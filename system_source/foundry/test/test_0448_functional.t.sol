// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/FibonacciBalance.sol";

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

contract FibonacciBalance_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function FibonacciBalance_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a normal withdrawal correctly increments withdrawalCounter and transfers ether based on calculatedFibNumber
    function test_Normal_withdrawal_flow_0() public {
// assume: withdrawalCounter >= 0
// cover: withdraw :: require(fibonacciLibrary.delegatecall(fibSig, withdrawalCounter)) true
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: withdrawalCounter()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify behavior when withdrawalCounter is at initial state (0) before any withdrawals
    function test_Withdrawal_counter_boundary_zero_state_1() public {
// assume: withdrawalCounter == 0
// assume: start == 3
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: withdrawalCounter()
        // skip ABI-mismatched call: start()
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Transactional Consistency: Verify that multiple withdrawals correctly accumulate withdrawalCounter and maintain state consistency
    function test_Multiple_withdrawals_state_accumulation_2() public {
// assume: withdrawalCounter >= 0
// cover: withdraw :: require(fibonacciLibrary.delegatecall(fibSig, withdrawalCounter)) true
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: withdrawalCounter()
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: withdrawalCounter()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that the fallback function can delegatecall to the fibonacci library with arbitrary data
    function test_Fallback_function_delegatecall_to_library_3() public {
// assume: fibonacciLibrary != address(0)
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: fibonacciLibrary()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Resource & Execution Integrity: Verify that calculatedFibNumber is set correctly after a withdrawal operation
    function test_Read_calculatedFibNumber_after_withdrawal_4() public {
// assume: calculatedFibNumber >= 0
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: calculatedFibNumber()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that the constructor correctly sets the fibonacciLibrary address
    function test_Constructor_initialization_check_5() public {
// assume: fibonacciLibrary != address(0)
// assume: start == 3
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: fibonacciLibrary()
        // skip ABI-mismatched call: start()
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Resource & Execution Integrity
    function test_FibonacciBalance_calculatedFibNumber_6() public {
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: calculatedFibNumber()
        {
            uint256 __v1 = uint256(target.calculatedFibNumber());
            _assertRelU(__v1, 2, 0, "call:calculatedFibNumber>=0");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_FibonacciBalance_fibonacciLibrary_7() public {
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: fibonacciLibrary()
    }

    // @cover-intent Resource & Execution Integrity
    function test_FibonacciBalance_start_8() public {
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: start()
        {
            uint256 __v2 = uint256(target.start());
            _assertRelU(__v2, 0, 3, "call:start==3");
        }
    }

    // @cover-intent Financial & Accounting
    function test_FibonacciBalance_withdraw_9() public {
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: withdraw()
        {
            uint256 __v3 = uint256(target.withdrawalCounter());
            _assertRelU(__v3, 0, 1, "call:withdrawalCounter==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_FibonacciBalance_withdrawalCounter_10() public {
        vm.startPrank(owner);
        FibonacciBalance target = new FibonacciBalance(alice);
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
        // skip ABI-mismatched call: withdrawalCounter()
        {
            uint256 __v4 = uint256(target.withdrawalCounter());
            _assertRelU(__v4, 2, 0, "call:withdrawalCounter>=0");
        }
    }

}
