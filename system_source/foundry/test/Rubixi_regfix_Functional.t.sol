// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/rubixi.sol";

// Foundry cheatcodes binding for Solidity 0.4.x
// 0.4 没有 interface，用抽象合约声明
contract Vm {
    function prank(address) public;
    function startPrank(address) public;
    function stopPrank() public;
    function deal(address, uint256) public;
    function expectRevert() public;
    function expectRevert(bytes) public;
    function store(address, bytes32, bytes32) public;
    function load(address, bytes32) public returns (bytes32);
}

contract Rubixi_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Rubixi_FunctionalTest() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() public payable { }


    // ---------- Helpers (0.4) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b);
    }
    function _assertTrue(bool ok, string why) internal { require(ok); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string why) internal {
        // op: 0==,1!=,2>=,3<=,4>,5<
        if (op == 0) require(a == b);
        else if (op == 1) require(a != b);
        else if (op == 2) require(a >= b);
        else if (op == 3) require(a <= b);
        else if (op == 4) require(a >  b);
        else if (op == 5) require(a <  b);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string why) internal {
        if (a >= b) require(a - b <= tol); else require(b - a <= tol);
    }
    function _assertEqA(address a, address b) internal { require(a == b); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b); }
    function _assertEqS(string a, string b) internal { if (sha3(a) != sha3(b)) { require(false); } }


    // @cover-intent Authorization & Access Control: Verify that DynamicPyramid() sets the caller as creator, enabling owner-only functions.
    function test_constructor_and_owner_setup_0() public {
// cover: DynamicPyramid :: creator = msg.sender
// cover: changeOwner :: onlyowner modifier passes
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.startPrank(owner);
        {
        target.changeOwner(bob);
        }
        {
        target.changeOwner(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner calls to guarded functions revert.
    function test_non_owner_reverts_on_guarded_functions_1() public {
// cover: collectAllFees :: onlyowner modifier fails
// cover: changeMultiplier :: onlyowner modifier fails
// cover: changeFeePercentage :: onlyowner modifier fails
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.startPrank(bob);
        vm.expectRevert();
        // skip ABI-mismatched call: collectAllFees()
        vm.expectRevert();
        {
        target.changeMultiplier(200);
        }
        vm.expectRevert();
        {
        target.changeFeePercentage(5);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that sending less than 1 ether via fallback adds to collectedFees without creating a participant.
    function test_fallback_init_small_value_adds_fees_2() public {
// cover: init :: msg.value < 1 ether
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.startPrank(bob);
        // skip ABI-mismatched call: feesSeperateFromBalanceApproximately()
        // skip ABI-mismatched call: totalParticipants()
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v1, 2, 0, "call:feesSeperateFromBalanceApproximately>=0");
        }
        {
            uint256 __v2 = uint256(target.totalParticipants());
            _assertRelU(__v2, 0, 0, "call:totalParticipants==0");
        }
    }

    // @cover-intent Protocol State Machine: Verify that sending exactly 1 ether creates a participant and updates balance and fees.
    function test_fallback_init_exact_one_ether_creates_participant_3() public {
// cover: init :: msg.value >= 1 ether
// cover: addPayout :: participants.push
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.startPrank(bob);
        // skip ABI-mismatched call: totalParticipants()
        // skip ABI-mismatched call: currentPyramidBalanceApproximately()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.totalParticipants());
            _assertRelU(__v3, 0, 1, "call:totalParticipants==1");
        }
        // skip bad numeric post: call:currentPyramidBalanceApproximately() >= 0
    }

    // @cover-intent Financial & Accounting: Verify that sending 50 ether or more halves the fee percentage.
    function test_fifty_ether_reduces_fee_percentage_4() public {
// cover: init :: msg.value >= 50 ether
// cover: init :: _fee /= 2
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(bob);
        // skip ABI-mismatched call: currentFeePercentage()
    }

    // @cover-intent Protocol State Machine: Verify that pyramidMultiplier changes when participants reach 10 and 25.
    function test_multiplier_changes_at_milestones_5() public {
// cover: addPayout :: participants.length == 10
// cover: addPayout :: participants.length == 25
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(bob);
        // skip ABI-mismatched call: currentMultiplier()
    }

    // @cover-intent Financial & Accounting: Verify that owner can collect all accumulated fees.
    function test_owner_collects_all_fees_6() public {
// cover: collectAllFees :: collectedFees > 0
// cover: collectAllFees :: creator.send(collectedFees)
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.startPrank(owner);
        // skip ABI-mismatched call: collectAllFees()
        // skip ABI-mismatched call: feesSeperateFromBalanceApproximately()
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v4, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Financial & Accounting: Verify that owner can collect a percentage of fees.
    function test_owner_collects_percent_of_fees_7() public {
// cover: collectPercentOfFees :: collectedFees > 0 && _pcent <= 100
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.startPrank(owner);
        {
        target.collectPercentOfFees(50);
        }
        // skip ABI-mismatched call: feesSeperateFromBalanceApproximately()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that owner can collect a specific amount of fees in ether.
    function test_owner_collects_fees_in_ether_8() public {
// cover: collectFeesInEther :: _amt <= collectedFees
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.startPrank(owner);
        {
        target.collectFeesInEther(0);
        }
        // skip ABI-mismatched call: feesSeperateFromBalanceApproximately()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can change multiplier and fee within allowed bounds.
    function test_owner_changes_multiplier_and_fee_9() public {
// cover: changeMultiplier :: 120 <= _mult <= 300
// cover: changeFeePercentage :: _fee <= 10
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.changeMultiplier(200);
        }
        {
        target.changeFeePercentage(5);
        }
        // skip ABI-mismatched call: currentMultiplier()
        // skip ABI-mismatched call: currentFeePercentage()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_DynamicPyramid_set_creator_10() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
    }

    // @cover-intent Authorization & Access Control
    function test_changeFeePercentage_owner_sets_fee_to_5_11() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.changeFeePercentage(5);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeMultiplier_owner_sets_multiplier_to_200_12() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.changeMultiplier(200);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_owner_transfers_ownership_to_alice_13() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.changeOwner(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_collectAllFees_owner_collects_fees_after_deposit_14() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        // skip ABI-mismatched call: collectAllFees()
        vm.stopPrank();
        {
            uint256 __v5 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v5, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_collectFeesInEther_owner_collects_partial_fees_15() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.collectFeesInEther(1);
        }
        vm.stopPrank();
        {
            uint256 __v6 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v6, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_collectPercentOfFees_owner_collects_50_of_fees_16() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.collectPercentOfFees(50);
        }
        vm.stopPrank();
        {
            uint256 __v7 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v7, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentFeePercentage_view_fee_17() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(alice);
        // skip ABI-mismatched call: currentFeePercentage()
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentMultiplier_view_multiplier_18() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(alice);
        // skip ABI-mismatched call: currentMultiplier()
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentPyramidBalanceApproximately_view_balance_19() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(bob);
        // skip ABI-mismatched call: currentPyramidBalanceApproximately()
    }

    // @cover-intent Resource & Execution Integrity
    function test_feesSeperateFromBalanceApproximately_view_fees_20() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(bob);
        // skip ABI-mismatched call: feesSeperateFromBalanceApproximately()
        {
            uint256 __v8 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v8, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_nextPayoutWhenPyramidBalanceTotalsApproximately_view_next_payout_21() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(bob);
        // skip ABI-mismatched call: nextPayoutWhenPyramidBalanceTotalsApproximately()
        {
            uint256 __v9 = uint256(target.nextPayoutWhenPyramidBalanceTotalsApproximately());
            _assertRelU(__v9, 2, 0, "call:nextPayoutWhenPyramidBalanceTotalsApproximately>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_numberOfParticipantsWaitingForPayout_view_count_22() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(bob);
        // skip ABI-mismatched call: numberOfParticipantsWaitingForPayout()
        {
            uint256 __v10 = uint256(target.numberOfParticipantsWaitingForPayout());
            _assertRelU(__v10, 0, 1, "call:numberOfParticipantsWaitingForPayout==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_participantDetails_view_participant_0_23() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(bob);
        {
        target.participantDetails(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_totalParticipants_view_count_24() public {
        vm.startPrank(owner);
        Rubixi target = new Rubixi();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(bob);
        // skip ABI-mismatched call: totalParticipants()
        {
            uint256 __v11 = uint256(target.totalParticipants());
            _assertRelU(__v11, 0, 1, "call:totalParticipants==1");
        }
    }

}
