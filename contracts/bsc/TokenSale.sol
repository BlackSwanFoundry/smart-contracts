// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * Chainlink Aggregator interface.
 */
interface IAggregatorV3 {

  function decimals()
    external
    view
    returns (
      uint8
    );

  function description()
    external
    view
    returns (
      string memory
    );

  function version()
    external
    view
    returns (
      uint256
    );

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Ownable {
  using SafeMath for uint;
  
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
        if(bytes(sesh).length > 0){
          require(block.timestamp >= sesh.stop);
        }
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
  fallback () external  payable {
  }
  
  /**
   * @dev receive function ***DO NOT OVERRIDE***
   */
  receive () external payable {
  }
  
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