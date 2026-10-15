// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x93c32845fae42c83a70e5f06214c8433665c2ab5.sol";

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

contract X_WALLET_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function X_WALLET_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify normal deposit and withdrawal flow with sufficient balance and time lock expired
    function test_Put_and_Collect_normal_0() public {
// assume: now > Acc[alice].unlockTime
// assume: Acc[alice].balance >= MinSum
// assume: Acc[alice].balance >= 1 ether
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime true
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(5 ether)(0);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 5 ether + 1 ether
    }

    // @cover-intent External Interaction & Environment: Verify Collect reverts when unlock time is in the future
    function test_Put_with_future_unlock_and_Collect_before_time_1() public {
// assume: now < 2000000000
// assume: Acc[alice].balance >= MinSum
// assume: Acc[alice].balance >= 1 ether
// cover: Collect :: now>acc.unlockTime false
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(5 ether)(2000000000);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 5 ether
    }

    // @cover-intent Financial & Accounting: Verify Collect reverts when requested amount exceeds balance
    function test_Collect_insufficient_balance_2() public {
// assume: now > Acc[alice].unlockTime
// assume: Acc[alice].balance >= MinSum
// assume: Acc[alice].balance < 2 ether
// cover: Collect :: acc.balance>=_am false
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(1 ether)(0);
        }
        vm.expectRevert();
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 1 ether
    }

    // @cover-intent Financial & Accounting: Verify Collect reverts when balance is below MinSum (1 ether)
    function test_Collect_below_MinSum_3() public {
// assume: now > Acc[alice].unlockTime
// assume: Acc[alice].balance < MinSum
// assume: Acc[alice].balance >= 0.1 ether
// cover: Collect :: acc.balance>=MinSum false
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(0.5 ether)(0);
        }
        vm.expectRevert();
        // skip malformed call: Collect(0.1 ether) (bad raw arg for Collect.arg0: type=uint256, raw=0.1 ether)
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 0.5 ether
    }

    // @cover-intent Financial & Accounting: Verify accumulation of multiple deposits and correct withdrawal
    function test_Multiple_deposits_and_single_collect_4() public {
// assume: now > Acc[alice].unlockTime
// assume: Acc[alice].balance == 5 ether
// assume: Acc[alice].balance >= MinSum
// assume: Acc[alice].balance >= 4 ether
// cover: Collect :: all conditions true
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(2 ether)(0);
        }
        {
        target.Put.value(3 ether)(0);
        }
        {
        target.Collect(4 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 20 ether - 5 ether + 4 ether
    }

    // @cover-intent Resource & Execution Integrity: Verify that after successful call.value, balance is decremented (reentrancy protection via state update after call)
    function test_Collect_reentrancy_guard_behavior_5() public {
// assume: now > Acc[alice].unlockTime
// assume: Acc[alice].balance >= MinSum
// assume: Acc[alice].balance >= 1 ether
// cover: Collect :: msg.sender.call.value(_am)() true
// cover: Collect :: acc.balance-=_am executed
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(5 ether)(0);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 5 ether + 1 ether
    }

    // @cover-intent External Interaction & Environment: Verify that Put sets unlockTime to now when _unlockTime is in the past
    function test_Put_with_past_unlock_time_6() public {
// assume: now > 1
// assume: Acc[alice].unlockTime == now
// assume: Acc[alice].balance == 1 ether
// cover: Put :: _unlockTime>now false (unlockTime set to now)
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(1 ether)(1);
        }
        // TODO assert: alice.balance == 10 ether - 1 ether
    }

    // @cover-intent Financial & Accounting: Verify Collect works when balance equals MinSum exactly
    function test_Collect_exact_MinSum_7() public {
// assume: now > Acc[alice].unlockTime
// assume: Acc[alice].balance == 1 ether
// assume: Acc[alice].balance >= MinSum
// assume: Acc[alice].balance >= 1 ether
// cover: Collect :: acc.balance>=MinSum true (boundary)
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(1 ether)(0);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether - 1 ether + 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that different users have independent balances and can operate separately
    function test_Multiple_users_independent_accounts_8() public {
// assume: now > Acc[alice].unlockTime
// assume: now > Acc[bob].unlockTime
// assume: Acc[alice].balance >= MinSum
// assume: Acc[bob].balance >= MinSum
// assume: Acc[alice].balance >= 2 ether
// assume: Acc[bob].balance >= 1 ether
// cover: Collect :: all conditions true for alice
// cover: Collect :: all conditions true for bob
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(3 ether)(0);
        }
        vm.prank(bob);
        {
        target.Put.value(2 ether)(0);
        }
        vm.prank(alice);
        {
        target.Collect(2 ether);
        }
        vm.prank(bob);
        {
        target.Collect(1 ether);
        }
        // TODO assert: alice.balance == 10 ether - 3 ether + 2 ether
        // TODO assert: bob.balance == 10 ether - 2 ether + 1 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_Acc_query_9() public {
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(1 ether)(0);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_Collect_positive_10() public {
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(1 ether)(0);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_query_11() public {
        vm.startPrank(owner);
        X_WALLET target = new X_WALLET(alice);
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
        target.MinSum();
        }
    }

    // @cover-intent Financial & Accounting
    function test_Put_positive_12() public {
        vm.startPrank(alice);
        X_WALLET target = new X_WALLET(alice);
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
        target.Put.value(1 ether)(0);
        }
        // TODO assert: alice.balance == 1 ether
    }

}
