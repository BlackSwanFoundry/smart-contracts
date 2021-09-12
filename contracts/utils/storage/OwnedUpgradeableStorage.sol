// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./EternalStorage.sol";
import "./UpgradeableStorage.sol";
import "./UpgradeableOwnerStorage.sol";

/**
 * @title OwnedUpgradeableStorage
 * @dev This is the storage necessary to perform upgradeable contracts.
 * This means, required state variables for Upgradeable purpose and eternal storage per se.
 */
contract OwnedUpgradeableStorage is UpgradeableOwnerStorage, UpgradeableStorage, EternalStorage {}