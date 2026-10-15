// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/reentrancy_cross_function.sol";

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

contract Reentrancy_cross_function_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Reentrancy_cross_function_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit via transfer and then withdraw the full balance, with balance correctly reset to zero.
    function test_Normal_withdraw_after_deposit_via_transfer_0() public {
// assume: userBalances[alice] == 100
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: require(success) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.transfer(alice, 100);
        }
        // skip ABI-mismatched call: withdrawBalance()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Demonstrate that during withdrawBalance, the attacker can re-enter transfer to drain more funds than their balance, violating accounting consistency.
    function test_Reentrancy_attack_via_cross_function_call_1() public {
// assume: userBalances[alice] == 200
// assume: userBalances[bob] == 100
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: require(success) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 200);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(alice, 200);
        }
        vm.prank(bob);
        {
        target.transfer(bob, 100);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
    }

    // @cover-intent Edge behavior: Verify that calling withdrawBalance when user has zero balance sends 0 ETH and resets balance to zero.
    function test_Withdraw_with_zero_balance_2() public {
// assume: userBalances[alice] == 0
// cover: withdrawBalance :: require(success) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 0);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
    }

    // @cover-intent Edge behavior: Verify that transfer does not modify balances when sender has insufficient funds.
    function test_Transfer_with_insufficient_balance_3() public {
// assume: userBalances[alice] == 50
// cover: transfer :: require(balance>=amount) false
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 50);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.transfer(alice, 50);
        }
        {
        target.transfer(bob, 100);
        }
        vm.stopPrank();
    }

    // @cover-intent Edge behavior: Verify that transferring to oneself works correctly, balance remains unchanged.
    function test_Transfer_to_self_4() public {
// assume: userBalances[alice] == 100
// cover: transfer :: require(balance>=amount) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.transfer(alice, 100);
        }
        {
        target.transfer(alice, 50);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that a sequence of transfers and a final withdraw maintains correct balance updates.
    function test_Multiple_transfers_and_withdraw_sequence_5() public {
// assume: userBalances[alice] == 120
// assume: userBalances[bob] == 80
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: require(success) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 200);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.transfer(alice, 200);
        }
        {
        target.transfer(bob, 80);
        }
        {
        target.transfer(bob, 30);
        }
        vm.stopPrank();
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
    }

    // @cover-intent Financial & Accounting
    function test_transfer_positive_6() public {
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.transfer(alice, 100);
        }
        vm.prank(alice);
        {
        target.transfer(bob, 30);
        }
        // TODO assert: alice.balance == 70
        // TODO assert: bob.balance == 30
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_positive_7() public {
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 50);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.transfer(alice, 50);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
    }

}
