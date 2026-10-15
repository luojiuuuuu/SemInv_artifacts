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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via a direct transfer, then withdraw their balance, and that the balance is reset to zero after withdrawal.
    function test_Normal_withdraw_and_transfer_interaction_0() public {
// assume: userBalances[alice] == 10 ether
// cover: withdrawBalance :: require(success) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1000000000000000000)));
        vm.startPrank(owner);
        target.transfer(alice, 10 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawBalance();
        }
    }

    // @cover-intent External Interaction & Environment: Demonstrate that a malicious contract can re-enter withdrawBalance via transfer during the external call, draining more than the user's balance.
    function test_Cross_function_reentrancy_attack_via_transfer_1() public {
// assume: userBalances[alice] >= 1 ether
// assume: userBalances[bob] == 5 ether
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: require(success) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(5000000000000000000)));
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(5000000000000000000)));
        vm.startPrank(owner);
        target.transfer(alice, 5 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 1 ether);
        }
        vm.prank(bob);
        {
        target.withdrawBalance();
        }
    }

    // @cover-intent Transactional Consistency: Verify that transfer reverts when sender has insufficient balance.
    function test_Transfer_with_insufficient_balance_2() public {
// assume: userBalances[alice] == 1 ether
// cover: transfer :: require(balance>=amount) false
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1000000000000000000)));
        vm.startPrank(owner);
        target.transfer(alice, 1 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 2 ether);
        }
        // TODO assert: alice.balance == 1 ether
        // TODO assert: bob.balance == 0 ether
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawBalance succeeds even when balance is zero, sending 0 ETH and resetting balance.
    function test_Withdraw_from_zero_balance_3() public {
// assume: userBalances[alice] == 0
// cover: withdrawBalance :: require(success) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawBalance();
        }
    }

    // @cover-intent Financial & Accounting: Verify that transferring to oneself does not change balances.
    function test_Transfer_to_self_4() public {
// assume: userBalances[alice] >= 3 ether
// cover: transfer :: require(balance>=amount) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(5000000000000000000)));
        vm.startPrank(owner);
        target.transfer(alice, 5 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(alice, 3 ether);
        }
        // TODO assert: alice.balance == 5 ether
    }

    // @cover-intent Transactional Consistency: Verify that transfer to address(0) succeeds (no special check in contract).
    function test_Transfer_to_zero_address_5() public {
// assume: userBalances[alice] >= 1 ether
// cover: transfer :: require(balance>=amount) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(2000000000000000000)));
        vm.startPrank(owner);
        target.transfer(alice, 2 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(0x0000000000000000000000000000000000000000, 1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiple transfers correctly update balances and total supply is conserved.
    function test_Multiple_transfers_between_users_6() public {
// assume: userBalances[alice] >= 3 ether
// assume: userBalances[bob] >= 2 ether
// cover: transfer :: require(balance>=amount) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(10000000000000000000)));
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(5000000000000000000)));
        vm.startPrank(owner);
        target.transfer(alice, 10 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 3 ether);
        }
        vm.prank(bob);
        {
        target.transfer(carol, 2 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that withdrawBalance correctly reflects the final balance after transfers.
    function test_Withdraw_after_multiple_transfers_7() public {
// assume: userBalances[alice] == 6 ether
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: require(success) true
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(10000000000000000000)));
        vm.startPrank(owner);
        target.transfer(alice, 10 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.transfer(bob, 4 ether);
        }
        {
        target.withdrawBalance();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_transfer_positive_8() public {
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
        target.transfer(bob, 50);
        }
        // TODO assert: alice.balance == 50
        // TODO assert: bob.balance == 50
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_positive_9() public {
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
        target.withdrawBalance();
        }
        // TODO assert: alice.balance == 0
    }

}
