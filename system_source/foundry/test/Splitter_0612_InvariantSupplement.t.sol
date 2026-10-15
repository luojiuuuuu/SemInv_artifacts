// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "./Splitter_0612_Invariant.t.sol";

// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract Splitter_0612LegacyEthFlowSupplementTest is Splitter_0612BasePropertyTest {

    function test_supplement_receive_no_retained_eth() public {
        // invariant: I4.transaction.receive_no_retained_eth
        uint256 beforeBalance = address(target).balance;
        handler.call_receive();
        _assertTrue(address(target).balance <= beforeBalance);
    }
}
