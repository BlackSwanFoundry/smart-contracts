// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../tokens/IBEP20.sol";
import "../../utils/math/SafeMath.sol";
import "../../utils/storage/OwnedUpgradeableStorage.sol";
import "../../utils/Claimable.sol";

contract UpgradebleTokenDrop is OwnedUpgradeableStorage {
    using SafeMath for uint;

    string internal _init = "bsf_drop_init";
    string internal _tx_count = "bsf_drop_tx_count";
    string internal _limit_array = "bsf_drop_limit_array";
    string internal _fee_discount = "bsf_drop_step_discount";
    string internal _fee = "bsf_drop_fee";
    string internal _fee_exempt = "bsf_drop_fee_exempt";

    address internal _base_trigger = 0x00000000000000000000000000000000000DEeCE;

    event DropSent(uint total, address tokenAddress);
    event ClaimedTokens(address token, address owner, uint balance);

    modifier hasFee() {
        if (currentFee(msg.sender) > 0) {
            require(msg.value >= currentFee(msg.sender));
        }
        _;
    }

    constructor(){
        setArrayLimit(200);
        setDiscountStep(0.00005 ether);
        setFee(0.05 ether);
        setFeeExempt(_owner(), true);
        boolStorage[keccak256(abi.encode(_init))] = true;
    }

    receive() external payable{}
    fallback() external payable{}

    function initialize(address _no) external onlyOwner {
        require(!_initialized());
        setFeeExempt(_owner(), false);
        transferOwnership(_no);
        setFeeExempt(_newOwner(), true);
        boolStorage[keccak256(abi.encode(_init))] = true;
    }

    function _initialized() internal view returns (bool){
        return boolStorage[keccak256(abi.encode(_init))];
    }

    function initialized() external view returns (bool) {
        return _initialized();
    }

    function _txCount(address customer) internal view returns(uint){
        return uintStorage[keccak256(abi.encodePacked(_tx_count, customer))];
    }
 
    function txCount(address customer) external view returns(uint) {
        return _txCount(customer);
    }

    function _arrayLimit() internal view returns(uint){
        return uintStorage[keccak256(abi.encode(_limit_array))];
    }

    function arrayLimit() external view returns(uint) {
        return _arrayLimit();
    }

    function setArrayLimit(uint _newLimit) public onlyOwner {
        require(_newLimit != 0);
        uintStorage[keccak256(abi.encode(_limit_array))] = _newLimit;
    }

    function _discountStep() internal view returns(uint){
        return uintStorage[keccak256(abi.encode(_fee_discount))];
    }

    function discountStep() external view returns(uint) {
        return uintStorage[keccak256(abi.encode(_fee_discount))];
    }

    function setDiscountStep(uint _newStep) public onlyOwner {
        require(_newStep != 0);
        uintStorage[keccak256(abi.encode(_fee_discount))] = _newStep;
    }

    function fee() public view returns(uint) {
        return uintStorage[keccak256(abi.encode(_fee))];
    }

    function _exempt(address sender) internal view returns(bool) {
        return boolStorage[keccak256(abi.encodePacked(_fee_exempt, sender))];
    }

    function currentFee(address _customer) public view returns(uint) {
        if (fee() > discountRate(msg.sender)) {
            return fee().sub(discountRate(_customer));
        } else {
            return 0;
        }
    }

    function setFee(uint _newStep) public onlyOwner {
        require(_newStep != 0);
        uintStorage[keccak256(abi.encode(_fee))] = _newStep;
    }

    function setFeeExempt(address customer, bool exempt) public onlyOwner {
        boolStorage[keccak256(abi.encodePacked(_fee_exempt, customer))] = exempt;
    }

    function discountRate(address _customer) public view returns(uint) {
        uint count = _txCount(_customer);
        return count.mul(_discountStep());
    }

    function disable() external onlyOwner{
        boolStorage[keccak256(abi.encode(_init))] = false;
    }

    function multisendToken(address token, address[] calldata _contributors, uint[] calldata _balances) public hasFee payable {
        if (token == _base_trigger){
            multisendEther(_contributors, _balances);
        } else {
            uint total = 0;
            require(_contributors.length <= _arrayLimit());
            IBEP20 IBEP20token = IBEP20(token);
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
                IBEP20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
                total += _balances[i];
            }
            setTxCount(msg.sender, _txCount(msg.sender).add(1));
            emit DropSent(total, token);
        }
    }

    function multisendEther(address[] calldata _contributors, uint[] calldata _balances) public payable {
        uint total = msg.value;
        uint fee_ = currentFee(msg.sender);
        require(total >= fee_);
        require(_contributors.length <= _arrayLimit());
        total = total.sub(fee_);
        uint i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            payable(_contributors[i]).transfer(_balances[i]);
        }
        setTxCount(msg.sender, _txCount(msg.sender).add(1));
        emit DropSent(msg.value, _base_trigger);
    }

    function claimTokens(address _token) public onlyOwner {
        if (_token == address(0x0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }
        IBEP20 IBEP20token = IBEP20(_token);
        uint balance = IBEP20token.balanceOf(address(this));
        IBEP20token.transfer(owner(), balance);
        emit ClaimedTokens(_token, owner(), balance);
    }
    
    function setTxCount(address customer, uint txCount_) private {
        uintStorage[keccak256(abi.encodePacked(_tx_count, customer))] = txCount_;
    }
}