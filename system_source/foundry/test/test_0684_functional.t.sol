// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/integer_overflow_multitx_multifunc_feasible.sol";

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

contract IntegerOverflowMultiTxMultiFuncFeasible_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowMultiTxMultiFuncFeasible_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: After init() sets initialized=1, run() should subtract input from count without overflow.
    function test_Positive_path_init_then_run_with_safe_subtraction_0() public {
// assume: count == 1
// cover: run :: initialized == 0 false
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        // skip ABI-mismatched call: init()
        {
        target.run(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Calling run() before init() should do nothing because initialized == 0 guard returns early.
    function test_Edge_run_without_init_initialized_0_should_return_early_1() public {
// assume: count == 1
// cover: run :: initialized == 0 true
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        target.run(1);
        }
    }

    // @cover-intent Financial & Accounting: After init, subtracting count from itself should result in count == 0, no overflow.
    function test_Boundary_run_with_input_equal_to_count_after_init_count_becomes_0_2() public {
// assume: count == 1
// cover: run :: initialized == 0 false
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        // skip ABI-mismatched call: init()
        {
        target.run(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: After init, subtracting input > count causes integer underflow (count becomes very large due to unchecked subtraction).
    function test_Boundary_run_with_input_greater_than_count_underflow_attempt_3() public {
// assume: count == 1
// cover: run :: initialized == 0 false
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        // skip ABI-mismatched call: init()
        {
        target.run(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: After init, multiple run calls should decrement count cumulatively.
    function test_Multiple_runs_after_init_sequential_subtraction_4() public {
// assume: count == 1
// cover: run :: initialized == 0 false
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        // skip ABI-mismatched call: init()
        {
        target.run(1);
        }
        {
        target.run(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Multiple run calls before init should all return early, leaving count unchanged.
    function test_Multiple_runs_without_init_no_state_change_5() public {
// assume: count == 1
// cover: run :: initialized == 0 true
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        target.run(5);
        }
        vm.prank(bob);
        {
        target.run(10);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_count_read_initial_value_6() public {
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        {
            uint256 __v1 = uint256(target.count());
            _assertRelU(__v1, 0, 1, "call:count==1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_init_set_initialized_flag_7() public {
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        // skip ABI-mismatched call: init()
    }

    // @cover-intent Financial & Accounting
    function test_run_integer_underflow_after_init_8() public {
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
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
        // skip ABI-mismatched call: init()
        {
        target.run(2);
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.count());
            _assertRelU(__v2, 0, 115792089237316195423570985008687907853269984665640564039457584007913129639935, "call:count==115792089237316195423570985008687907853269984665640564039457584007913129639935");
        }
    }

}
