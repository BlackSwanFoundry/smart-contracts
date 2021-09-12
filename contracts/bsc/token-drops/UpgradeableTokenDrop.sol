// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../tokens/IBEP20.sol";
import "../../utils/math/SafeMath.sol";
import "../../utils/storage/OwnedUpgradeableStorage.sol";
import "../../utils/Claimable.sol";

contract UpgradebleTokenDrop is OwnedUpgradeableStorage, Claimable {
    using SafeMath for uint;

    event Multisended(uint total, address tokenAddress);
    event ClaimedTokens(address token, address owner, uint balance);

    modifier hasFee() {
        if (currentFee(msg.sender) > 0) {
            require(msg.value >= currentFee(msg.sender));
        }
        _;
    }

    receive() external payable{}
    fallback() external payable{}

    function initialize(address _owner) public {
        require(!initialized());
        transferOwnership(_owner);
        setArrayLimit(200);
        setDiscountStep(0.00005 ether);
        setFee(0.05 ether);
        boolStorage[keccak256("bsf_drop_init")] = true;
    }

    function initialized() public view returns (bool) {
        return boolStorage[keccak256("bsf_drop_init")];
    }
 
    function txCount(address customer) public view returns(uint) {
        return uintStorage[keccak256(abi.encodePacked("txcount", customer))];
    }

    function arrayLimit() public view returns(uint) {
        return uintStorage[keccak256("arrayLimit")];
    }

    function setArrayLimit(uint _newLimit) public onlyOwner {
        require(_newLimit != 0);
        uintStorage[keccak256("arrayLimit")] = _newLimit;
    }

    function discountStep() public view returns(uint) {
        return uintStorage[keccak256("discountStep")];
    }

    function setDiscountStep(uint _newStep) public onlyOwner {
        require(_newStep != 0);
        uintStorage[keccak256("discountStep")] = _newStep;
    }

    function fee() public view returns(uint) {
        return uintStorage[keccak256("fee")];
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
        uintStorage[keccak256("fee")] = _newStep;
    }

    function discountRate(address _customer) public view returns(uint) {
        uint count = txCount(_customer);
        return count.mul(discountStep());
    }

    function multisendToken(address token, address[] calldata _contributors, uint[] calldata _balances) public hasFee payable {
        if (token == 0x000000000000000000000000000000000000bEEF){
            multisendEther(_contributors, _balances);
        } else {
            uint total = 0;
            require(_contributors.length <= arrayLimit());
            IBEP20 IBEP20token = IBEP20(token);
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
                IBEP20token.transferFrom(msg.sender, _contributors[i], _balances[i]);
                total += _balances[i];
            }
            setTxCount(msg.sender, txCount(msg.sender).add(1));
            emit Multisended(total, token);
        }
    }

    function multisendEther(address[] calldata _contributors, uint[] calldata _balances) public payable {
        uint total = msg.value;
        uint fee_ = currentFee(msg.sender);
        require(total >= fee_);
        require(_contributors.length <= arrayLimit());
        total = total.sub(fee_);
        uint i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            payable(_contributors[i]).transfer(_balances[i]);
        }
        setTxCount(msg.sender, txCount(msg.sender).add(1));
        emit Multisended(msg.value, 0x000000000000000000000000000000000000bEEF);
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
    
    function setTxCount(address customer, uint _txCount) private {
        uintStorage[keccak256(abi.encodePacked("txCount", customer))] = _txCount;
    }

}