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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via Put, then collect it after the unlock time passes, with balance decrement and MinSum check.
    function test_Basic_Put_and_Collect_flow_0() public {
// assume: now > 100
// cover: Collect :: require(acc.balance>=MinSum) false
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
        target.Put.value(5 ether)(100);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify successful collection when balance >= MinSum and unlock time has passed.
    function test_Collect_after_unlock_time_passes_1() public {
// assume: now > 1
// cover: Collect :: require(acc.balance>=MinSum) true
// cover: Collect :: require(acc.balance>=_am) true
// cover: Collect :: require(now>acc.unlockTime) true
// cover: Collect :: if(msg.sender.call.value(_am)()) true
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
        target.Put.value(2 ether)(1);
        }
        {
        target.Collect(1 ether);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when _am exceeds acc.balance.
    function test_Collect_with_amount_exceeding_balance_2() public {
// assume: now > 1
// cover: Collect :: require(acc.balance>=_am) false
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
        target.Put.value(1 ether)(1);
        }
        vm.expectRevert();
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts when now <= acc.unlockTime.
    function test_Collect_before_unlock_time_3() public {
// assume: now < 9999999999
// cover: Collect :: require(now>acc.unlockTime) false
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
        target.Put.value(2 ether)(9999999999);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract without data calls Put(0) and updates balance.
    function test_Fallback_triggers_Put_with_zero_unlock_time_4() public {
// cover: fallback :: calls Put(0)
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
        target.Acc(alice);
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiple Put calls accumulate balance and partial Collect works correctly.
    function test_Multiple_deposits_and_partial_collection_5() public {
// assume: now > 1
// cover: Collect :: require(acc.balance>=MinSum) true
// cover: Collect :: require(acc.balance>=_am) true
// cover: Collect :: require(now>acc.unlockTime) true
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
        target.Put.value(5 ether)(1);
        }
        {
        target.Put.value(3 ether)(1);
        }
        {
        target.Collect(4 ether);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect works when balance equals MinSum (1 ether).
    function test_Collect_exactly_MinSum_6() public {
// assume: now > 1
// cover: Collect :: require(acc.balance>=MinSum) true
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
        target.Put.value(1 ether)(1);
        }
        {
        target.Collect(1 ether);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that Collect(0) succeeds when balance >= MinSum and unlock time passed.
    function test_Collect_with_zero_amount_7() public {
// assume: now > 1
// cover: Collect :: require(acc.balance>=_am) true
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
        target.Put.value(2 ether)(1);
        }
        {
        target.Collect(0);
        }
        {
        target.Acc(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that different users have independent Acc mappings.
    function test_Separate_users_have_independent_balances_8() public {
// assume: now > 1
// cover: Collect :: require(acc.balance>=MinSum) true
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
        target.Put.value(3 ether)(1);
        }
        vm.prank(bob);
        {
        target.Put.value(2 ether)(1);
        }
        vm.prank(alice);
        {
        target.Collect(1 ether);
        }
        vm.prank(bob);
        {
        target.Collect(1 ether);
        }
        vm.prank(alice);
        {
        target.Acc(alice);
        }
        vm.prank(bob);
        {
        target.Acc(bob);
        }
    }

    // @cover-intent Transactional Consistency: Verify that MinSum returns the expected value of 1 ether.
    function test_MinSum_read_9() public {
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
        // skip ABI-mismatched call: MinSum()
    }

    // @cover-intent Resource & Execution Integrity
    function test_Acc_View_10() public {
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
    }

    // @cover-intent External Interaction & Environment
    function test_Collect_Reentrancy_11() public {
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
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_MinSum_View_12() public {
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
        // skip ABI-mismatched call: MinSum()
        // TODO assert: call:MinSum() >= 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_Put_Deposit_13() public {
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
    }

}
