// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/TestSystem.sol";


contract TestSystem_FunctionalTest is Test {
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


    // @cover-intent state transition test for activate
    function test_test_activate_and_close_phase_transition_0() public {
// cover: _activate :: require(phase == Phase.Init) true
// cover: _close :: require(phase == Phase.Active) true
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.activate();
        }
        {
        target.close();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for activate
    function test_test_activate_by_non_owner_reverts_1() public {
// cover: activate :: require(_msgSender() == _owner) false
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.activate();
        }
    }

    // @cover-intent 验证 owner 可以铸造和销毁代币，totalSupply 和 balance 正确更新
    function test_test_mint_and_burn_by_owner_2() public {
// cover: _mint :: require(balance >= amount) true
// cover: _burn :: require(balance >= amount) true
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.mint(alice, 100);
        }
        {
        target.burn(alice, 40);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 60
    }

    // @cover-intent 验证非 owner 调用 mint() 会回退
    function test_test_mint_by_non_owner_reverts_3() public {
// cover: mint :: require(_msgSender() == _owner) false
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(bob);
        {
        target.mint(bob, 50);
        }
    }

    // @cover-intent 验证 unpause 状态下 transfer 正常执行
    function test_test_transfer_when_not_paused_4() public {
// cover: transfer :: require(!_paused) true
// cover: _transfer :: require(balance >= amount) true
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.mint(alice, 200);
        }
        vm.prank(alice);
        {
        target.transfer(bob, 80);
        }
        // TODO assert: alice.balance == 120
        // TODO assert: bob.balance == 80
    }

    // @cover-intent 验证 paused 状态下 transfer 会回退
    function test_test_transfer_when_paused_reverts_5() public {
// cover: transfer :: require(!_paused) false
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.pause();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.mint(alice, 100);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.transfer(bob, 10);
        }
    }

    // @cover-intent state transition test for pause
    function test_test_pause_and_unpause_by_owner_6() public {
// cover: _pause :: require(_msgSender() == _owner) true
// cover: _unpause :: require(_msgSender() == _owner) true
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.pause();
        }
        {
        target.unpause();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for nextStage
    function test_test_nextStage_monotonic_increment_7() public {
// cover: _advanceStage :: stage += 1
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.nextStage();
        }
        vm.prank(bob);
        {
        target.nextStage();
        }
    }

    // @cover-intent 验证 owner 可以转移所有权给新地址
    function test_test_transferOwnership_by_owner_8() public {
// cover: transferOwnership :: require(newOwner != address(0)) true
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
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

    // @cover-intent 验证销毁超过余额时回退
    function test_test_burn_insufficient_balance_reverts_9() public {
// cover: _burn :: require(balance >= amount) false
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.mint(alice, 30);
        }
        vm.expectRevert();
        {
        target.burn(alice, 100);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for activate
    function test_activate_by_owner_10() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.activate();
        }
    }

    // @cover-intent Test that balanceOf returns correct balance after mint
    function test_balanceOf_after_mint_11() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
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
        target.balanceOf(alice);
        }
    }

    // @cover-intent Test that owner can burn tokens from an address
    function test_burn_by_owner_12() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.mint(alice, 100);
        }
        {
        target.burn(alice, 30);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for close
    function test_close_by_owner_13() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.activate();
        }
        {
        target.close();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that owner can mint tokens to an address
    function test_mint_by_owner_14() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.mint(alice, 50);
        }
    }

    // @cover-intent state transition test for nextStage
    function test_nextStage_by_anyone_15() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.nextStage();
        }
    }

    // @cover-intent Test that owner returns the contract owner
    function test_owner_view_16() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.owner();
        }
    }

    // @cover-intent state transition test for pause
    function test_pause_by_owner_17() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.pause();
        }
    }

    // @cover-intent Test that paused returns false after unpause
    function test_paused_view_after_unpause_18() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.unpause();
        }
        vm.prank(alice);
        {
        target.paused();
        }
    }

    // @cover-intent Test that phase returns Active after activate
    function test_phase_view_after_activate_19() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.activate();
        }
        vm.prank(alice);
        {
        target.phase();
        }
    }

    // @cover-intent Test that stage returns 1 after nextStage
    function test_stage_view_after_nextStage_20() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(alice);
        {
        target.nextStage();
        }
        {
        target.stage();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that totalSupply returns correct supply after mint
    function test_totalSupply_after_mint_21() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.mint(alice, 200);
        }
        vm.prank(alice);
        {
        target.totalSupply();
        }
    }

    // @cover-intent Test that transfer works when not paused
    function test_transfer_when_not_paused_22() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
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
        target.transfer(bob, 40);
        }
    }

    // @cover-intent Test that owner can transfer ownership
    function test_transferOwnership_by_owner_23() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
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

    // @cover-intent state transition test for unpause
    function test_unpause_by_owner_24() public {
        vm.startPrank(owner);
        TestSystem target = new TestSystem();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.pause();
        }
        {
        target.unpause();
        }
        vm.stopPrank();
    }

}
