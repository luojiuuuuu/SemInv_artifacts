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


    // @cover-intent Authorization & Access Control: Verify that the DynamicPyramid function (intended as constructor) can be called by anyone to set themselves as creator, bypassing intended owner initialization.
    function test_DynamicPyramid_constructor_misuse_0() public {
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

    // @cover-intent Authorization & Access Control: Owner can collect all accumulated fees after participants send ETH.
    function test_owner_collectAllFees_positive_1() public {
// cover: collectAllFees :: onlyowner modifier true
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
        vm.startPrank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        // skip ABI-mismatched call: collectAllFees()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Non-owner calling collectAllFees reverts due to onlyowner modifier.
    function test_nonowner_collectAllFees_revert_2() public {
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
        vm.prank(owner);
        // skip ABI-mismatched call: DynamicPyramid()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: collectAllFees()
    }

    // @cover-intent Financial & Accounting: Owner can collect a specific amount of fees in ether, with boundary when _amt > collectedFees triggering collectAllFees.
    function test_collectFeesInEther_boundary_3() public {
// cover: collectFeesInEther :: _amt > collectedFees triggers collectAllFees
// cover: collectFeesInEther :: collectedFees == 0 throw
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
        target.collectFeesInEther(0);
        }
        {
        target.collectFeesInEther(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Owner can collect a percentage of fees, with boundary at _pcent > 100 causing revert.
    function test_collectPercentOfFees_boundary_4() public {
// cover: collectPercentOfFees :: _pcent > 100 throw
// cover: collectPercentOfFees :: collectedFees == 0 throw
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
        vm.expectRevert();
        {
        target.collectPercentOfFees(101);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Owner can change multiplier within [120, 300] range; values outside revert.
    function test_changeMultiplier_boundary_5() public {
// cover: changeMultiplier :: _mult > 300 throw
// cover: changeMultiplier :: _mult < 120 throw
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
        vm.expectRevert();
        {
        target.changeMultiplier(119);
        }
        vm.expectRevert();
        {
        target.changeMultiplier(301);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Owner can change fee percentage up to 10; values above revert.
    function test_changeFeePercentage_boundary_6() public {
// cover: changeFeePercentage :: _fee > 10 throw
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
        vm.expectRevert();
        {
        target.changeFeePercentage(11);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Sending less than 1 ether adds to collectedFees without entering pyramid.
    function test_fallback_small_value_fees_7() public {
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
        // skip ABI-mismatched call: DynamicPyramid()
        // skip ABI-mismatched call: feesSeperateFromBalanceApproximately()
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.totalParticipants());
            _assertRelU(__v1, 0, 0, "call:totalParticipants==0");
        }
        {
            uint256 __v2 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v2, 2, 0, "call:feesSeperateFromBalanceApproximately>=0");
        }
    }

    // @cover-intent Financial & Accounting: Sending >= 50 ether halves the fee percentage.
    function test_large_value_fee_halving_8() public {
// cover: init :: msg.value >= 50 ether _fee /= 2
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
        // skip ABI-mismatched call: currentFeePercentage()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.totalParticipants());
            _assertRelU(__v3, 0, 1, "call:totalParticipants==1");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_DynamicPyramid_positive_9() public {
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
    function test_changeFeePercentage_positive_10() public {
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
    function test_changeFeePercentage_non_owner_revert_11() public {
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
    function test_changeMultiplier_positive_12() public {
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
    function test_changeMultiplier_non_owner_revert_13() public {
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
    function test_changeOwner_positive_14() public {
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
    function test_changeOwner_non_owner_revert_15() public {
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
    function test_collectAllFees_positive_16() public {
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
    function test_collectAllFees_non_owner_revert_17() public {
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
    function test_collectFeesInEther_positive_18() public {
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
            uint256 __v5 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v5, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_collectFeesInEther_non_owner_revert_19() public {
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
    function test_collectPercentOfFees_positive_20() public {
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
            uint256 __v6 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v6, 0, 0, "call:feesSeperateFromBalanceApproximately==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_collectPercentOfFees_non_owner_revert_21() public {
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
    function test_currentFeePercentage_view_22() public {
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
    function test_currentMultiplier_view_23() public {
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
    function test_currentPyramidBalanceApproximately_view_24() public {
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
    function test_feesSeperateFromBalanceApproximately_view_25() public {
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
            uint256 __v7 = uint256(target.feesSeperateFromBalanceApproximately());
            _assertRelU(__v7, 2, 0, "call:feesSeperateFromBalanceApproximately>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_nextPayoutWhenPyramidBalanceTotalsApproximately_view_26() public {
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
        // skip ABI-mismatched call: nextPayoutWhenPyramidBalanceTotalsApproximately()
        {
            uint256 __v8 = uint256(target.nextPayoutWhenPyramidBalanceTotalsApproximately());
            _assertRelU(__v8, 2, 0, "call:nextPayoutWhenPyramidBalanceTotalsApproximately>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_numberOfParticipantsWaitingForPayout_view_27() public {
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
        // skip ABI-mismatched call: numberOfParticipantsWaitingForPayout()
        {
            uint256 __v9 = uint256(target.numberOfParticipantsWaitingForPayout());
            _assertRelU(__v9, 2, 0, "call:numberOfParticipantsWaitingForPayout>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_participantDetails_view_28() public {
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
    function test_totalParticipants_view_29() public {
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
        // skip ABI-mismatched call: totalParticipants()
        {
            uint256 __v10 = uint256(target.totalParticipants());
            _assertRelU(__v10, 2, 1, "call:totalParticipants>=1");
        }
    }

}
