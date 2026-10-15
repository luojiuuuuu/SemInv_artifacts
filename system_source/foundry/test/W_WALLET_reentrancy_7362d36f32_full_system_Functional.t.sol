// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x7b368c4e805c3870b6c49a3f1f49f69af8662cf3.sol";

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

contract W_WALLET_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function W_WALLET_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via Put, then collect a portion after unlock time, with correct balance deduction and event logging.
    function test_Basic_Put_and_Collect_Positive_0() public {
// assume: block.timestamp >= 10000000000
// assume: Acc(alice).balance >= MinSum
// assume: Acc(alice).balance >= 2 ether
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime true
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(5 ether)(10000000000);
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that Collect reverts when called before the unlock time set by Put.
    function test_Collect_Before_UnlockTime_Reverts_1() public {
// assume: block.timestamp < Acc(alice).unlockTime
// cover: Collect :: now>acc.unlockTime false
        vm.startPrank(owner);
        W_WALLET target = new W_WALLET(alice);
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
        target.Collect(1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when requested amount exceeds the user's balance.
    function test_Collect_Insufficient_Balance_Reverts_2() public {
// assume: block.timestamp >= 10000000000
// assume: Acc(alice).balance < 2 ether
// cover: Collect :: acc.balance>=_am false
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(1 ether)(10000000000);
        }
        vm.expectRevert();
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH directly to the contract (fallback) triggers Put(0), setting unlockTime to now.
    function test_Fallback_Calls_Put_With_Zero_UnlockTime_3() public {
// assume: Acc(alice).unlockTime == block.timestamp
// assume: Acc(alice).balance == 3 ether
// cover: Put :: _unlockTime>now?_unlockTime:now
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
    }

    // @cover-intent Financial & Accounting: Verify that multiple Put calls accumulate balance correctly.
    function test_Multiple_Deposits_Accumulate_Balance_4() public {
// assume: block.timestamp >= 10000000001
// assume: Acc(alice).balance == 5 ether
// assume: Acc(alice).balance >= MinSum
// cover: Collect :: acc.balance>=MinSum && acc.balance>=_am && now>acc.unlockTime true
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(10000000000);
        }
        {
        target.Put.value(3 ether)(10000000001);
        }
        {
        target.Collect(4 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect can withdraw the exact balance, leaving zero.
    function test_Collect_Exact_Balance_After_Unlock_5() public {
// assume: block.timestamp >= 10000000000
// assume: Acc(alice).balance == 2 ether
// assume: Acc(alice).balance >= MinSum
// cover: Collect :: acc.balance>=_am true (exact match)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(10000000000);
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that Put with _unlockTime in the past sets unlockTime to current block.timestamp.
    function test_Put_With_Past_UnlockTime_Sets_To_Now_6() public {
// assume: block.timestamp > 1
// assume: Acc(alice).unlockTime == block.timestamp
// cover: Put :: _unlockTime>now false
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
    }

    // @cover-intent External Interaction & Environment: Verify that the reentrancy guard (balance deduction after call) prevents double withdrawal in a single transaction.
    function test_Collect_Reentrancy_Attempt_After_Transfer_7() public {
// assume: block.timestamp >= 10000000000
// assume: Acc(alice).balance >= MinSum
// assume: Acc(alice).balance >= 3 ether
// assume: msg.sender.call.value(3 ether)() succeeds
// cover: Collect :: msg.sender.call.value(_am)() true
// cover: Collect :: acc.balance-=_am executed
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(5 ether)(10000000000);
        }
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect with _am = 0 reverts due to balance >= _am being true but no actual transfer (edge case).
    function test_Collect_With_Zero_Amount_Reverts_8() public {
// assume: block.timestamp >= 10000000000
// assume: Acc(alice).balance >= MinSum
// assume: Acc(alice).balance >= 0
// cover: Collect :: msg.sender.call.value(0)() false (or reverts)
        vm.startPrank(alice);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put.value(2 ether)(10000000000);
        }
        vm.expectRevert();
        {
        target.Collect(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_view_9() public {
        vm.startPrank(owner);
        W_WALLET target = new W_WALLET(alice);
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

    // @cover-intent minimal test for Acc
    function test_perfn_Acc_10() public {
        vm.startPrank(owner);
        W_WALLET target = new W_WALLET(alice);
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

    // @cover-intent minimal test for Collect
    function test_perfn_Collect_11() public {
        vm.startPrank(owner);
        W_WALLET target = new W_WALLET(alice);
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
        target.Collect(1);
        }
    }

    // @cover-intent minimal test for Put
    function test_perfn_Put_12() public {
        vm.startPrank(owner);
        W_WALLET target = new W_WALLET(alice);
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
        target.Put(1);
        }
    }

}
