// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "./Escrow_0517_Invariant.t.sol";

// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract Escrow_0517LegacyEthFlowSupplementTest is Escrow_0517BasePropertyTest {

    function test_supplement_eth_balance_bound_0_deposited() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.deposited() <= address(target).balance);
    }
}
