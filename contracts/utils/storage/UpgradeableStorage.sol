// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title UpgradeableStorage
 * @dev This contract holds all the necessary state variables to support the upgrade functionality
 */
contract UpgradeableStorage {
  // Version name of the current implementation
    string internal _version;

    // Address of the current implementation
    address internal _implementation;

    /**
    * @dev Tells the version name of the current implementation
    * @return string representing the name of the current version
    */
    function version() public view returns (string memory) {
        return _version;
    }

    /**
    * @dev Tells the address of the current implementation
    * @return address of the current implementation
    */
    function implementation() public view returns (address) {
        return _implementation;
    }
}