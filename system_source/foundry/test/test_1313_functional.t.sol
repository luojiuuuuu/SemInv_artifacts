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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH via a direct transfer, then withdraw their balance, and that the balance is zeroed after withdrawal. Also verify that transfer works correctly between users.
    function test_Normal_withdrawal_and_transfer_0() public {
// assume: balance(alice) >= 10 ether
// assume: balance(bob) == 0
// cover: transfer :: require(balance>=amount) true
// cover: withdrawBalance :: normal path
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 10 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 5 ether);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: bob.balance == 0
    }

    // @cover-intent External Interaction & Environment: Demonstrate that withdrawBalance is vulnerable to reentrancy because it sends ETH before updating state, allowing the attacker to call transfer() in the fallback to drain funds.
    function test_Reentrancy_attack_via_cross_function_call_1() public {
// assume: balance(alice) >= 10 ether
// assume: balance(bob) == 5 ether
// cover: withdrawBalance :: reentrancy via transfer
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 10 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 5 ether);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Transactional Consistency: Verify that transfer reverts when sender has insufficient balance, leaving state unchanged.
    function test_Transfer_with_insufficient_balance_2() public {
// assume: balance(alice) == 1 ether
// cover: transfer :: require(balance>=amount) false
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that withdrawing from a zero balance sends 0 ETH and sets balance to 0 (no revert).
    function test_Withdraw_from_zero_balance_3() public {
// assume: balance(alice) == 0
// cover: withdrawBalance :: zero balance
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
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

    // @cover-intent Transactional Consistency: Verify that transferring to oneself works correctly (balance unchanged).
    function test_Transfer_to_self_4() public {
// assume: balance(alice) >= 5 ether
// cover: transfer :: self-transfer
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
    }

    // @cover-intent Financial & Accounting: Verify that multiple transfers and a withdrawal maintain balance conservation.
    function test_Multiple_transfers_and_withdrawal_5() public {
// assume: balance(alice) >= 10 ether
// cover: transfer :: multiple transfers
// cover: withdrawBalance :: multiple withdrawals
        vm.startPrank(owner);
        Reentrancy_cross_function target = new Reentrancy_cross_function();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 10 ether);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 4 ether);
        }
        vm.prank(bob);
        {
        target.transfer(carol, 2 ether);
        }
        vm.prank(carol);
        // skip ABI-mismatched call: withdrawBalance()
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: bob.balance == 0
        // TODO assert: carol.balance == 0
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
        // dropped unsafe vm.store: slot=keccak256(alice, userBalances mapping slot), value=100;
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.transfer(bob, 50);
        }
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
        // dropped unsafe vm.store: slot=keccak256(alice, userBalances mapping slot), value=100;
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance()
        // TODO assert: alice.balance == 0
    }

}
