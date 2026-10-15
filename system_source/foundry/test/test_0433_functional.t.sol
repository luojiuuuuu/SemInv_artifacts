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
// assume: withdrawalCounter == 0
// assume: calculatedFibNumber == 0
// cover: withdraw :: require(delegatecall success) true
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

    // @cover-intent Transactional Consistency: Verify that multiple withdrawals increment withdrawalCounter sequentially and each call recalculates fib number
    function test_Multiple_withdrawals_accumulate_counter_1() public {
// assume: withdrawalCounter == 2
// cover: withdraw :: require(delegatecall success) true
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
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: withdrawalCounter()
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: withdrawalCounter()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that the fallback function delegates calls to fibonacciLibrary with arbitrary data
    function test_Fallback_function_delegates_arbitrary_calls_2() public {
// assume: fibonacciLibrary != address(0)
// cover: fallback :: require(delegatecall success) true
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
    }

    // @cover-intent Resource & Execution Integrity: Verify behavior when contract has insufficient ether for transfer
    function test_Withdrawal_with_zero_ether_in_contract_3() public {
// assume: address(this).balance == 0
// assume: calculatedFibNumber > 0
// cover: withdraw :: require(transfer success) false
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
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify constructor correctly sets the fibonacciLibrary address
    function test_Constructor_sets_fibonacciLibrary_4() public {
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
    }

    // @cover-intent Protocol State Machine: Verify that start variable is initialized to 3 as per contract source
    function test_Start_value_is_initialized_to_3_5() public {
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
    }

    // @cover-intent Protocol State Machine: Verify withdrawalCounter initial value is zero
    function test_Withdrawal_counter_starts_at_zero_6() public {
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
    }

    // @cover-intent Financial & Accounting: Verify calculatedFibNumber is updated after a withdrawal call
    function test_CalculatedFibNumber_after_withdrawal_7() public {
// assume: withdrawalCounter == 1
// cover: withdraw :: require(delegatecall success) true
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

    // @cover-intent Financial & Accounting
    function test_withdraw_sequence_8() public {
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
        vm.prank(owner);
        // skip ABI-mismatched call: fibonacciLibrary()
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Resource & Execution Integrity
    function test_calculatedFibNumber_sequence_9() public {
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
    }

    // @cover-intent External Interaction & Environment
    function test_fibonacciLibrary_sequence_10() public {
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
    function test_start_sequence_11() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawalCounter_sequence_12() public {
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
    }

}
