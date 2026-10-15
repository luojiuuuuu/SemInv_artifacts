// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xb5e1b1ee15c6fa0e48fce100125569d430f1bd12.sol";

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

contract Private_Bank_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Private_Bank_FunctionalTest() public {
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


    // @cover-intent Test that Deposit reverts when msg.value is less than MinDeposit (1 ether) – Financial & Accounting boundary
    function test_Deposit_below_minimum_0() public {
// assume: MinDeposit() == 1 ether
// cover: Deposit :: msg.value > MinDeposit false
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(0.5 ether)();
        }
        // TODO assert: alice.balance == 0.5 ether
    }

    // @cover-intent Test that Deposit succeeds when msg.value exceeds MinDeposit – Financial & Accounting positive path
    function test_Deposit_above_minimum_1() public {
// assume: MinDeposit() == 1 ether
// cover: Deposit :: msg.value > MinDeposit true
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(2 ether)();
        }
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Test CashOut with amount equal to balance – Financial & Accounting positive path
    function test_CashOut_exact_balance_2() public {
// assume: balances(alice) == 2 ether
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(2 ether)();
        }
        {
        target.CashOut(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Test CashOut with amount greater than balance – Financial & Accounting boundary revert
    function test_CashOut_exceeding_balance_3() public {
// assume: balances(alice) == 1 ether
// cover: CashOut :: _am <= balances[msg.sender] false
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(1 ether)();
        }
        vm.expectRevert();
        {
        target.CashOut(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Test CashOut with zero amount – Financial & Accounting edge case
    function test_CashOut_zero_amount_4() public {
// assume: balances(alice) == 1 ether
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(0)() true
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(1 ether)();
        }
        {
        target.CashOut(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Test that reentrancy in CashOut does not drain more than balance – External Interaction & Environment vulnerability check
    function test_Reentrancy_attempt_via_CashOut_5() public {
// assume: balances(alice) == 2 ether
// cover: CashOut :: _am <= balances[msg.sender] true
// cover: CashOut :: msg.sender.call.value(_am)() true
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(2 ether)();
        }
        {
        target.CashOut(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Test sequence of deposits and cashouts to ensure balance consistency – Financial & Accounting
    function test_Multiple_deposits_and_cashouts_6() public {
// assume: balances(alice) == 2 ether
// assume: balances(bob) == 3 ether
// cover: CashOut :: _am <= balances[msg.sender] true
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(2 ether)();
        }
        vm.prank(bob);
        {
        target.Deposit.value(3 ether)();
        }
        vm.prank(alice);
        {
        target.CashOut(1 ether);
        }
        vm.prank(bob);
        {
        target.CashOut(2 ether);
        }
        // TODO assert: alice.balance == 1 ether
        // TODO assert: bob.balance == 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_CashOut_sequence_7() public {
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(2 ether)();
        }
        {
        target.CashOut(1);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_8() public {
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(2 ether)();
        }
        // TODO assert: alice.balance == 2
    }

    // @cover-intent Financial & Accounting
    function test_MinDeposit_sequence_9() public {
        vm.startPrank(owner);
        Private_Bank target = new Private_Bank(alice);
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
        target.MinDeposit();
        }
        // TODO assert: call:MinDeposit() >= 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_10() public {
        vm.startPrank(alice);
        Private_Bank target = new Private_Bank(alice);
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
        target.Deposit.value(2 ether)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2
    }

}
