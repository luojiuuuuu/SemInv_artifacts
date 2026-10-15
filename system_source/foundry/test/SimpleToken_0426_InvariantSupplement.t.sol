// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "./SimpleToken_0426_Invariant.t.sol";

// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract SimpleToken_0426LegacyAccountingSupplementTest is SimpleToken_0426LegacyPropertyTest {

    function test_supplement_accounting_sum_0() public {
        // invariant: I1.accounting.sum_supply_consistency
        _run_basic_sequence();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            sum += target.balanceOf(handler.actor(i));
        }
        _assertTrue(sum <= target.totalSupply());
    }
}
