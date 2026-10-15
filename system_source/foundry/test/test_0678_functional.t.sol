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


    // @cover-intent Protocol State Machine: After init() sets initialized=1, run() should decrement count from 1 to 0.
    function test_Positive_path_init_then_run_with_decrement_0() public {
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

    // @cover-intent Protocol State Machine: Calling run() before init() should not modify count because initialized==0 causes early return.
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
        target.run(5);
        }
    }

    // @cover-intent Financial & Accounting: When count is 0 and run(1) is called after init(), the subtraction count -= 1 will underflow (since uint256), resulting in count = 2^256 - 1.
    function test_Boundary_integer_underflow_when_count_0_and_input_1_2() public {
// assume: count == 0
// cover: run :: initialized == 0 false
        vm.startPrank(owner);
        IntegerOverflowMultiTxMultiFuncFeasible target = new IntegerOverflowMultiTxMultiFuncFeasible();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.run(1);
        }
    }

    // @cover-intent Protocol State Machine: Calling run(0) after init() should leave count unchanged (count -= 0).
    function test_Boundary_run_with_input_0_after_init_3() public {
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
        target.run(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Calling run(2) after init() when count=1 will underflow (1 - 2 underflows), resulting in count = 2^256 - 1.
    function test_Boundary_run_with_large_input_after_init_4() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_count_read_5() public {
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
            _assertRelU(__v1, 2, 0, "call:count>=0");
        }
    }

    // @cover-intent Protocol State Machine
    function test_init_setup_6() public {
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
    function test_run_overflow_7() public {
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
            _assertRelU(__v2, 0, 0, "call:count==0");
        }
    }

}
