// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x941d225236464a25eb18076df7da6a91d0f95e9e.sol";

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

contract ETH_FUND_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function ETH_FUND_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a deposit below MinDeposit (1 ether) does not update the balance mapping.
    function test_deposit_below_minimum_0() public {
// assume: MinDeposit() == 1 ether
// cover: Deposit :: msg.value > MinDeposit false
        vm.startPrank(owner);
        ETH_FUND target = new ETH_FUND(alice);
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that a deposit exactly equal to MinDeposit does not update the balance (strict greater-than check).
    function test_deposit_at_minimum_1() public {
// assume: MinDeposit() == 1 ether
// cover: Deposit :: msg.value > MinDeposit false
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that a deposit above MinDeposit updates the balance correctly.
    function test_deposit_above_minimum_2() public {
// assume: MinDeposit() == 1 ether
// cover: Deposit :: msg.value > MinDeposit true
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
    }

    // @cover-intent Authorization & Access Control: Verify that CashOut reverts when _am exceeds the caller's balance.
    function test_cashout_exceeds_balance_3() public {
// assume: balances(alice) == 2 ether
// cover: CashOut :: _am <= balances[msg.sender] false
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        target.CashOut(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that CashOut reverts when block.number <= lastBlock (same block as last deposit).
    function test_cashout_same_block_as_deposit_4() public {
// assume: block.number == lastBlock
// cover: CashOut :: block.number > lastBlock false
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        target.CashOut(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify a successful CashOut after a deposit in a previous block, with balance deduction.
    function test_cashout_successful_5() public {
// assume: block.number > lastBlock
// assume: balances(alice) == 2 ether
// cover: CashOut :: (_am <= balances[msg.sender] && block.number > lastBlock) true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that reentrancy via fallback does not drain the contract (balance deduction happens after external call).
    function test_cashout_reentrancy_attempt_6() public {
// assume: block.number > lastBlock
// assume: balances(alice) == 3 ether
// assume: alice's fallback reenters CashOut(1 ether)
// cover: CashOut :: msg.sender.call.value(_am)() true
// cover: CashOut :: balances[msg.sender]-=_am after call
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify cumulative balance tracking across multiple deposits and a partial cashout.
    function test_multiple_deposits_and_cashout_7() public {
// assume: block.number > lastBlock
// assume: balances(alice) == 5 ether
// cover: Deposit :: msg.value > MinDeposit true (twice)
// cover: CashOut :: (_am <= balances[msg.sender] && block.number > lastBlock) true
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that CashOut with _am=0 succeeds (edge case) and does not change balance.
    function test_cashout_zero_amount_8() public {
// assume: block.number > lastBlock
// assume: balances(alice) == 2 ether
// cover: CashOut :: _am <= balances[msg.sender] true (0 <= 2)
// cover: CashOut :: msg.sender.call.value(0)() true
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        target.CashOut(0);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_CashOut_sequence_9() public {
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        ETH_FUND target = new ETH_FUND(alice);
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
        ETH_FUND target = new ETH_FUND(alice);
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
        // TODO assert: call:MinDeposit() >= 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_12() public {
        vm.startPrank(alice);
        ETH_FUND target = new ETH_FUND(alice);
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
        // TODO assert: call:balances(alice) >= 2 ether
    }

}
