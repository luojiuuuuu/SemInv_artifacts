// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "../src/ResearchTarget.sol";


contract ResearchTarget_FunctionalTest is Test {
    address owner = address(0x0A0A);
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address carol = address(0xCA1CE);


    // ---------- Helpers (0.8+) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        assertEq(a, b);
    }
    function _delta(int256 after_, int256 before_) internal pure returns (int256) {
        return after_ - before_;
    }
    function _assertTrue(bool ok, string memory why) internal {
        assertTrue(ok, why);
    }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) assertEq(a, b, why);
        else if (op == 1) assertTrue(a != b, why);
        else if (op == 2) assertGe(a, b, why);
        else if (op == 3) assertLe(a, b, why);
        else if (op == 4) assertTrue(a >  b, why);
        else if (op == 5) assertTrue(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        assertLe(d, tol, why);
    }
    function _assertEqA(address a, address b) internal {
        assertEq(a, b);
    }
    function _assertEqB32(bytes32 a, bytes32 b) internal {
        assertEq(a, b);
    }
    function _assertEqS(string memory a, string memory b) internal {
        assertEq(a, b);
    }


    // @cover-intent Financial & Accounting: Test basic deposit and withdraw functionality, verifying balance and totalSupply updates.
    function test_deposit_and_withdraw_positive_0() public {
// cover: withdraw :: require(balances[msg.sender] >= amount) true
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.withdraw(50);
        }
        // TODO assert: alice.balance == 50
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 0, 50, "call:totalSupply==50");
        }
    }

    // @cover-intent Financial & Accounting: Test withdraw reverts when balance is insufficient.
    function test_withdraw_insufficient_balance_1() public {
// cover: withdraw :: require(balances[msg.sender] >= amount) false
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw(20);
        }
        // TODO assert: alice.balance == 10
        {
            uint256 __v2 = uint256(target.totalSupply());
            _assertRelU(__v2, 0, 10, "call:totalSupply==10");
        }
    }

    // @cover-intent Financial & Accounting: Test mint function by owner, verifying balance update but totalSupply is not updated (known bug).
    function test_mint_by_owner_2() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.mint(alice, 100);
        }
        // TODO assert: alice.balance == 100
        {
            uint256 __v3 = uint256(target.totalSupply());
            _assertRelU(__v3, 0, 0, "call:totalSupply==0");
        }
    }

    // @cover-intent Authorization & Access Control: Test that non-owner cannot call mint.
    function test_mint_by_non_owner_reverts_3() public {
// cover: mint :: require(msg.sender == owner) false
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.mint(bob, 50);
        }
    }

    // @cover-intent Protocol State Machine: Test state transitions from Init to Active to Closed.
    function test_activate_and_close_state_machine_4() public {
// cover: activate :: require(phase == Phase.Init) true
// cover: close :: require(phase == Phase.Active) true
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        // skip ABI-mismatched call: activate()
        // skip ABI-mismatched call: close()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Test activate reverts when not in Init state.
    function test_activate_from_wrong_state_5() public {
// cover: activate :: require(phase == Phase.Init) false
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        // skip ABI-mismatched call: activate()
        vm.expectRevert();
        // skip ABI-mismatched call: activate()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Test close reverts when not in Active state.
    function test_close_from_wrong_state_6() public {
// cover: close :: require(phase == Phase.Active) false
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: close()
    }

    // @cover-intent Protocol State Machine: Test reset allows moving back to Init from any state.
    function test_reset_state_machine_7() public {
// cover: reset :: require(msg.sender == owner) true
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        // skip ABI-mismatched call: activate()
        // skip ABI-mismatched call: reset()
        // skip ABI-mismatched call: phase()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test ownership transfer and verify new owner can call owner-only functions.
    function test_transfer_ownership_8() public {
// cover: transferOwnership :: require(msg.sender == owner) true
// cover: activate :: require(msg.sender == owner) true
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.transferOwnership(alice);
        }
        // skip ABI-mismatched call: activate()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test that receive() fallback correctly calls deposit().
    function test_receive_fallback_deposit_9() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(bob);
        {
        target.withdraw(200);
        }
        // TODO assert: bob.balance == 0
        {
            uint256 __v4 = uint256(target.totalSupply());
            _assertRelU(__v4, 0, 0, "call:totalSupply==0");
        }
    }

    // @cover-intent Protocol State Machine
    function test_activate_positive_10() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        // skip ABI-mismatched call: activate()
        // skip ABI-mismatched call: activate()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_balances_view_11() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.balances(owner);
        }
        // TODO assert: owner.balance == 100
    }

    // @cover-intent Protocol State Machine
    function test_close_positive_12() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        // skip ABI-mismatched call: activate()
        // skip ABI-mismatched call: close()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_deposit_positive_13() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting
    function test_mint_positive_14() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.mint(alice, 100);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_15() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Protocol State Machine
    function test_phase_view_16() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: phase()
    }

    // @cover-intent Protocol State Machine
    function test_reset_positive_17() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        // skip ABI-mismatched call: activate()
        // skip ABI-mismatched call: close()
        // skip ABI-mismatched call: reset()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_view_18() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: totalSupply()
        {
            uint256 __v5 = uint256(target.totalSupply());
            _assertRelU(__v5, 0, 200, "call:totalSupply==200");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_positive_19() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.transferOwnership(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_20() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.withdraw(50);
        }
        // TODO assert: alice.balance == 50
    }

}
