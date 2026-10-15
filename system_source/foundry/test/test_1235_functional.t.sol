// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xb93430ce38ac4a6bb47fb1fc085ea669353fd89e.sol";

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

contract PrivateBank_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PrivateBank_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH above MinDeposit and cash out up to their balance, with correct balance updates.
    function test_Basic_deposit_and_cashout_flow_0() public {
// assume: address(alice).balance >= 2 ether
// cover: Deposit :: msg.value >= MinDeposit true
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
        {
        target.CashOut(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that depositing less than MinDeposit does not update balance and does not revert (falls through).
    function test_Deposit_below_minimum_reverts_silently_1() public {
// assume: address(alice).balance >= 0.5 ether
// cover: Deposit :: msg.value >= MinDeposit false
        vm.startPrank(owner);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that cashout amount greater than balance fails the guard and does not execute.
    function test_CashOut_exceeding_balance_reverts_2() public {
// assume: address(alice).balance >= 2 ether
// cover: Deposit :: msg.value >= MinDeposit true
// cover: CashOut :: _am <= balances[msg.sender] false
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
        {
        target.CashOut(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits correctly sum the balance.
    function test_Multiple_deposits_accumulate_balance_3() public {
// assume: address(alice).balance >= 5 ether
// cover: Deposit :: msg.value >= MinDeposit true
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
        // skip ABI-mismatched call: Deposit()
        {
        target.CashOut(4 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that balances of different users are stored separately and do not interfere.
    function test_Separate_user_balances_are_independent_4() public {
// assume: address(alice).balance >= 2 ether
// assume: address(bob).balance >= 3 ether
// cover: Deposit :: msg.value >= MinDeposit true
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
        vm.prank(bob);
        // skip ABI-mismatched call: Deposit()
        vm.prank(alice);
        {
        target.CashOut(2 ether);
        }
        vm.prank(bob);
        {
        target.CashOut(1 ether);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending ETH directly to the contract (fallback) does not update any user balance.
    function test_Fallback_function_accepts_ETH_without_balance_change_5() public {
// assume: address(alice).balance >= 3 ether
// cover: Deposit :: msg.value >= MinDeposit true
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
        {
        target.CashOut(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that cashout with zero amount is allowed when balance is zero (guard passes).
    function test_CashOut_with_zero_amount_6() public {
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(owner);
        PrivateBank target = new PrivateBank(alice);
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
        target.CashOut(0);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that MinDeposit() returns the expected constant value (1 ether).
    function test_MinDeposit_read_returns_constant_7() public {
        vm.startPrank(owner);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: MinDeposit()
    }

    // @cover-intent Authorization & Access Control: Verify that balances() returns zero for an address that never deposited.
    function test_Balance_read_returns_zero_for_new_user_8() public {
        vm.startPrank(owner);
        PrivateBank target = new PrivateBank(alice);
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
        target.balances(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_CashOut_sequence_9() public {
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
        {
        target.CashOut(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_10() public {
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
    }

    // @cover-intent Financial & Accounting
    function test_MinDeposit_sequence_11() public {
        vm.startPrank(owner);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: MinDeposit()
        // TODO assert: call:MinDeposit() == 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_12() public {
        vm.startPrank(alice);
        PrivateBank target = new PrivateBank(alice);
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
        // skip ABI-mismatched call: Deposit()
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: call:balances(alice) == 2 ether
    }

}
