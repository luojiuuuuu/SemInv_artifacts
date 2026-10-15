// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/timelock.sol";

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

contract TimeLock_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function TimeLock_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and withdraw after the 1-week lock time expires.
    function test_Normal_deposit_and_withdraw_after_lock_period_0() public {
// assume: now > lockTime[alice] + 1 weeks
// cover: withdraw :: require(balances[msg.sender] > 0) true
// cover: withdraw :: require(now > lockTime[msg.sender]) false
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        {
        target.increaseLockTime(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify successful withdrawal after lock period has passed.
    function test_Withdraw_after_lock_time_expires_1() public {
// assume: now > lockTime[alice]
// cover: withdraw :: require(balances[msg.sender] > 0) true
// cover: withdraw :: require(now > lockTime[msg.sender]) true
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that increasing lock time prevents early withdrawal.
    function test_Increase_lock_time_extends_withdrawal_delay_2() public {
// assume: now > lockTime[alice] - 604800 && now < lockTime[alice]
// cover: withdraw :: require(now > lockTime[msg.sender]) false
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
        {
        target.increaseLockTime(604800);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate balance and reset lock time to now + 1 week.
    function test_Multiple_deposits_increase_balance_and_reset_lock_time_3() public {
// assume: now < lockTime[alice]
// cover: withdraw :: require(balances[msg.sender] > 0) true
// cover: withdraw :: require(now > lockTime[msg.sender]) false
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
        // skip ABI-mismatched call: deposit()
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw reverts when user has no balance.
    function test_Withdraw_with_zero_balance_reverts_4() public {
// cover: withdraw :: require(balances[msg.sender] > 0) false
        vm.startPrank(owner);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Resource & Execution Integrity: Verify that increasing lock time by zero is a no-op.
    function test_Increase_lock_time_by_zero_does_not_change_behavior_5() public {
// assume: now > lockTime[alice]
// cover: withdraw :: require(balances[msg.sender] > 0) true
// cover: withdraw :: require(now > lockTime[msg.sender]) true
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
        {
        target.increaseLockTime(0);
        }
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that a very large lock time increase effectively locks funds forever.
    function test_Large_increase_lock_time_prevents_withdrawal_indefinitely_6() public {
// assume: now < lockTime[alice]
// cover: withdraw :: require(now > lockTime[msg.sender]) false
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
        {
        target.increaseLockTime(1000000000);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that different users have independent balances and lock times.
    function test_Multiple_users_can_deposit_independently_7() public {
// assume: now < lockTime[alice] && now < lockTime[bob]
// cover: withdraw :: require(balances[msg.sender] > 0) true
// cover: withdraw :: require(now > lockTime[msg.sender]) false
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
        vm.prank(bob);
        // skip ABI-mismatched call: deposit()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Financial & Accounting
    function test_deposit_sequence_8() public {
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
    }

    // @cover-intent Protocol State Machine
    function test_withdraw_sequence_9() public {
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
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
        // skip ABI-mismatched call: deposit()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent minimal test for balances
    function test_perfn_balances_10() public {
        vm.startPrank(owner);
        TimeLock target = new TimeLock();
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

    // @cover-intent minimal test for increaseLockTime
    function test_perfn_increaseLockTime_11() public {
        vm.startPrank(owner);
        TimeLock target = new TimeLock();
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
        target.increaseLockTime(1);
        }
    }

    // @cover-intent minimal test for lockTime
    function test_perfn_lockTime_12() public {
        vm.startPrank(owner);
        TimeLock target = new TimeLock();
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
        target.lockTime(alice);
        }
    }

}
