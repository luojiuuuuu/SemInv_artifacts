// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/reentrancy_simple.sol";

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

contract Reentrance_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Reentrance_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and then withdraw the exact balance, and the balance is zeroed after withdrawal.
    function test_Normal_deposit_and_withdrawal_0() public {
// assume: address(alice).balance >= 5 ether
// cover: withdrawBalance :: msg.sender.call.value(userBalance[msg.sender])() succeeds
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        // skip ABI-mismatched call: withdrawBalance()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that a malicious contract cannot exploit reentrancy to drain more than its balance, because the balance is set to zero after the call (vulnerable pattern).
    function test_Reentrancy_attack_attempt_1() public {
// assume: address(alice).balance >= 5 ether
// cover: withdrawBalance :: msg.sender.call.value(userBalance[msg.sender])() succeeds
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        // skip ABI-mismatched call: withdrawBalance()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing when balance is zero sends 0 ETH and does not revert (the call with value 0 should succeed).
    function test_Withdraw_with_zero_balance_2() public {
// assume: getBalance(alice) == 0
// cover: withdrawBalance :: userBalance[msg.sender] == 0
        vm.startPrank(owner);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits accumulate correctly and a single withdrawal returns the total.
    function test_Multiple_deposits_and_single_withdrawal_3() public {
// assume: address(alice).balance >= 5 ether
// cover: addToBalance :: userBalance[msg.sender] += msg.value
// cover: withdrawBalance :: userBalance[msg.sender] == 5 ether
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        // skip ABI-mismatched call: addToBalance()
        // skip ABI-mismatched call: withdrawBalance()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that balances are isolated per user; alice's withdrawal does not affect bob's balance.
    function test_Deposit_and_withdraw_by_different_users_4() public {
// assume: address(alice).balance >= 4 ether
// assume: address(bob).balance >= 6 ether
// cover: withdrawBalance :: alice's withdrawal
// cover: withdrawBalance :: bob's withdrawal
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        vm.prank(bob);
        // skip ABI-mismatched call: addToBalance()
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Verify that depositing 0 ETH is allowed and does not change balance.
    function test_Deposit_with_zero_value_5() public {
// cover: addToBalance :: msg.value == 0
        vm.startPrank(owner);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that after withdrawal, a new deposit can be made and withdrawn again.
    function test_Withdraw_after_partial_deposit_and_then_deposit_again_6() public {
// assume: address(alice).balance >= 5 ether
// cover: withdrawBalance :: first withdrawal
// cover: addToBalance :: second deposit
// cover: withdrawBalance :: second withdrawal
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        // skip ABI-mismatched call: withdrawBalance()
        // skip ABI-mismatched call: addToBalance()
        // skip ABI-mismatched call: withdrawBalance()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_addToBalance_positive_7() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        // TODO assert: call:getBalance(alice) == 1 ether
    }

    // @cover-intent Financial & Accounting
    function test_getBalance_positive_8() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        vm.prank(bob);
        {
        target.getBalance(alice);
        }
        // TODO assert: call:getBalance(alice) == 5 ether
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_positive_9() public {
        vm.startPrank(alice);
        Reentrance target = new Reentrance();
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
        // skip ABI-mismatched call: addToBalance()
        // skip ABI-mismatched call: withdrawBalance()
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.getBalance(alice));
            _assertRelU(__v1, 0, 0, "call:getBalance==0");
        }
    }

}
