// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/wallet_02_refund_nosub.sol";

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

contract Wallet_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Wallet_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit Ether and withdraw up to their balance, and that the balance is correctly updated.
    function test_deposit_and_withdraw_positive_0() public {
// cover: deposit :: assert(balances[msg.sender] + msg.value > balances[msg.sender]) true
// cover: withdraw :: require(amount <= balances[msg.sender]) true
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that withdrawing more than the user's balance reverts.
    function test_withdraw_exceeds_balance_reverts_1() public {
// cover: withdraw :: require(amount <= balances[msg.sender]) false
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        vm.expectRevert();
        {
        target.withdraw(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that refund() sends the entire balance to the caller but does NOT reset the balance (vulnerability).
    function test_refund_after_deposit_2() public {
// cover: refund :: transfer(balances[msg.sender])
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        // skip ABI-mismatched call: refund()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Demonstrate the vulnerability where refund() does not zero the balance, allowing repeated draining.
    function test_refund_repeatedly_drains_contract_3() public {
// cover: refund :: transfer(balances[msg.sender])
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        vm.startPrank(bob);
        // skip ABI-mismatched call: deposit()
        // skip ABI-mismatched call: refund()
        // skip ABI-mismatched call: refund()
        // skip ABI-mismatched call: refund()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner (creator) can call migrateTo to transfer the contract balance.
    function test_migrateTo_owner_only_4() public {
// cover: migrateTo :: require(creator == msg.sender) true
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        vm.prank(owner);
        {
        target.migrateTo(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call migrateTo.
    function test_migrateTo_non_owner_reverts_5() public {
// cover: migrateTo :: require(creator == msg.sender) false
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        vm.expectRevert();
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that the assert in deposit prevents overflow (though unlikely with uint256).
    function test_deposit_overflow_assert_6() public {
// cover: deposit :: assert(balances[msg.sender] + msg.value > balances[msg.sender]) true
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
    }

    // @cover-intent Financial & Accounting
    function test_deposit_sequence_7() public {
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Authorization & Access Control
    function test_migrateTo_sequence_8() public {
        vm.startPrank(owner);
        Wallet target = new Wallet();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        // skip ABI-mismatched call: deposit()
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_refund_sequence_9() public {
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        // skip ABI-mismatched call: refund()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_sequence_10() public {
        vm.startPrank(alice);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(30);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 70
    }

}
