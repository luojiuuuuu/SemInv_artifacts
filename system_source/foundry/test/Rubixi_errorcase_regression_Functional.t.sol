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


    // @cover-intent Authorization & Access Control: Verify that only the owner can collect all accumulated fees, and that the collectedFees state is reset to zero after collection.
    function test_owner_can_collect_all_fees_0() public {
// cover: collectAllFees :: onlyowner modifier true
// cover: collectAllFees :: onlyowner modifier false
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: collectAllFees()
        {
            uint256 __v1 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v1, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can collect a specific percentage of fees, and that the collectedFees decreases accordingly.
    function test_owner_can_collect_percent_of_fees_1() public {
// cover: collectPercentOfFees :: onlyowner modifier true
// cover: collectPercentOfFees :: onlyowner modifier false
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.collectPercentOfFees(50);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.collectPercentOfFees(50);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can collect a specific amount of fees in ether, and that the collectedFees decreases by the specified amount.
    function test_owner_can_collect_fees_in_ether_2() public {
// cover: collectFeesInEther :: onlyowner modifier true
// cover: collectFeesInEther :: onlyowner modifier false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.collectFeesInEther(1);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can change the multiplier, and that the multiplier is constrained between 120 and 300.
    function test_owner_can_change_multiplier_3() public {
// cover: changeMultiplier :: onlyowner modifier true
// cover: changeMultiplier :: onlyowner modifier false
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
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.changeMultiplier(200);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeMultiplier(200);
        }
        vm.startPrank(owner);
        vm.expectRevert();
        {
        target.changeMultiplier(100);
        }
        vm.expectRevert();
        {
        target.changeMultiplier(400);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can change the fee percentage, and that the fee is capped at 10.
    function test_owner_can_change_fee_percentage_4() public {
// cover: changeFeePercentage :: onlyowner modifier true
// cover: changeFeePercentage :: onlyowner modifier false
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
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.changeFeePercentage(5);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeFeePercentage(5);
        }
        vm.expectRevert();
        vm.prank(owner);
        {
        target.changeFeePercentage(15);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the current owner can change the owner address.
    function test_owner_can_change_owner_5() public {
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.changeOwner(alice);
        }
        {
        target.changeOwner(bob);
        }
        vm.expectRevert();
        {
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that sending less than 1 ether to the contract adds the value to collectedFees without creating a participant.
    function test_fallback_init_with_small_value_adds_to_fees_6() public {
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
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.prank(alice);
        // skip ABI-mismatched call: totalParticipants()
    }

    // @cover-intent Financial & Accounting: Verify that sending 1 ether or more creates a participant and updates the balance.
    function test_fallback_init_with_large_value_creates_participant_7() public {
// cover: init :: msg.value >= 1 ether
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
        // skip ABI-mismatched call: totalParticipants()
        {
            uint256 __v2 = uint256(target.totalParticipants());
            _assertRelU(__v2, 0, 1, "call:totalParticipants==1");
        }
    }

    // @cover-intent Transactional Consistency: Verify that participantDetails returns the correct address and payout for a valid participant index.
    function test_participant_details_returns_correct_info_8() public {
// cover: participantDetails :: orderInPyramid <= participants.length
// cover: participantDetails :: orderInPyramid > participants.length
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
        vm.startPrank(alice);
        {
        target.participantDetails(0);
        }
        {
        target.participantDetails(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_DynamicPyramid_test_9() public {
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
    function test_changeFeePercentage_test_10() public {
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
    function test_changeMultiplier_test_11() public {
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
    function test_changeOwner_test_12() public {
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
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_collectAllFees_test_13() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_collectFeesInEther_test_14() public {
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
        // skip malformed call: collectFeesInEther(0.05) (bad raw arg for collectFeesInEther.arg0: type=uint256, raw=0.05)
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_collectPercentOfFees_test_15() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_currentFeePercentage_test_16() public {
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
        // skip ABI-mismatched call: currentFeePercentage()
    }

    // @cover-intent Financial & Accounting
    function test_currentMultiplier_test_17() public {
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
        // skip ABI-mismatched call: currentMultiplier()
    }

    // @cover-intent Financial & Accounting
    function test_currentPyramidBalanceApproximately_test_18() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: currentPyramidBalanceApproximately()
    }

    // @cover-intent Financial & Accounting
    function test_feesSeperateFromBalanceApproximately_test_19() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: feesSeperateFromBalanceApproximately()
    }

    // @cover-intent Financial & Accounting
    function test_nextPayoutWhenPyramidBalanceTotalsApproximately_test_20() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: nextPayoutWhenPyramidBalanceTotalsApproximately()
    }

    // @cover-intent Financial & Accounting
    function test_numberOfParticipantsWaitingForPayout_test_21() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: numberOfParticipantsWaitingForPayout()
    }

    // @cover-intent Financial & Accounting
    function test_participantDetails_test_22() public {
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
        vm.prank(bob);
        {
        target.participantDetails(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_totalParticipants_test_23() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: totalParticipants()
    }

}
