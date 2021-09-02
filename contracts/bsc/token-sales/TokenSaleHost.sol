// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../tokens/IBEP20.sol";
import "../../utils/Ownable.sol";
import "../../utils/math/SafeMath.sol";
import "../../utils/aggregators/IAggregatorV3.sol";

  /**
   * @dev The definition of a token sale.
   */
  struct Session {
      // UID
      uint256 id;
      // Timestamp the sale starts
      uint256 start;
      // Timestamp the sale stops
      uint256 stop;
      // Last rate sync timestamp
      uint256 sync;
      // Current Rate
      uint256 rate;
      // Rate normalization: rate / 10**{decimal}
      uint8 decimal;
      // Current TOKEN|BNB Rate
      uint256 issue;
      // WEI raised
      uint256 raised;
      // Maximum sale quantity
      uint256 max;
      // Total tokens sold
      uint256 sold;
      // Total minutes before bnb rate update
      uint256 threshold;
      // Contract address of chainlink aggregator
      address chainlink;
      // Token Sale Owner
      address owner;
      // Token Contract
      IBEP20 token;
  }

/**
 * @title TokenSaleHost
 * @dev Host contract from token "crowd" sales.
 */
contract TokenSaleHost is Ownable {
  using SafeMath for uint;

  /**
   * @dev The token sale sessions.
   */
  mapping(uint => Session) public sessions;
  /**
   * @dev The token sale contract sessions, reverse lookup.
   */
  mapping(address => uint) private tokenSessions;
  /**
   * @dev The uid source.
   */
  uint internal uid;
  /**
   * @dev The current token fee.
   */
  uint internal pToken;
  /**
   * @dev The current coin fee.
   */
  uint internal pCoin;
  /**
   * @dev The emergency kill switch... this should never be used *crosses fingers*
   */
  bool internal kill;
  /**
   * @dev The chainlink aggregator for the contract.
   */
  IAggregatorV3 internal rates;

  /**
   * @dev Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );
  
  /**
   * TODO: Documentation
   */
  event SessionScheduled(
      address indexed creator,
      uint256 id
  );
  
  /**
   * @dev Reverts if sale id not open.
   */
  modifier open(uint _id) {
      require(!kill);
      // solium-disable-next-line security/no-block-members
      require(block.timestamp >= sessions[_id].start && block.timestamp <= sessions[_id].stop);
      _;
  }

  modifier notExists(address _token) {
      uint _cid = 0;
      _cid = tokenSessions[_token];
      if(_cid > 0){
        Session storage sesh = sessions[_cid];
        require(block.timestamp >= sesh.stop);
      }
      _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   */
  constructor() {
      uid = 0;    // Seed 0.
      pCoin = 1;  // Default 1%
      pToken = 1; // Default 1%
  }
  
  /**
   * TODO: Documentation
   */
  function create(uint256 _start,
  uint256 _stop,
  uint256 _rate, 
  uint8 _decimal,
  uint256 _issue,
  uint256 _max,
  uint256 _threshold,
  address _chainlink,
  address _token) 
  external 
  payable 
  notExists(_token) 
  returns(uint256) {
      require(address(_token) != address(0));
      // solium-disable-next-line security/no-block-members
      require(_start >= block.timestamp);
      require(_stop > _start);
      require(_rate >= 0 || _chainlink != address(0));
      
      uint _id = _getId();
      
      Session memory sesh = Session({
          id: _id,
          start: _start,
          stop: _stop,
          sync: uint256(0),
          rate: _rate,
          decimal: _decimal,
          issue: _issue,
          max: _max,
          sold: uint256(0),
          raised: uint256(0),
          threshold: _threshold,
          chainlink: _chainlink,
          owner: msg.sender,
          token: IBEP20(_token)
      });

      sessions[_id] = sesh;
      tokenSessions[_token] = _id;
      
      emit SessionScheduled(msg.sender, _id);
      return _id;
  }

 /**
  * @dev Liquidate the specified token from the contract.
  * if {token} == address(0) liquidate the underlying coin.
  */
  function liquidate(address token) external onlyOwner {
    if(token == address(0)) {
        payable(owner()).transfer(address(this).balance);
    }else{
        IBEP20 t = IBEP20(token);
        t.transfer(owner(), t.balanceOf(address(this)));
    }
  }

  /**
   * @dev Lock / Unlock contract with kill switch, only to be used in emergencies.
   */
  function lock(bool _lock) external onlyOwner {
      kill = _lock;
  }

  /**
   * @dev Set the applied contract fee for coins.
   */
  function setCoinFee(uint coinFee) external onlyOwner {
      if(coinFee > 0) {
        pCoin = coinFee;
      }
  }

  /**
   * @dev Set the applied contract fee for tokens.
   */
  function setTokenFee(uint tokenFee) external onlyOwner {
      if(tokenFee > 0) {
        pToken = tokenFee;
      }
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @param _id the token sale uid
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed(uint256 _id) external view returns(bool){
      Session storage sesh = sessions[_id];
      return block.timestamp > sesh.stop;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _id sale id
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase (uint256 _id,address _beneficiary,uint256 _weiAmount) internal view open(_id) {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }
  
  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  fallback () external  payable {}
  
  /**
   * @dev receive function ***DO NOT OVERRIDE***
   */
  receive () external payable {}
  
  /**
   * @dev Returns the next unique id in the sequence.
   */
  function _getId() private returns(uint256){
      return uid += 1;
  }

  /**
   * @dev Returns the fee adjusted transfer amount, and applied fees.
   * @param {uint} _amount of wei involved in token purchase.
   */
  function _getValues(uint _amount) private view returns  (uint,uint,uint){
      uint tokenFee = _calculateFee(_amount,pToken);
      uint baseFee = _calculateFee(_amount,pCoin);
      uint transferAmount = _amount.sub(tokenFee).sub(baseFee);
      return (transferAmount, tokenFee, baseFee);
  }

  function _calculateFee(uint _amount, uint _rate) private pure returns (uint) {
        if(_amount <= 0) return 0;
        return _amount.mul(_rate).div(10**2);
  }
   
  /**
   * @dev Returns the latest rate price.
   * @param {address} _chainlink  aggregator contract address.
   * @param {int8}  _decimal integer to normalize to a desired fiat increment
   */
   function _getLatestPrice(address _chainlink, uint8 _decimal) private returns(uint){
       rates = IAggregatorV3(_chainlink);
       (,int price,,,) = rates.latestRoundData(); 
       return (uint(price) / 10**_decimal);
   }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(uint _id, address _beneficiary) external payable open(_id) {
      uint weiAmount = msg.value;
      _preValidatePurchase(_id,_beneficiary, weiAmount);
      (uint tokens, uint tFee, uint bFee) = _getValues(_getTokenAmount(_id,weiAmount));
      _processPurchase(_id, _beneficiary, tokens, tFee);
      emit TokenPurchase(msg.sender,_beneficiary,weiAmount,tokens);
      _forwardFunds(_id, bFee);
      _postValidatePurchase(_id,_beneficiary, weiAmount);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _wei Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    uint256 _id,
    address _beneficiary,
    uint256 _wei
  )
    internal
  {
    Session storage sesh = sessions[_id];
    sesh.raised = sesh.raised.add(_wei);
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    uint256 _id,
    address _beneficiary,
    uint256 _tokenAmount,
    uint _fee
  )
    internal
  {
    Session storage sesh = sessions[_id];
    sesh.token.transfer(_beneficiary, (_tokenAmount - _fee));
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    uint _id,
    address _beneficiary,
    uint _tokenAmount,
    uint _tokenFee
  )
    internal
  {
    _deliverTokens(_id, _beneficiary, _tokenAmount, _tokenFee);
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _id sale id
   * @param _wei Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _wei
   */
  function _getTokenAmount(uint _id, uint _wei)
    internal returns (uint256)
  {
      Session storage sesh = sessions[_id];
      if(sesh.rate > 0 && sesh.sync > 0){
          if((block.timestamp - sesh.sync).div(1000).div(60) >= sesh.threshold){
              sesh.rate = _getLatestPrice(sesh.chainlink, sesh.decimal);
              sesh.sync = block.timestamp;
          }
      }else{
          sesh.rate = _getLatestPrice(sesh.chainlink, sesh.decimal);
          sesh.sync = block.timestamp;
      }
    return _wei.div(10**18).mul(sesh.rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds(uint _id, uint _baseFee) internal {
      payable(sessions[_id].owner).transfer((msg.value-_baseFee));
  }
}