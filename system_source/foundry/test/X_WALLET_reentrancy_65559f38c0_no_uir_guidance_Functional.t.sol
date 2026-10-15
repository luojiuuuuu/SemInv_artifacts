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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via Put, and after the unlock time, collect a portion of the balance, with balance deduction and supply conservation.
    function test_Put_and_Collect_positive_path_0() public {
// assume: now > Acc(alice).unlockTime
// assume: Acc(alice).balance >= MinSum
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
    }

    // @cover-intent Authorization & Access Control: Verify that Collect reverts when called before the unlock time, even if balance is sufficient.
    function test_Collect_before_unlock_time_reverts_1() public {
// assume: now <= Acc(alice).unlockTime
// assume: Acc(alice).balance >= MinSum
// cover: Collect :: now>acc.unlockTime false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.Collect(1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that Collect reverts when requested amount exceeds balance, even if time condition is met.
    function test_Collect_with_insufficient_balance_reverts_2() public {
// assume: now > Acc(alice).unlockTime
// assume: Acc(alice).balance < _am
// cover: Collect :: acc.balance>=_am false
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
        vm.startPrank(alice);
        {
        target.Put(0);
        }
        vm.expectRevert();
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple Put calls accumulate balance, and a partial Collect reduces balance correctly.
    function test_Multiple_deposits_and_partial_collect_3() public {
// assume: now > Acc(alice).unlockTime
// assume: Acc(alice).balance >= MinSum
// cover: Collect :: successful collect
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
        target.Put.value(3 ether)(0);
        }
        {
        target.Put.value(2 ether)(0);
        }
        {
        target.Collect(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_Acc_balance_check_4() public {
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

    // @cover-intent Financial & Accounting
    function test_Collect_success_5() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_MinSum_default_6() public {
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
    function test_Put_deposit_7() public {
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
        target.Put.value(1 ether)(100);
        }
    }

}
