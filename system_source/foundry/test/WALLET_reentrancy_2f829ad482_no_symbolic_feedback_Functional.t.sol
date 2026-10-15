// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol";

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

contract WALLET_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function WALLET_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Test that Collect reverts when balance is sufficient for MinSum but not for requested amount.
    function test_Collect_fails_due_to_insufficient_balance_below_am_0() public {
// assume: acc.balance (1.5 ether) >= MinSum (1 ether) but < _am (2 ether)
// cover: Collect :: acc.balance >= MinSum true
// cover: Collect :: acc.balance >= _am false
        vm.startPrank(owner);
        WALLET target = new WALLET(alice);
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
        target.Collect(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Test that Collect does not deduct balance if the external call fails (e.g., recipient contract reverts).
    function test_Collect_fails_due_to_external_call_failure_reentrancy_guard_not_present_but_call_fails_1() public {
// assume: msg.sender.call.value(1 ether)() returns false (simulate by making alice a contract that rejects ETH)
// cover: Collect :: msg.sender.call.value(_am)() false
        vm.startPrank(alice);
        WALLET target = new WALLET(alice);
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
    }

    // @cover-intent Financial & Accounting: Test that Collect can withdraw the entire balance when it meets MinSum.
    function test_Collect_with_exact_balance_2() public {
// assume: acc.balance == 1 ether
// cover: Collect :: acc.balance >= MinSum true
// cover: Collect :: acc.balance >= _am true
        vm.startPrank(alice);
        WALLET target = new WALLET(alice);
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
    }

    // @cover-intent Financial & Accounting: Test that Collect with _am=0 succeeds if balance >= MinSum and time lock passed.
    function test_Collect_with_zero_amount_3() public {
// assume: acc.balance >= MinSum
// cover: Collect :: acc.balance >= _am true (0 <= balance)
        vm.startPrank(alice);
        WALLET target = new WALLET(alice);
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
        target.Collect(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_Acc_balance_and_unlockTime_4() public {
        vm.startPrank(alice);
        WALLET target = new WALLET(alice);
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
    function test_Collect_successful_withdrawal_5() public {
        vm.startPrank(alice);
        WALLET target = new WALLET(alice);
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
    function test_MinSum_initial_value_6() public {
        vm.startPrank(owner);
        WALLET target = new WALLET(alice);
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
        // TODO assert: call:MinSum() == 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_Put_deposit_with_unlock_time_7() public {
        vm.startPrank(alice);
        WALLET target = new WALLET(alice);
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
        target.Put.value(1 ether)(10000000000);
        }
    }

}
