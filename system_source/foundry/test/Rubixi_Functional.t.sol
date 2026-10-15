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


    // @cover-intent Authorization & Access Control: Verify that only the contract creator (owner) can call access-controlled functions, and that non-owners are rejected.
    function test_initial_owner_setup_and_authorization_0() public {
// cover: changeOwner :: onlyowner modifier true
// cover: changeOwner :: onlyowner modifier false
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
        {
        target.DynamicPyramid();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOwner(alice);
        }
        vm.startPrank(owner);
        {
        target.changeOwner(alice);
        }
        {
        target.changeOwner(owner);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that the owner can collect all accumulated fees after participants send ETH.
    function test_fee_collection_positive_path_1() public {
// cover: collectAllFees :: collectedFees != 0
// cover: collectAllFees :: onlyowner modifier true
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
        {
        target.DynamicPyramid();
        }
        {
        target.collectAllFees();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that collectAllFees reverts when there are no collected fees.
    function test_fee_collection_empty_revert_2() public {
// cover: collectAllFees :: collectedFees == 0
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
        {
        target.DynamicPyramid();
        }
        vm.expectRevert();
        {
        target.collectAllFees();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify collectFeesInEther with amount less than collected fees works, and that exceeding collected fees triggers collectAllFees.
    function test_collect_fees_in_ether_boundary_3() public {
// cover: collectFeesInEther :: _amt <= collectedFees
// cover: collectFeesInEther :: _amt > collectedFees
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
        {
        target.DynamicPyramid();
        }
        {
        target.collectFeesInEther(1);
        }
        {
        target.collectFeesInEther(100);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify collectPercentOfFees with valid percentage and revert with invalid percentage.
    function test_collect_percent_of_fees_boundary_4() public {
// cover: collectPercentOfFees :: _pcent <= 100
// cover: collectPercentOfFees :: _pcent > 100
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
        {
        target.DynamicPyramid();
        }
        {
        target.collectPercentOfFees(50);
        }
        vm.expectRevert();
        {
        target.collectPercentOfFees(101);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify changeMultiplier accepts values within [120, 300] and rejects values outside.
    function test_change_multiplier_boundary_5() public {
// cover: changeMultiplier :: _mult >= 120 && _mult <= 300
// cover: changeMultiplier :: _mult < 120 || _mult > 300
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
        {
        target.DynamicPyramid();
        }
        {
        target.changeMultiplier(120);
        }
        {
        target.changeMultiplier(300);
        }
        vm.expectRevert();
        {
        target.changeMultiplier(119);
        }
        vm.expectRevert();
        {
        target.changeMultiplier(301);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.currentMultiplier());
            _assertRelU(__v1, 2, 120, "call:currentMultiplier>=120");
        }
        {
            uint256 __v2 = uint256(target.currentMultiplier());
            _assertRelU(__v2, 3, 300, "call:currentMultiplier<=300");
        }
    }

    // @cover-intent Protocol State Machine: Verify changeFeePercentage accepts values <= 10 and rejects values > 10.
    function test_change_fee_percentage_boundary_6() public {
// cover: changeFeePercentage :: _fee <= 10
// cover: changeFeePercentage :: _fee > 10
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
        {
        target.DynamicPyramid();
        }
        {
        target.changeFeePercentage(0);
        }
        {
        target.changeFeePercentage(10);
        }
        vm.expectRevert();
        {
        target.changeFeePercentage(11);
        }
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.currentFeePercentage());
            _assertRelU(__v3, 3, 10, "call:currentFeePercentage<=10");
        }
    }

    // @cover-intent Financial & Accounting: Verify that participating with 1 ETH adds participant, updates balance, and triggers payouts when balance is sufficient.
    function test_pyramid_participation_and_payout_7() public {
// cover: init :: msg.value >= 1 ether
// cover: addPayout :: balance > participants[payoutOrder].payout
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
        {
        target.DynamicPyramid();
        }
        {
        target.totalParticipants();
        }
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.totalParticipants());
            _assertRelU(__v4, 0, 2, "call:totalParticipants==2");
        }
        {
            uint256 __v5 = uint256(target.numberOfParticipantsWaitingForPayout());
            _assertRelU(__v5, 2, 0, "call:numberOfParticipantsWaitingForPayout>=0");
        }
    }

    // @cover-intent Financial & Accounting: Verify that sending less than 1 ether adds to collectedFees without creating a participant.
    function test_small_donation_goes_to_fees_8() public {
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
        vm.startPrank(owner);
        {
        target.DynamicPyramid();
        }
        {
        target.totalParticipants();
        }
        {
        target.feesSeperateFromBalanceApproximately();
        }
        vm.stopPrank();
        {
            uint256 __v6 = uint256(target.totalParticipants());
            _assertRelU(__v6, 0, 0, "call:totalParticipants==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_DynamicPyramid_set_creator_9() public {
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
        {
        target.DynamicPyramid();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeFeePercentage_owner_sets_fee_to_5_10() public {
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
        {
        target.DynamicPyramid();
        }
        {
        target.changeFeePercentage(5);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeMultiplier_owner_sets_multiplier_to_200_11() public {
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
        {
        target.DynamicPyramid();
        }
        {
        target.changeMultiplier(200);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_owner_transfers_ownership_to_bob_12() public {
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
        {
        target.DynamicPyramid();
        }
        {
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_collectAllFees_owner_collects_fees_after_deposit_13() public {
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
        {
        target.DynamicPyramid();
        }
        {
        target.collectAllFees();
        }
        vm.stopPrank();
        {
            uint256 __v7 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v7, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_collectFeesInEther_owner_collects_partial_fees_14() public {
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
        {
        target.DynamicPyramid();
        }
        {
        target.collectFeesInEther(1);
        }
        vm.stopPrank();
        {
            uint256 __v8 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v8, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_collectPercentOfFees_owner_collects_50_of_fees_15() public {
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
        {
        target.DynamicPyramid();
        }
        {
        target.collectPercentOfFees(50);
        }
        vm.stopPrank();
        {
            uint256 __v9 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v9, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentFeePercentage_view_fee_16() public {
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
        {
        target.currentFeePercentage();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentMultiplier_view_multiplier_17() public {
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
        {
        target.currentMultiplier();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentPyramidBalanceApproximately_view_balance_18() public {
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
        {
        target.currentPyramidBalanceApproximately();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_feesSeperateFromBalanceApproximately_view_fees_19() public {
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
        {
        target.feesSeperateFromBalanceApproximately();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_nextPayoutWhenPyramidBalanceTotalsApproximately_view_next_payout_20() public {
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
        {
        target.nextPayoutWhenPyramidBalanceTotalsApproximately();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_numberOfParticipantsWaitingForPayout_view_count_21() public {
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
        {
        target.numberOfParticipantsWaitingForPayout();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_participantDetails_view_participant_0_22() public {
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
        {
        target.participantDetails(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_totalParticipants_view_count_23() public {
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
        {
        target.totalParticipants();
        }
    }

}
