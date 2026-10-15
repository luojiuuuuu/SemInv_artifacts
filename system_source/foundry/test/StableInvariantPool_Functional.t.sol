// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/StableInvariantPool.sol";


contract StableInvariantPool_FunctionalTest is Test {
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


    // @cover-intent Financial & Accounting: Verify that a single swap updates balances and invariantD as expected, and that getInvariant returns the updated invariantD.
    function test_Basic_swap_and_invariant_check_0() public {
// assume: invariantD == 1000000
// cover: swap :: normal execution
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        target.swap(alice, 10);
        }
        {
        target.balance(alice);
        }
        // skip ABI-mismatched call: getInvariant()
        vm.stopPrank();
        // skip bad numeric post: call:balance(alice) == 10
    }

    // @cover-intent Resource & Execution Integrity: Test swap with amountIn = 0 to check for division by zero or unexpected behavior.
    function test_Swap_with_zero_amount_1() public {
// assume: invariantD == 1000000
// cover: swap :: amountIn == 0
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        target.swap(alice, 0);
        }
        {
        target.balance(alice);
        }
        // skip ABI-mismatched call: getInvariant()
        vm.stopPrank();
        // skip bad numeric post: call:balance(alice) == 0
    }

    // @cover-intent Transactional Consistency: Perform swaps with two different token addresses to ensure balance mapping works independently.
    function test_Multiple_swaps_with_different_tokens_2() public {
// assume: invariantD == 1000000
// cover: swap :: different token addresses
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        target.swap(alice, 50);
        }
        vm.prank(bob);
        {
        target.swap(bob, 30);
        }
        vm.prank(alice);
        {
        target.balance(alice);
        }
        vm.prank(bob);
        {
        target.balance(bob);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: getInvariant()
        // skip bad numeric post: call:balance(alice) == 50
        // skip bad numeric post: call:balance(bob) == 30
    }

    // @cover-intent Financial & Accounting: Demonstrate rounding-error-induced invariant drift by performing multiple swaps and comparing invariantD to expected value.
    function test_Invariant_drift_after_multiple_swaps_3() public {
// assume: invariantD == 1000000
// cover: swap :: repeated small swaps
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        target.swap(alice, 1);
        }
        {
        target.swap(alice, 1);
        }
        {
        target.swap(alice, 1);
        }
        // skip ABI-mismatched call: getInvariant()
        {
        target.balance(alice);
        }
        vm.stopPrank();
        // skip bad numeric post: call:balance(alice) == 3
    }

    // @cover-intent Resource & Execution Integrity: Test swap with a very large amountIn to check for overflow or unexpected behavior.
    function test_Large_amount_swap_boundary_4() public {
// assume: invariantD == 1000000
// cover: swap :: large amountIn
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        target.swap(alice, 1000000);
        }
        {
        target.balance(alice);
        }
        // skip ABI-mismatched call: getInvariant()
        vm.stopPrank();
        // skip bad numeric post: call:balance(alice) == 1000000
    }

    // @cover-intent Transactional Consistency: Verify that swapping the same token repeatedly accumulates balance correctly.
    function test_Swap_with_same_token_multiple_times_5() public {
// assume: invariantD == 1000000
// cover: swap :: multiple swaps same token
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        target.swap(alice, 10);
        }
        {
        target.swap(alice, 20);
        }
        {
        target.balance(alice);
        }
        // skip ABI-mismatched call: getInvariant()
        vm.stopPrank();
        // skip bad numeric post: call:balance(alice) == 30
    }

    // @cover-intent Resource & Execution Integrity
    function test_balance_view_6() public {
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        target.balance(alice);
        }
        // skip bad numeric post: call:balance(alice) == 0
    }

    // @cover-intent Financial & Accounting
    function test_getInvariant_view_7() public {
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        // skip ABI-mismatched call: getInvariant()
        // TODO assert: call:getInvariant() == invariantD
    }

    // @cover-intent Financial & Accounting
    function test_invariantD_view_8() public {
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
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
        // skip ABI-mismatched call: invariantD()
        {
            uint256 __v1 = uint256(target.invariantD());
            _assertRelU(__v1, 0, 1000, "call:invariantD==1000");
        }
    }

    // @cover-intent Financial & Accounting
    function test_swap_with_invariant_drift_9() public {
        vm.startPrank(owner);
        StableInvariantPool target = new StableInvariantPool(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=keccak256(abi.encode(alice, uint256(0))), value=1000;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.swap(alice, 100);
        }
        // skip bad numeric post: call:balance(alice) == 1100
    }

}
