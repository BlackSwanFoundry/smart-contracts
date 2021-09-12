// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./storage/EternalStorage.sol";

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is EternalStorage, Ownable {
    function newOwner() public view returns (address) {
        return addressStorage[keccak256("newOwner")];
    }

    /**
    * @dev Modifier throws if called by any account other than the newOwner.
    */
    modifier onlyNewOwner() {
        require(msg.sender == newOwner());
        _;
    }

    /**
    * @dev Allows the current owner to set the newOwner address.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) override public onlyOwner {
        require(_newOwner != address(0));
        addressStorage[keccak256("newOwner")] = _newOwner;
    }

    /**
    * @dev Allows the newOwner address to finalize the transfer.
    */
    function claimOwnership() public onlyNewOwner {
        emit OwnershipTransferred(owner(), newOwner());
        addressStorage[keccak256("owner")] = addressStorage[keccak256("newOwner")];
        addressStorage[keccak256("newOwner")] = address(0);
    }
}