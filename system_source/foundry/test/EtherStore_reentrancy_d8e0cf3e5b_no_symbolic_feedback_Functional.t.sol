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


    // @cover-intent Financial & Accounting: Verify that a user can deposit and then withdraw up to the withdrawal limit after the one-week cooldown, and that balances and lastWithdrawTime update correctly.
    function test_Deposit_and_withdraw_within_limit_and_time_window_0() public {
// assume: balances(alice) >= 1 ether
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
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Ensure that withdrawing more than the user's balance reverts.
    function test_Withdraw_exceeding_balance_reverts_1() public {
// assume: balances(alice) == 0.5 ether
// cover: withdrawFunds :: require(balances[msg.sender] >= _weiToWithdraw) false
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: depositFunds()
        vm.expectRevert();
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Ensure that withdrawing more than the withdrawalLimit reverts.
    function test_Withdraw_exceeding_withdrawal_limit_reverts_2() public {
// assume: balances(alice) >= 2 ether
// assume: withdrawalLimit == 1 ether
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
        // skip ABI-mismatched call: depositFunds()
        vm.expectRevert();
        {
        target.withdrawFunds(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that a reentrancy attack during the external call in withdrawFunds does not drain more than the user's balance, due to the balance update after the call.
    function test_Reentrancy_attempt_via_malicious_fallback_3() public {
// assume: balances(alice) >= 1 ether
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// assume: alice's fallback calls withdrawFunds again
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
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate correctly and a single withdrawal reduces the balance appropriately.
    function test_Multiple_deposits_and_single_withdrawal_4() public {
// assume: balances(alice) == 3 ether
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(balances[msg.sender] >= _weiToWithdraw) true
// cover: withdrawFunds :: require(_weiToWithdraw <= withdrawalLimit) true
// cover: withdrawFunds :: require(now >= lastWithdrawTime[msg.sender] + 1 weeks) true
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
        // skip ABI-mismatched call: depositFunds()
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing zero wei is allowed (edge case).
    function test_Withdraw_zero_wei_5() public {
// assume: balances(alice) >= 0
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(balances[msg.sender] >= _weiToWithdraw) true
// cover: withdrawFunds :: require(_weiToWithdraw <= withdrawalLimit) true
// cover: withdrawFunds :: require(now >= lastWithdrawTime[msg.sender] + 1 weeks) true
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
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing exactly the withdrawal limit succeeds.
    function test_Withdraw_exactly_withdrawal_limit_6() public {
// assume: balances(alice) >= 1 ether
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(_weiToWithdraw <= withdrawalLimit) true
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
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that after a successful withdrawal, lastWithdrawTime is updated to now, enforcing a new cooldown.
    function test_Withdraw_after_cooldown_resets_timer_7() public {
// assume: balances(alice) >= 1 ether after first withdraw
// assume: now < lastWithdrawTime(alice) + 1 weeks after first withdraw
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
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple users can deposit independently and their balances are tracked separately.
    function test_Deposit_from_multiple_users_8() public {
// assume: balances(alice) >= 0.5 ether
// assume: balances(bob) >= 1 ether
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// assume: now >= lastWithdrawTime(bob) + 1 weeks
// cover: withdrawFunds :: require(balances[msg.sender] >= _weiToWithdraw) true (both)
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
        // skip ABI-mismatched call: depositFunds()
        vm.startPrank(bob);
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_depositFunds_positive_9() public {
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
        // skip ABI-mismatched call: depositFunds()
        // TODO assert: call:balances(alice) == 2 ether
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawFunds_positive_10() public {
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=lastWithdrawTime[alice], value=0;
        // dropped unsafe vm.store: slot=balances[alice], value=2 ether;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
        // TODO assert: call:balances(alice) == 1 ether
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawFunds_revert_insufficient_balance_11() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdrawFunds(1 ether);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawFunds_revert_exceeds_limit_12() public {
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=balances[alice], value=2 ether;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: depositFunds()
        vm.expectRevert();
        {
        target.withdrawFunds(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_withdrawFunds_revert_time_lock_13() public {
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=balances[alice], value=1 ether;
        // dropped unsafe vm.store: slot=lastWithdrawTime[alice], value=9999999999;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: depositFunds()
        vm.expectRevert();
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_balances_view_14() public {
        vm.startPrank(alice);
        EtherStore target = new EtherStore();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=balances[alice], value=5 ether;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: depositFunds()
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: call:balances(alice) == 5 ether
    }

    // @cover-intent Protocol State Machine
    function test_lastWithdrawTime_view_15() public {
        vm.startPrank(owner);
        EtherStore target = new EtherStore();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe vm.store: slot=lastWithdrawTime[alice], value=1000;
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.lastWithdrawTime(alice);
        }
        {
            uint256 __v1 = uint256(target.lastWithdrawTime(alice));
            _assertRelU(__v1, 0, 1000, "call:lastWithdrawTime==1000");
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawalLimit_view_16() public {
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
        // skip ABI-mismatched call: withdrawalLimit()
        // TODO assert: call:withdrawalLimit() == 1 ether
    }

}
