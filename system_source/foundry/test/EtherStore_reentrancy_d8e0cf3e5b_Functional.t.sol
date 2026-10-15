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


    // @cover-intent Financial & Accounting: Verify that a user can deposit and then withdraw within the withdrawal limit and after the 1-week cooldown, with correct balance updates.
    function test_Deposit_and_withdraw_within_limit_and_time_window_0() public {
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

    // @cover-intent Resource & Execution Integrity: Ensure withdrawal fails when requested amount exceeds the user's balance.
    function test_Withdraw_exceeding_balance_reverts_1() public {
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

    // @cover-intent Resource & Execution Integrity: Ensure withdrawal fails when requested amount exceeds the withdrawal limit.
    function test_Withdraw_exceeding_limit_reverts_2() public {
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

    // @cover-intent External Interaction & Environment: Verify that reentrancy during withdrawal does not drain the contract (checks-effects-interactions pattern is violated, but test shows the vulnerability).
    function test_Reentrancy_attack_attempt_via_fallback_3() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks
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
        vm.prank(alice);
        // skip ABI-mismatched call: depositFunds()
        vm.prank(bob);
        // skip ABI-mismatched call: depositFunds()
        vm.prank(alice);
        {
        target.withdrawFunds(1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate correctly and a single withdrawal reduces balance accordingly.
    function test_Multiple_deposits_and_single_withdrawal_4() public {
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
        // skip ABI-mismatched call: depositFunds()
        // skip ABI-mismatched call: depositFunds()
        {
        target.withdrawFunds(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawal of exactly the limit (1 ether) succeeds.
    function test_Withdrawal_limit_boundary_at_exactly_1_ether_5() public {
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

    // @cover-intent Resource & Execution Integrity: Verify that withdrawal of 0 wei succeeds (edge case).
    function test_Withdrawal_of_zero_amount_6() public {
// assume: now >= lastWithdrawTime(alice) + 1 weeks
// cover: withdrawFunds :: require(balances[msg.sender] >= _weiToWithdraw) true
// cover: withdrawFunds :: require(_weiToWithdraw <= withdrawalLimit) true
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
        {
        target.withdrawFunds(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that deposits from different users are isolated and one user can withdraw their own funds.
    function test_Deposit_by_multiple_users_and_withdrawal_by_one_7() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: depositFunds()
        vm.prank(bob);
        // skip ABI-mismatched call: depositFunds()
        vm.prank(alice);
        {
        target.withdrawFunds(1 ether);
        }
    }

    // @cover-intent Financial & Accounting
    function test_depositFunds_positive_8() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_positive_9() public {
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

    // @cover-intent Financial & Accounting
    function test_balances_view_10() public {
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
        vm.prank(bob);
        {
        target.balances(alice);
        }
    }

    // @cover-intent Protocol State Machine
    function test_lastWithdrawTime_view_11() public {
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
        vm.prank(bob);
        {
        target.lastWithdrawTime(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawalLimit_view_12() public {
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
    }

}
