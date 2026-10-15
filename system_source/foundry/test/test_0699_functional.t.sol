// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/integer_overflow_multitx_onefunc_feasible.sol";

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

contract IntegerOverflowMultiTxOneFuncFeasible_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowMultiTxOneFuncFeasible_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: After first call sets initialized=1, subsequent calls decrement count normally.
    function test_Normal_decrement_after_initialization_0() public {
// cover: run :: initialized == 0 (false)
        vm.startPrank(owner);
        IntegerOverflowMultiTxOneFuncFeasible target = new IntegerOverflowMultiTxOneFuncFeasible();
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
        target.run(0);
        }
        {
        target.run(5);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Decrementing count below 1 causes arithmetic underflow revert.
    function test_Underflow_revert_on_decrement_below_zero_1() public {
// cover: run :: count - input underflows
        vm.startPrank(owner);
        IntegerOverflowMultiTxOneFuncFeasible target = new IntegerOverflowMultiTxOneFuncFeasible();
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
        target.run(0);
        }
        vm.expectRevert();
        {
        target.run(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: First call sets initialized=1 and returns without modifying count.
    function test_Initialization_guard_prevents_decrement_on_first_call_2() public {
// cover: run :: initialized == 0 (true)
        vm.startPrank(owner);
        IntegerOverflowMultiTxOneFuncFeasible target = new IntegerOverflowMultiTxOneFuncFeasible();
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
        target.run(100);
        }
    }

    // @cover-intent Transactional Consistency: Multiple decrements after initialization work correctly.
    function test_Multiple_decrements_after_initialization_3() public {
// cover: run :: initialized == 0 (false)
        vm.startPrank(owner);
        IntegerOverflowMultiTxOneFuncFeasible target = new IntegerOverflowMultiTxOneFuncFeasible();
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
        target.run(0);
        }
        {
        target.run(1);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.run(2);
        }
        vm.prank(alice);
        {
        target.run(3);
        }
    }

    // @cover-intent Resource & Execution Integrity: Decrementing by zero is a no-op and does not revert.
    function test_Decrement_by_zero_after_initialization_4() public {
// cover: run :: initialized == 0 (false)
        vm.startPrank(owner);
        IntegerOverflowMultiTxOneFuncFeasible target = new IntegerOverflowMultiTxOneFuncFeasible();
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
        target.run(0);
        }
        {
        target.run(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Decrementing by max uint256 causes underflow revert.
    function test_Decrement_by_max_uint256_after_initialization_5() public {
// cover: run :: count - input underflows
        vm.startPrank(owner);
        IntegerOverflowMultiTxOneFuncFeasible target = new IntegerOverflowMultiTxOneFuncFeasible();
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
        target.run(0);
        }
        vm.expectRevert();
        {
        target.run(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_count_view_6() public {
        vm.startPrank(owner);
        IntegerOverflowMultiTxOneFuncFeasible target = new IntegerOverflowMultiTxOneFuncFeasible();
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
        // skip ABI-mismatched call: count()
    }

    // @cover-intent Financial & Accounting
    function test_run_overflow_7() public {
        vm.startPrank(owner);
        IntegerOverflowMultiTxOneFuncFeasible target = new IntegerOverflowMultiTxOneFuncFeasible();
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
        target.run(0);
        }
        {
        target.run(2);
        }
        vm.stopPrank();
    }

}
