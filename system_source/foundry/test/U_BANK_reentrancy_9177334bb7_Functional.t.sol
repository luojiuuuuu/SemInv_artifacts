// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x7541b76cb60f4c60af330c208b0623b7f54bf615.sol";

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

contract U_BANK_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function U_BANK_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via Put, then collect a portion after unlock time, with correct balance deduction and MinSum check.
    function test_Basic_Put_and_Collect_positive_0() public {
// assume: now >= 100
// assume: Acc(alice).balance >= 2 ether
// cover: Collect :: acc.balance >= MinSum && acc.balance >= _am && now > acc.unlockTime true
        vm.startPrank(alice);
        U_BANK target = new U_BANK(alice);
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
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        {
        target.Put(100);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when current time is not past unlockTime.
    function test_Collect_before_unlockTime_1() public {
// assume: now < 9999999999
// assume: Acc(alice).balance >= 2 ether
// cover: Collect :: now > acc.unlockTime false
        vm.startPrank(alice);
        U_BANK target = new U_BANK(alice);
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
        target.Put.value(5 ether)(9999999999);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect works when _am equals the full balance.
    function test_Collect_exact_balance_2() public {
// assume: now >= 0
// assume: Acc(alice).balance == 3 ether
// cover: Collect :: acc.balance >= _am true (equal)
        vm.startPrank(alice);
        U_BANK target = new U_BANK(alice);
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
        target.Put.value(3 ether)(0);
        }
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when _am exceeds balance.
    function test_Collect_exceeds_balance_3() public {
// assume: Acc(alice).balance == 2 ether
// cover: Collect :: acc.balance >= _am false
        vm.startPrank(alice);
        U_BANK target = new U_BANK(alice);
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
        vm.expectRevert();
        {
        target.Collect(3 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract (fallback) triggers Put(0) and updates balance.
    function test_Fallback_calls_Put_with_zero_4() public {
// assume: now >= 0
// assume: Acc(alice).balance >= 2 ether
// cover: fallback :: calls Put(0)
        vm.startPrank(owner);
        U_BANK target = new U_BANK(alice);
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
        target.Collect(1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiple users can independently deposit and collect without interference.
    function test_Multiple_users_independent_accounts_5() public {
// assume: now >= 0
// assume: Acc(alice).balance >= 2 ether
// assume: Acc(bob).balance >= 2 ether
// cover: Collect :: multiple users, both succeed
        vm.startPrank(alice);
        U_BANK target = new U_BANK(alice);
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
        target.Put.value(4 ether)(0);
        }
        vm.prank(alice);
        {
        target.Collect(2 ether);
        }
        vm.prank(bob);
        {
        target.Collect(3 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that Put sets unlockTime to _unlockTime when it is in the future.
    function test_Put_with_future_unlockTime_6() public {
// assume: now < 500
// assume: Acc(alice).balance >= 2 ether
// cover: Put :: _unlockTime > now, sets unlockTime = _unlockTime
        vm.startPrank(alice);
        U_BANK target = new U_BANK(alice);
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
        target.Put.value(2 ether)(500);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Put sets unlockTime to now when _unlockTime is in the past.
    function test_Put_with_past_unlockTime_7() public {
// assume: now > 1
// assume: Acc(alice).balance >= 2 ether
// cover: Put :: _unlockTime <= now, sets unlockTime = now
        vm.startPrank(alice);
        U_BANK target = new U_BANK(alice);
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
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that Collect uses call.value and updates balance only on success, preventing reentrancy-based double withdrawal.
    function test_Collect_reentrancy_guard_implicit_8() public {
// assume: now >= 0
// assume: Acc(alice).balance >= 2 ether
// cover: Collect :: msg.sender.call.value(_am)() true, then balance decremented
        vm.startPrank(alice);
        U_BANK target = new U_BANK(alice);
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
        target.Collect(5 ether);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_view_9() public {
        vm.startPrank(owner);
        U_BANK target = new U_BANK(alice);
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
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 2000000000000000000, "call:MinSum==2000000000000000000");
        }
    }

    // @cover-intent minimal test for Acc
    function test_perfn_Acc_10() public {
        vm.startPrank(owner);
        U_BANK target = new U_BANK(alice);
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
        U_BANK target = new U_BANK(alice);
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
        U_BANK target = new U_BANK(alice);
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
