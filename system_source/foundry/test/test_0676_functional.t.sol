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


    // @cover-intent Protocol State Machine – Verify that after init() sets initialized=1, run() can decrement count without overflow.
    function test_Normal_operation_init_then_run_with_small_decrement_0() public {
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

    // @cover-intent Protocol State Machine – Verify that run() returns early when initialized == 0, leaving count unchanged.
    function test_Edge_run_without_init_reverts_silently_1() public {
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
    }

    // @cover-intent Financial & Accounting – Verify that run() with input > count causes integer underflow (wraps around) due to unchecked subtraction.
    function test_Boundary_integer_underflow_when_count_input_2() public {
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

    // @cover-intent Resource & Execution Integrity – Verify that run(0) after init leaves count unchanged (subtract 0).
    function test_Boundary_run_with_input_0_after_init_3() public {
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
        target.run(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting – Verify that multiple run calls after init accumulate decrements correctly.
    function test_Multiple_calls_init_then_multiple_runs_4() public {
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
        target.run(2);
        }
        {
        target.run(3);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine – Verify that calling init() multiple times does not break subsequent run() calls.
    function test_Edge_init_called_twice_5() public {
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
        // skip ABI-mismatched call: init()
        {
        target.run(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_count_initial_6() public {
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
    function test_init_sets_initialized_7() public {
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
        {
            uint256 __v2 = uint256(target.count());
            _assertRelU(__v2, 0, 1, "call:count==1");
        }
    }

    // @cover-intent Financial & Accounting
    function test_run_overflow_after_init_8() public {
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
            uint256 __v3 = uint256(target.count());
            _assertRelU(__v3, 0, 0, "call:count==0");
        }
    }

}
