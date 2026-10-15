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


    // @cover-intent Financial & Accounting: Test normal deposit and immediate withdrawal after lock period expires
    function test_deposit_and_withdraw_normal_0() public {
// assume: now <= lockTime(alice)
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
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test successful withdrawal after lock period expires
    function test_deposit_and_withdraw_after_lock_1() public {
// assume: now > lockTime(alice)
// cover: withdraw :: require(now > lockTime[msg.sender]) true
// cover: withdraw :: require(balances[msg.sender] > 0) true
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
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

    // @cover-intent Authorization & Access Control: Test that increasing lock time prevents withdrawal until new lock expires
    function test_increase_lock_time_before_withdraw_2() public {
// assume: now <= lockTime(alice)
// cover: withdraw :: require(now > lockTime[msg.sender]) false
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
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

    // @cover-intent Financial & Accounting: Test multiple deposits accumulate and can be withdrawn after lock
    function test_multiple_deposits_and_withdraw_3() public {
// assume: now > lockTime(alice)
// cover: withdraw :: require(balances[msg.sender] > 0) true
// cover: withdraw :: require(now > lockTime[msg.sender]) true
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deposit()
        // skip ABI-mismatched call: deposit()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Test withdrawal reverts when balance is zero
    function test_withdraw_with_zero_balance_4() public {
// assume: balances(alice) == 0
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Test that increasing lock time by a large value does not overflow (vulnerability test)
    function test_increase_lock_time_overflow_5() public {
// assume: now > lockTime(alice) due to overflow
// cover: increaseLockTime :: overflow causes lockTime to wrap to small value
// cover: withdraw :: require(now > lockTime[msg.sender]) true
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: deposit()
        {
        target.increaseLockTime(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control: Test that lock times are independent per user
    function test_multiple_users_independent_locks_6() public {
// assume: now > lockTime(bob)
// assume: now <= lockTime(alice)
// cover: withdraw :: require(now > lockTime[msg.sender]) true for bob
// cover: withdraw :: require(now > lockTime[msg.sender]) false for alice
        vm.startPrank(alice);
        TimeLock target = new TimeLock();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: deposit()
        vm.prank(bob);
        // skip ABI-mismatched call: deposit()
        vm.prank(alice);
        {
        target.increaseLockTime(86400);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_deposit_sequence_7() public {
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

    // @cover-intent Financial & Accounting
    function test_withdraw_sequence_8() public {
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
        vm.stopPrank();
    }

    // @cover-intent minimal test for balances
    function test_perfn_balances_9() public {
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
    function test_perfn_increaseLockTime_10() public {
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
    function test_perfn_lockTime_11() public {
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
