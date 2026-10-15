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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via Put, then collect a portion after unlock time, respecting MinSum and balance checks.
    function test_Basic_Put_and_Collect_flow_0() public {
// assume: now > 0
// assume: Acc(alice).balance >= 5 ether
// assume: MinSum() == 2 ether
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
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts if _am exceeds the user's balance, even if MinSum is met.
    function test_Collect_fails_when_amount_exceeds_balance_1() public {
// assume: Acc(alice).balance == 3 ether
// assume: MinSum() == 2 ether
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
        target.Put.value(3 ether)(0);
        }
        vm.expectRevert();
        {
        target.Collect(5 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts if now <= acc.unlockTime, even if balance conditions are met.
    function test_Collect_fails_before_unlock_time_2() public {
// assume: now < 9999999999
// assume: Acc(alice).balance == 3 ether
// assume: MinSum() == 2 ether
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
        target.Put.value(3 ether)(9999999999);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect with _am = 0 succeeds if balance >= MinSum and unlock time passed.
    function test_Collect_with_zero_amount_3() public {
// assume: now > 0
// assume: Acc(alice).balance >= 3 ether
// assume: MinSum() == 2 ether
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
        target.Put.value(3 ether)(0);
        }
        {
        target.Collect(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that two users can independently deposit and collect without interference.
    function test_Multiple_users_deposit_and_collect_independently_4() public {
// assume: now > 0
// assume: Acc(alice).balance == 3 ether
// assume: Acc(bob).balance == 4 ether
// assume: MinSum() == 2 ether
// cover: Collect :: both users pass all checks
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
        target.Collect(1 ether);
        }
        vm.prank(bob);
        {
        target.Collect(2 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that balance accumulates across multiple Put calls and can be collected partially.
    function test_Collect_after_multiple_deposits_5() public {
// assume: now > 0
// assume: Acc(alice).balance == 5 ether
// assume: MinSum() == 2 ether
// cover: Collect :: balance >= MinSum and >= _am
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
        {
        target.Put.value(3 ether)(0);
        }
        {
        target.Collect(4 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_MinSum_View_6() public {
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
        // TODO assert: call:MinSum() >= 2 ether
    }

    // @cover-intent minimal test for Acc
    function test_perfn_Acc_7() public {
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
    function test_perfn_Collect_8() public {
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
    function test_perfn_Put_9() public {
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
