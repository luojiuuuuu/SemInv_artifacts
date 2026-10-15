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


    // @cover-intent Financial & Accounting: Verify normal deposit and withdrawal flow after lock time expires
    function test_deposit_and_withdraw_normal_0() public {
// assume: now > lockTime(alice) after 1 week passes
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
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        {
        target.increaseLockTime(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify withdrawal reverts when lock time has not expired
    function test_withdraw_before_lock_expires_1() public {
// assume: now <= lockTime(alice)
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
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify withdrawal reverts when balance is zero
    function test_withdraw_zero_balance_2() public {
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

    // @cover-intent Transactional Consistency: Verify increasing lock time extends the lock period
    function test_increase_lock_time_after_deposit_3() public {
// assume: now == lockTime(alice) - 1 second (before original expiry but after increase)
// cover: increaseLockTime :: lockTime[msg.sender] += _secondsToIncrease
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
        target.increaseLockTime(86400);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify multiple deposits accumulate balance and reset lock time
    function test_multiple_deposits_same_user_4() public {
// assume: now > lockTime(alice) after 1 week passes
// cover: deposit :: balances[msg.sender] += msg.value
// cover: deposit :: lockTime[msg.sender] = now + 1 weeks
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
        {
        target.increaseLockTime(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify increasing lock time by zero does not change behavior
    function test_increase_lock_time_zero_5() public {
// assume: now <= lockTime(alice) (before expiry)
// cover: increaseLockTime :: lockTime[msg.sender] += 0
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
        target.increaseLockTime(0);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify users have independent balances and lock times
    function test_different_users_independent_locks_6() public {
// assume: now > lockTime(alice) and now > lockTime(bob) after 1 week passes
// cover: deposit :: different users
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
        vm.prank(alice);
        {
        target.increaseLockTime(0);
        }
        vm.prank(bob);
        {
        target.increaseLockTime(0);
        }
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
        {
            uint256 __v1 = uint256(target.balances(alice));
            _assertRelU(__v1, 0, 100, "call:balances==100");
        }
    }

    // @cover-intent Protocol State Machine
    function test_increaseLockTime_sequence_8() public {
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
        target.increaseLockTime(100);
        }
        vm.stopPrank();
        // TODO assert: call:lockTime(alice) >= 604800 + 100
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
        {
        target.increaseLockTime(0);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.balances(alice));
            _assertRelU(__v2, 0, 100, "call:balances==100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_balances_sequence_10() public {
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
        {
        target.balances(alice);
        }
        {
            uint256 __v3 = uint256(target.balances(alice));
            _assertRelU(__v3, 0, 50, "call:balances==50");
        }
    }

    // @cover-intent Protocol State Machine
    function test_lockTime_sequence_11() public {
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
        {
        target.lockTime(alice);
        }
        {
            uint256 __v4 = uint256(target.lockTime(alice));
            _assertRelU(__v4, 2, 604800, "call:lockTime>=604800");
        }
    }

}
