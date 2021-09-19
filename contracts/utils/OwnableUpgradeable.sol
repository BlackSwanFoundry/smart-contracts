// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../utils/Context.sol";
import "./storage/EternalStorage.sol";

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
abstract contract OwnableUpgradeable is Context, EternalStorage {
    string internal _owner_ = "bsf_own_owner";
    string internal _new_owner_ = "bsf_own_new_owner";

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
    function owner() external view virtual returns (address) {
        return _owner();
    }

    function _owner() internal view virtual returns (address){
        return addressStorage[keccak256(abi.encode(_owner_))];
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }

    function _setOwner(address _no) internal {
        address oldOwner = addressStorage[keccak256(abi.encode(_owner_))];
        addressStorage[keccak256(abi.encode(_new_owner_))] = _no;
        emit OwnershipTransferred(oldOwner, _no);
    }

    function newOwner() external view returns (address) {
        return _newOwner();
    }

    function _newOwner() internal view returns (address){
        return addressStorage[keccak256(abi.encode(_new_owner_))];
    }

    /**
    * @dev Modifier throws if called by any account other than the newOwner.
    */
    modifier onlyNewOwner() {
        require(msg.sender == _newOwner());
        _;
    }

    /**
    * @dev Allows the current owner to set the newOwner address.
    * @param _no The address to transfer ownership to.
    */
    function transferOwnership(address _no) external onlyOwner {
        require(_no != address(0), "Ownable: new owner is the zero address");
        _setOwner(_no);
    }

    /**
    * @dev Allows the newOwner address to finalize the transfer.
    */
    function claimOwnership() external onlyNewOwner {
        emit OwnershipTransferred(_owner(), _newOwner());
        addressStorage[keccak256(abi.encode(_owner_))] = addressStorage[keccak256(abi.encode(_new_owner_))];
        addressStorage[keccak256(abi.encode(_new_owner_))] = address(0);
    }
}