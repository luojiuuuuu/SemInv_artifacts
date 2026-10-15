// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract Bytes32ArrayCtorOnly {
    bytes32[] public names;

    constructor(bytes32[] memory initNames) {
        for (uint256 i = 0; i < initNames.length; i++) {
            names.push(initNames[i]);
        }
    }

    function namesLength() external view returns (uint256) {
        return names.length;
    }
}