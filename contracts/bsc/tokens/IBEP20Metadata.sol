// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IBEP20.sol";

/**
 * @dev Interface for the optional metadata functions from the BEP20 standard.
 *
 * _Available since v4.1._
 */
interface IBEP20Metadata is IBEP20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() override external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() override external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() override external view returns (uint8);
}