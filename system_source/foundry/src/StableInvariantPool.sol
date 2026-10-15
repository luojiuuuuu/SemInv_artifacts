// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * Minimal Stable AMM model (Balancer-style invariant)
 * Shows rounding-error-induced invariant drift across multi-step swaps
 */
contract StableInvariantPool {

    uint256 public invariantD;
    mapping(address => uint256) public balance;

    // --- initialize pool invariant ---
    constructor(uint256 _initD) {
        invariantD = _initD;
    }

    // --- simplified swap (multi-step attack target) ---
    function swap(address tokenIn, uint256 amountIn) external returns (uint256 amountOut) {

        uint256 x = balance[tokenIn] + amountIn;

        // invariant-based pricing (simplified)
        uint256 expectedOut = invariantD * 1e18 / (x + 1);

        // ⚠️ rounding truncation (core vulnerability surface)
        amountOut = expectedOut / 1e18;

        balance[tokenIn] = x;

        // invariant update is approximate (key issue)
        invariantD = invariantD + amountIn - amountOut;

        return amountOut;
    }

    // --- multi-transaction vulnerability emerges here ---
    function getInvariant() external view returns (uint256) {
        return invariantD;
    }
}