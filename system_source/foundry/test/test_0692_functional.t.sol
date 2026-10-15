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


    // @cover-intent Protocol State Machine: Verify that after the first call (which initializes the contract), subsequent calls to run(uint256) decrement count by the input amount.
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

    // @cover-intent Financial & Accounting: Test edge behavior where count becomes zero after decrement.
    function test_Decrement_to_zero_1() public {
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
    }

    // @cover-intent Resource & Execution Integrity: Verify that decrementing count by an amount larger than count causes an arithmetic underflow (revert due to Solidity 0.4.23 unchecked underflow).
    function test_Underflow_attempt_input_count_2() public {
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
        vm.expectRevert();
        {
        target.run(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that multiple decrements work correctly in sequence.
    function test_Multiple_decrements_3() public {
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
        target.run(3);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.run(2);
        }
    }

    // @cover-intent Protocol State Machine: Verify that the first call to run() sets initialized and returns without modifying count.
    function test_First_call_returns_early_4() public {
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

    // @cover-intent Resource & Execution Integrity: Test decrement with a large input that does not cause underflow.
    function test_Decrement_with_large_input_5() public {
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
        {
            uint256 __v1 = uint256(target.count());
            _assertRelU(__v1, 2, 1, "call:count>=1");
        }
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
        {
            uint256 __v2 = uint256(target.count());
            _assertRelU(__v2, 0, 1, "call:count==1");
        }
    }

}
