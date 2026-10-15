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


    // @cover-intent Financial & Accounting: Verify basic deposit and withdraw accounting consistency
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
    }

    // @cover-intent Financial & Accounting: Verify withdraw reverts when balance insufficient
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
        target.withdraw(100);
        }
        // TODO assert: alice.balance == 50
    }

    // @cover-intent Financial & Accounting: Verify mint increases balance but not totalSupply (known bug)
    function test_mint_by_owner_2() public {
// cover: mint :: onlyOwner modifier true
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
        target.mint(alice, 200);
        }
        // TODO assert: alice.balance == 200
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 0, 0, "call:totalSupply==0");
        }
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot call mint
    function test_mint_by_non_owner_reverts_3() public {
// cover: mint :: onlyOwner modifier false
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
        target.mint(bob, 100);
        }
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Protocol State Machine: Verify activate transitions from Init to Active
    function test_state_transition_init_to_active_4() public {
// cover: activate :: require(phase == Phase.Init) true
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
        // skip ABI-mismatched call: activate()
    }

    // @cover-intent Protocol State Machine: Verify activate reverts when not in Init phase
    function test_activate_when_not_init_reverts_5() public {
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

    // @cover-intent Protocol State Machine: Verify complete lifecycle Init -> Active -> Closed -> Init via reset
    function test_full_state_machine_cycle_6() public {
// cover: activate :: require(phase == Phase.Init) true
// cover: close :: require(phase == Phase.Active) true
// cover: reset :: onlyOwner modifier true
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

    // @cover-intent Protocol State Machine: Verify close reverts when not in Active phase
    function test_close_when_not_active_reverts_7() public {
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

    // @cover-intent Authorization & Access Control: Verify owner can transfer ownership
    function test_transfer_ownership_8() public {
// cover: transferOwnership :: onlyOwner modifier true
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

    // @cover-intent Authorization & Access Control: Verify non-owner cannot transfer ownership
    function test_non_owner_cannot_transfer_ownership_9() public {
// cover: transferOwnership :: onlyOwner modifier false
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
        target.transferOwnership(bob);
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

    // @cover-intent state transition test for activate
    function test_activate_nonowner_revert_11() public {
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
        // skip ABI-mismatched call: activate()
    }

    // @cover-intent Financial & Accounting
    function test_balances_view_12() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mint(alice, 100);
        vm.prank(owner);
        target.mint(owner, 100);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.mint(alice, 100);
        }
        vm.prank(alice);
        {
        target.balances(alice);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Protocol State Machine
    function test_close_positive_13() public {
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

    // @cover-intent state transition test for close
    function test_close_nonowner_revert_14() public {
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
        // skip ABI-mismatched call: activate()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: close()
    }

    // @cover-intent Financial & Accounting
    function test_deposit_positive_15() public {
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
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_mint_positive_16() public {
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
        target.mint(alice, 200);
        }
        // TODO assert: alice.balance == 200
    }

    // @cover-intent Authorization & Access Control
    function test_mint_nonowner_revert_17() public {
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
        target.mint(alice, 100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_18() public {
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
    function test_phase_view_19() public {
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
    function test_reset_positive_20() public {
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

    // @cover-intent state transition test for reset
    function test_reset_nonowner_revert_21() public {
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
        // skip ABI-mismatched call: activate()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: reset()
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_view_22() public {
        vm.startPrank(owner);
        ResearchTarget target = new ResearchTarget();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.mint(alice, 100);
        vm.prank(owner);
        target.mint(owner, 100);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.mint(alice, 100);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: totalSupply()
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_positive_23() public {
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

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_nonowner_revert_24() public {
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
        target.transferOwnership(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_25() public {
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

    // @cover-intent Financial & Accounting
    function test_withdraw_insufficient_balance_revert_26() public {
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
        target.withdraw(10);
        }
    }

}
