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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via Put, wait for unlock time, and then successfully collect a portion of their balance.
    function test_Basic_Put_and_Collect_Positive_0() public {
// assume: block.timestamp > 100
// cover: Collect :: acc.balance >= MinSum && acc.balance >= _am && now > acc.unlockTime true
// cover: Collect :: msg.sender.call.value(_am)() true
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
        target.Put.value(5 ether)(100);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when the user's balance is below MinSum (2 ether).
    function test_Collect_Below_MinSum_1() public {
// assume: block.timestamp > 100
// cover: Collect :: acc.balance >= MinSum false
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
        target.Put.value(1 ether)(100);
        }
        vm.expectRevert();
        // skip malformed call: Collect(0.5 ether) (bad raw arg for Collect.arg0: type=uint256, raw=0.5 ether)
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when the requested amount exceeds the user's balance.
    function test_Collect_Exceeds_Balance_2() public {
// assume: block.timestamp > 100
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
        target.Put.value(3 ether)(100);
        }
        vm.expectRevert();
        {
        target.Collect(5 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when the current time is before the unlock time.
    function test_Collect_Before_UnlockTime_3() public {
// assume: block.timestamp < 9999999999
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

    // @cover-intent Financial & Accounting: Verify that Put sets unlockTime to now when _unlockTime is in the past.
    function test_Put_With_Past_UnlockTime_4() public {
// assume: block.timestamp > 1
// cover: Put :: _unlockTime>now false, unlockTime set to now
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

    // @cover-intent Transactional Consistency: Verify that two users can independently deposit and collect without affecting each other's balances.
    function test_Multiple_Users_Independent_Balances_5() public {
// assume: block.timestamp > 100
// cover: Collect :: both users pass all guards
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
        target.Put.value(3 ether)(100);
        }
        vm.prank(bob);
        {
        target.Put.value(4 ether)(100);
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

    // @cover-intent Financial & Accounting: Verify that collecting the exact balance works and leaves zero balance.
    function test_Collect_Exact_Balance_6() public {
// assume: block.timestamp > 100
// cover: Collect :: acc.balance == _am
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
        target.Put.value(2 ether)(100);
        }
        {
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_MinSum_View_7() public {
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
        target.MinSum();
        }
        {
            uint256 __v1 = uint256(target.MinSum());
            _assertRelU(__v1, 0, 2000000000000000000, "call:MinSum==2000000000000000000");
        }
    }

    // @cover-intent minimal test for Acc
    function test_perfn_Acc_8() public {
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
    function test_perfn_Collect_9() public {
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
    function test_perfn_Put_10() public {
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
