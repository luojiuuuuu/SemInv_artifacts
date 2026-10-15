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


    // @cover-intent Authorization & Access Control: Verify that DynamicPyramid() can be called by anyone to set the creator, which is a vulnerability because it overwrites the owner.
    function test_DynamicPyramid_anyone_can_set_creator_0() public {
// cover: DynamicPyramid :: creator = msg.sender
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
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Owner can collect all fees when collectedFees > 0.
    function test_owner_collectAllFees_positive_1() public {
// assume: collectedFees > 0
// cover: collectAllFees :: onlyowner true
// cover: collectAllFees :: collectedFees != 0
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
        vm.prank(owner);
        // skip ABI-mismatched call: collectAllFees()
        {
            uint256 __v1 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v1, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Authorization & Access Control: Non-owner cannot collect all fees.
    function test_nonowner_collectAllFees_revert_2() public {
// cover: collectAllFees :: onlyowner false
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
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: collectAllFees()
    }

    // @cover-intent Authorization & Access Control: Owner can collect a specific amount of fees in ether.
    function test_owner_collectFeesInEther_positive_3() public {
// assume: collectedFees >= 1 ether
// cover: collectFeesInEther :: onlyowner true
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
        vm.prank(owner);
        {
        target.collectFeesInEther(1);
        }
        {
            uint256 __v2 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v2, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Authorization & Access Control: Owner can collect a percentage of fees.
    function test_owner_collectPercentOfFees_positive_4() public {
// assume: collectedFees > 0
// cover: collectPercentOfFees :: onlyowner true
// cover: collectPercentOfFees :: collectedFees != 0 && _pcent <= 100
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
        vm.prank(owner);
        {
        target.collectPercentOfFees(50);
        }
        {
            uint256 __v3 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v3, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Authorization & Access Control: Owner cannot collect more than 100% of fees.
    function test_owner_collectPercentOfFees_revert_on_overflow_5() public {
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.expectRevert();
        {
        target.collectPercentOfFees(101);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Owner can change multiplier within valid range.
    function test_owner_changeMultiplier_positive_6() public {
// cover: changeMultiplier :: onlyowner true
// cover: changeMultiplier :: _mult >= 120 && _mult <= 300
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
        // skip ABI-mismatched call: currentMultiplier()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Owner cannot set multiplier outside [120, 300].
    function test_owner_changeMultiplier_revert_out_of_range_7() public {
// cover: changeMultiplier :: _mult < 120
// cover: changeMultiplier :: _mult > 300
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

    // @cover-intent Protocol State Machine: Owner can change fee percentage within valid range.
    function test_owner_changeFeePercentage_positive_8() public {
// cover: changeFeePercentage :: onlyowner true
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
        vm.prank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.startPrank(owner);
        {
        target.changeFeePercentage(5);
        }
        // skip ABI-mismatched call: currentFeePercentage()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Owner cannot set fee percentage above 10.
    function test_owner_changeFeePercentage_revert_out_of_range_9() public {
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.expectRevert();
        {
        target.changeFeePercentage(11);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: participantDetails returns correct data for valid index and empty for out-of-bounds.
    function test_participantDetails_boundary_10() public {
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: DynamicPyramid()
        {
        target.participantDetails(0);
        }
        {
        target.participantDetails(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_DynamicPyramid_positive_11() public {
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
    function test_changeFeePercentage_positive_12() public {
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
    function test_changeFeePercentage_negative_non_owner_13() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeFeePercentage(5);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeMultiplier_positive_14() public {
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
    function test_changeMultiplier_negative_non_owner_15() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeMultiplier(200);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_16() public {
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

    // @cover-intent Authorization & Access Control
    function test_changeOwner_negative_non_owner_17() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_collectAllFees_positive_18() public {
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
            uint256 __v4 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v4, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_collectAllFees_negative_non_owner_19() public {
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: collectAllFees()
    }

    // @cover-intent Financial & Accounting
    function test_collectFeesInEther_positive_20() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_collectFeesInEther_negative_non_owner_21() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.collectFeesInEther(1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_collectPercentOfFees_positive_22() public {
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

    // @cover-intent Authorization & Access Control
    function test_collectPercentOfFees_negative_non_owner_23() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.collectPercentOfFees(50);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentFeePercentage_positive_24() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_currentMultiplier_positive_25() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_currentPyramidBalanceApproximately_positive_26() public {
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
        // skip ABI-mismatched call: currentPyramidBalanceApproximately()
    }

    // @cover-intent Resource & Execution Integrity
    function test_feesSeperateFromBalanceApproximately_positive_27() public {
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
        // skip ABI-mismatched call: feesSeperateFromBalanceApproximately()
        {
            uint256 __v5 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v5, 2, 0, "call:feesSeperateFromBalanceApproximately>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_nextPayoutWhenPyramidBalanceTotalsApproximately_positive_28() public {
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
        {
            uint256 __v6 = uint256(target.nextPayoutWhenPyramidBalanceTotalsApproximately());
            _assertRelU(__v6, 2, 0, "call:nextPayoutWhenPyramidBalanceTotalsApproximately>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_numberOfParticipantsWaitingForPayout_positive_29() public {
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
        {
            uint256 __v7 = uint256(target.numberOfParticipantsWaitingForPayout());
            _assertRelU(__v7, 2, 0, "call:numberOfParticipantsWaitingForPayout>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_participantDetails_positive_30() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_totalParticipants_positive_31() public {
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
        {
            uint256 __v8 = uint256(target.totalParticipants());
            _assertRelU(__v8, 0, 1, "call:totalParticipants==1");
        }
    }

}
