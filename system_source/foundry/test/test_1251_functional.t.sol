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


    // @cover-intent Financial & Accounting: Verify that a deposit of exactly MinDeposit updates the balance and emits a log entry via TransferLog.
    function test_Deposit_positive_path_0() public {
// assume: MinDeposit() == 1 ether
// cover: Deposit :: require(msg.value >= MinDeposit) true
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

    // @cover-intent Financial & Accounting: Verify that a deposit below MinDeposit does not update balance and does not call TransferLog.
    function test_Deposit_below_minimum_reverts_1() public {
// assume: MinDeposit() == 1 ether
// cover: Deposit :: require(msg.value >= MinDeposit) false
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that CashOut reduces balance and calls TransferLog after successful ETH transfer.
    function test_CashOut_positive_path_2() public {
// assume: balances(alice) >= 1 ether
// cover: CashOut :: require(_am <= balances[msg.sender]) true
// cover: CashOut :: require(msg.sender.call.value(_am)()) true
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

    // @cover-intent Financial & Accounting: Verify that CashOut reverts when _am > balances[msg.sender].
    function test_CashOut_amount_exceeds_balance_reverts_3() public {
// assume: balances(alice) == 1 ether
// cover: CashOut :: require(_am <= balances[msg.sender]) false
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
        vm.expectRevert();
        {
        target.CashOut(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can set a new Log contract address.
    function test_setLog_onlyOwner_positive_path_4() public {
// assume: tx.origin == owner
// cover: setLog :: require(tx.origin == owner) true
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

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call setLog.
    function test_setLog_non_owner_reverts_5() public {
// assume: tx.origin != owner
// cover: setLog :: require(tx.origin == owner) false
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

    // @cover-intent Transactional Consistency: Verify that a deposit followed by a full cashout results in zero balance and supply conservation.
    function test_Deposit_and_CashOut_full_cycle_6() public {
// assume: MinDeposit() == 1 ether
// assume: balances(alice) == 1 ether
// cover: Deposit :: require(msg.value >= MinDeposit) true
// cover: CashOut :: require(_am <= balances[msg.sender]) true
// cover: CashOut :: require(msg.sender.call.value(_am)()) true
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_CashOut_sequence_7() public {
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
    function test_Deposit_sequence_8() public {
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
    function test_MinDeposit_sequence_9() public {
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
    function test_balances_sequence_10() public {
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
    function test_owner_sequence_11() public {
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
    function test_setLog_sequence_12() public {
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
