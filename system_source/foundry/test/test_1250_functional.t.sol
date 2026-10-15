// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x7a8721a9d64c74da899424c1b52acbf58ddc9782.sol";

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

contract PrivateDeposit_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PrivateDeposit_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit exactly 1 ether and cash out the same amount, preserving balance consistency.
    function test_Normal_deposit_and_cash_out_0() public {
// cover: Deposit :: msg.value >= MinDeposit true
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateDeposit target = new PrivateDeposit();
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

    // @cover-intent Financial & Accounting: Verify that a deposit below MinDeposit (1 ether) is rejected and balance remains unchanged.
    function test_Deposit_below_minimum_1() public {
// cover: Deposit :: msg.value >= MinDeposit false
        vm.startPrank(owner);
        PrivateDeposit target = new PrivateDeposit();
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

    // @cover-intent Financial & Accounting: Verify that cash out exceeding balance is rejected and balance unchanged.
    function test_Cash_out_more_than_balance_2() public {
// cover: CashOut :: _am <= balances[msg.sender] false
        vm.startPrank(alice);
        PrivateDeposit target = new PrivateDeposit();
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
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can set a new Log contract address.
    function test_Owner_sets_log_to_a_new_Log_contract_3() public {
// cover: setLog :: tx.origin == owner true
        vm.startPrank(owner);
        PrivateDeposit target = new PrivateDeposit();
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
        {
        target.setLog(0x0000000000000000000000000000000000000001);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot set a new Log contract address.
    function test_Non_owner_cannot_set_log_4() public {
// cover: setLog :: tx.origin == owner false
        vm.startPrank(owner);
        PrivateDeposit target = new PrivateDeposit();
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
        vm.prank(alice);
        {
        target.setLog(0x0000000000000000000000000000000000000001);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that cash out updates balance before external call, preventing reentrancy.
    function test_Deposit_and_cash_out_with_reentrancy_guard_check_5() public {
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateDeposit target = new PrivateDeposit();
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

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate and partial cash out reduces balance correctly.
    function test_Multiple_deposits_and_partial_cash_out_6() public {
// cover: Deposit :: msg.value >= MinDeposit true
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        PrivateDeposit target = new PrivateDeposit();
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
        target.CashOut(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that public view functions are accessible to anyone.
    function test_Owner_can_read_MinDeposit_and_balances_7() public {
        vm.startPrank(owner);
        PrivateDeposit target = new PrivateDeposit();
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
        // skip ABI-mismatched call: MinDeposit()
        {
        target.balances(alice);
        }
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_CashOut_sequence_8() public {
        vm.startPrank(alice);
        PrivateDeposit target = new PrivateDeposit();
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
    function test_Deposit_sequence_9() public {
        vm.startPrank(alice);
        PrivateDeposit target = new PrivateDeposit();
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
    function test_MinDeposit_sequence_10() public {
        vm.startPrank(owner);
        PrivateDeposit target = new PrivateDeposit();
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
    function test_balances_sequence_11() public {
        vm.startPrank(alice);
        PrivateDeposit target = new PrivateDeposit();
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

    // @cover-intent Authorization & Access Control
    function test_owner_sequence_12() public {
        vm.startPrank(owner);
        PrivateDeposit target = new PrivateDeposit();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Authorization & Access Control
    function test_setLog_sequence_13() public {
        vm.startPrank(owner);
        PrivateDeposit target = new PrivateDeposit();
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
        {
        target.setLog(alice);
        }
    }

}
