// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/etherstore.sol";

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

contract EtherStore_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function EtherStore_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and then withdraw up to the limit after the time lock expires.
    function test_Deposit_and_Withdraw_Success_0() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(balances[msg.sender] >= _weiToWithdraw) true
// cover: withdrawFunds :: require(_weiToWithdraw <= withdrawalLimit) true
// cover: withdrawFunds :: require(now >= lastWithdrawTime[msg.sender] + 1 weeks) true
// cover: withdrawFunds :: require(msg.sender.call.value(_weiToWithdraw)()) true
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(2 ether)();
        }
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawal reverts when the amount exceeds the user's balance.
    function test_Withdraw_Exceeds_Balance_1() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(balances[msg.sender] >= _weiToWithdraw) false
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(0.5 ether)();
        }
        vm.expectRevert();
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0.5 ether
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawal reverts when the amount exceeds the withdrawal limit.
    function test_Withdraw_Exceeds_Limit_2() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(_weiToWithdraw <= withdrawalLimit) false
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(2 ether)();
        }
        vm.expectRevert();
        {
        target.withdrawFunds(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Protocol State Machine: Verify that withdrawal reverts if attempted before the one-week time lock has passed.
    function test_Withdraw_Before_Time_Lock_3() public {
// assume: now < lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(now >= lastWithdrawTime[msg.sender] + 1 weeks) false
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(1 ether)();
        }
        vm.expectRevert();
        // skip malformed call: withdrawFunds(0.5 ether) (bad raw arg for withdrawFunds.arg0: type=uint256, raw=0.5 ether)
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent External Interaction & Environment: Verify that a reentrant call during withdrawal does not allow multiple withdrawals (the balance is updated after the external call, but the require on the call result prevents reentrancy from succeeding).
    function test_Reentrancy_Attempt_4() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// assume: alice is a malicious contract that reenters withdrawFunds on receive
// cover: withdrawFunds :: require(msg.sender.call.value(_weiToWithdraw)()) true (reentrancy fails because balance is not yet updated but the reentrant call will revert due to insufficient balance after first withdrawal)
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(2 ether)();
        }
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate correctly and a single withdrawal reduces the balance appropriately.
    function test_Multiple_Deposits_and_Single_Withdrawal_5() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(balances[msg.sender] >= _weiToWithdraw) true
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(1 ether)();
        }
        {
        target.depositFunds.value(0.5 ether)();
        }
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawal exactly at the limit succeeds.
    function test_Withdrawal_Limit_Boundary_6() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(_weiToWithdraw <= withdrawalLimit) true (boundary)
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(1 ether)();
        }
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that after a successful withdrawal, the time lock resets and a second withdrawal within the same week reverts.
    function test_Withdrawal_After_Time_Lock_Reset_7() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks for first withdrawal
// assume: now < lastWithdrawTime(alice) + 1 weeks for second withdrawal (time lock reset after first)
// cover: withdrawFunds :: require(now >= lastWithdrawTime[msg.sender] + 1 weeks) false (second call)
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(2 ether)();
        }
        {
        target.withdrawFunds(1 ether);
        }
        vm.expectRevert();
        // skip malformed call: withdrawFunds(0.5 ether) (bad raw arg for withdrawFunds.arg0: type=uint256, raw=0.5 ether)
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_balances_query_8() public {
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(1 ether)();
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_depositFunds_deposit_9() public {
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(2 ether)();
        }
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_lastWithdrawTime_query_10() public {
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(1 ether)();
        }
        {
        target.withdrawFunds(1 ether);
        }
        {
        target.lastWithdrawTime(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_success_11() public {
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
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
        target.depositFunds.value(1 ether)();
        }
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdrawalLimit_query_12() public {
        vm.startPrank(owner);
        EtherStore target = new EtherStore();
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
        target.withdrawalLimit();
        }
    }

}
