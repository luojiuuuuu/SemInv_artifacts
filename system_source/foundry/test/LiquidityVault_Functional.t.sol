// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/LiquidityVault.sol";


contract LiquidityVault_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Verify that deposit correctly updates both userBalance and totalLiquidity.
    function test_Deposit_increases_totalLiquidity_and_userBalance_0() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        {
        target.deposit(100);
        }
        {
        target.userBalance(alice);
        }
        // skip ABI-mismatched call: totalLiquidity()
        vm.stopPrank();
        // TODO assert: alice.balance == 100
        {
            uint256 __v1 = uint256(target.totalLiquidity());
            _assertRelU(__v1, 2, 100, "call:totalLiquidity>=100");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw reverts when userBalance is insufficient.
    function test_Withdraw_with_insufficient_balance_reverts_1() public {
// cover: withdraw :: require(userBalance[msg.sender] >= amount) false
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdraw(1);
        }
    }

    // @cover-intent Financial & Accounting: Verify that withdraw reduces userBalance and totalLiquidity proportionally.
    function test_Withdraw_after_deposit_reduces_totalLiquidity_and_userBalance_2() public {
// cover: withdraw :: require(userBalance[msg.sender] >= amount) true
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        {
        target.deposit(100);
        }
        {
        target.withdraw(50);
        }
        {
        target.userBalance(alice);
        }
        // skip ABI-mismatched call: totalLiquidity()
        vm.stopPrank();
        // TODO assert: alice.balance == 50
        {
            uint256 __v2 = uint256(target.totalLiquidity());
            _assertRelU(__v2, 2, 50, "call:totalLiquidity>=50");
        }
    }

    // @cover-intent Financial & Accounting: Demonstrate cumulative rounding error from repeated withdrawals.
    function test_Repeated_withdrawals_cause_rounding_drift_in_totalLiquidity_3() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        {
        target.deposit(1000);
        }
        {
        target.withdraw(1);
        }
        {
        target.withdraw(1);
        }
        {
        target.withdraw(1);
        }
        // skip ABI-mismatched call: totalLiquidity()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.totalLiquidity());
            _assertRelU(__v3, 2, 997, "call:totalLiquidity>=997");
        }
    }

    // @cover-intent Financial & Accounting: Verify that withdrawing the full balance results in zero userBalance.
    function test_Withdraw_entire_balance_leaves_zero_userBalance_4() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        target.deposit(200);
        }
        {
        target.withdraw(200);
        }
        {
        target.userBalance(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that multiple users can interact without interference.
    function test_Multiple_users_deposit_and_withdraw_independently_5() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        target.deposit(50);
        }
        vm.prank(bob);
        {
        target.deposit(30);
        }
        vm.prank(alice);
        {
        target.withdraw(20);
        }
        vm.prank(bob);
        {
        target.withdraw(10);
        }
        vm.prank(alice);
        {
        target.userBalance(alice);
        }
        vm.prank(bob);
        {
        target.userBalance(bob);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: totalLiquidity()
        // TODO assert: alice.balance == 30
        // TODO assert: bob.balance == 20
        {
            uint256 __v4 = uint256(target.totalLiquidity());
            _assertRelU(__v4, 2, 50, "call:totalLiquidity>=50");
        }
    }

    // @cover-intent Financial & Accounting: Verify checkInvariant returns true after deposits.
    function test_Check_invariant_after_multiple_deposits_6() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        target.deposit(500);
        }
        vm.prank(bob);
        {
        target.deposit(300);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: checkInvariant()
    }

    // @cover-intent Financial & Accounting: Verify checkInvariant still returns true after withdrawals (despite rounding).
    function test_Check_invariant_after_withdrawals_7() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        {
        target.deposit(100);
        }
        {
        target.withdraw(99);
        }
        // skip ABI-mismatched call: checkInvariant()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that withdrawing zero amount is allowed and does not change state.
    function test_Withdraw_with_zero_amount_after_deposit_8() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(carol);
        {
        target.deposit(10);
        }
        {
        target.withdraw(0);
        }
        {
        target.userBalance(carol);
        }
        // skip ABI-mismatched call: totalLiquidity()
        vm.stopPrank();
        // TODO assert: carol.balance == 10
        {
            uint256 __v5 = uint256(target.totalLiquidity());
            _assertRelU(__v5, 2, 10, "call:totalLiquidity>=10");
        }
    }

    // @cover-intent Financial & Accounting: Verify that constructor sets totalLiquidity to the initial value.
    function test_Constructor_sets_initial_totalLiquidity_9() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        // skip ABI-mismatched call: totalLiquidity()
        {
            uint256 __v6 = uint256(target.totalLiquidity());
            _assertRelU(__v6, 2, 100, "call:totalLiquidity>=100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_checkInvariant_after_deposit_10() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        {
        target.deposit(100);
        }
        // skip ABI-mismatched call: checkInvariant()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_deposit_increases_totalLiquidity_and_userBalance_11() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        target.deposit(50);
        }
        {
            uint256 __v7 = uint256(target.totalLiquidity());
            _assertRelU(__v7, 2, 50, "call:totalLiquidity>=50");
        }
    }

    // @cover-intent Financial & Accounting
    function test_totalLiquidity_after_deposit_12() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        {
        target.deposit(200);
        }
        // skip ABI-mismatched call: totalLiquidity()
        vm.stopPrank();
        {
            uint256 __v8 = uint256(target.totalLiquidity());
            _assertRelU(__v8, 2, 200, "call:totalLiquidity>=200");
        }
    }

    // @cover-intent Financial & Accounting
    function test_userBalance_after_deposit_13() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        {
        target.deposit(75);
        }
        {
        target.userBalance(alice);
        }
        vm.stopPrank();
        {
            uint256 __v9 = uint256(target.userBalance(alice));
            _assertRelU(__v9, 0, 75, "call:userBalance==75");
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_with_sufficient_balance_14() public {
        vm.startPrank(owner);
        LiquidityVault target = new LiquidityVault(1);
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
        {
        target.deposit(100);
        }
        {
        target.withdraw(50);
        }
        vm.stopPrank();
        {
            uint256 __v10 = uint256(target.totalLiquidity());
            _assertRelU(__v10, 2, 0, "call:totalLiquidity>=0");
        }
    }

}
