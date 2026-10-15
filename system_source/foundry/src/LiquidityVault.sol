// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * Minimal liquidity accounting model (Bunni-style)
 * Demonstrates cumulative rounding error across repeated actions
 */
contract LiquidityVault {

    uint256 public totalLiquidity;
    mapping(address => uint256) public userBalance;

    constructor(uint256 _initial) {
        totalLiquidity = _initial;
    }

    // deposit updates global invariant
    function deposit(uint256 amount) external {
        userBalance[msg.sender] += amount;
        totalLiquidity += amount;
    }

    // ⚠️ repeated withdrawals cause rounding drift
    function withdraw(uint256 amount) external returns (uint256 payout) {

        require(userBalance[msg.sender] >= amount, "insufficient");

        // simplified share-based accounting
        uint256 share = (amount * totalLiquidity) / (totalLiquidity + 1);

        payout = share;

        userBalance[msg.sender] -= amount;
        totalLiquidity -= share;

        return payout;
    }

    // invariant check (intended but violated over time)
    function checkInvariant() external view returns (bool) {
        return totalLiquidity >= 0;
    }
}