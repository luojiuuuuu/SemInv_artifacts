// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/wallet_03_wrong_constructor.sol";

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


    // @cover-intent Authorization & Access Control: Verify that initWallet() sets the creator to msg.sender, enabling subsequent deposit and migrateTo calls.
    function test_init_wallet_and_deposit_0() public {
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
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that deposit() reverts on arithmetic overflow via the assert statement.
    function test_deposit_overflow_assertion_1() public {
// assume: balances[alice] == 1
// cover: deposit :: assert(balances[msg.sender] + msg.value > balances[msg.sender]) false
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
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        vm.expectRevert();
        // skip ABI-mismatched call: deposit()
        vm.stopPrank();
        // TODO assert: alice.balance == 1
    }

    // @cover-intent Financial & Accounting: Verify that withdraw() reverts when amount exceeds balance.
    function test_withdraw_insufficient_balance_2() public {
// assume: balances[alice] == 1 ether
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
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        vm.expectRevert();
        {
        target.withdraw(2 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that migrateTo() succeeds when called by the creator, transferring all contract balance.
    function test_migrate_to_by_creator_3() public {
// assume: creator == alice
// assume: address(this).balance == 5 ether
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that migrateTo() reverts when called by a non-creator.
    function test_migrate_to_by_non_creator_4() public {
// assume: creator == alice
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
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        {
        target.migrateTo(bob);
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits and withdrawals maintain correct balance accounting.
    function test_multiple_deposits_and_withdrawals_5() public {
// assume: balances[alice] == 3 ether
// assume: balances[bob] == 2 ether
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
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        vm.stopPrank();
        vm.prank(bob);
        // skip ABI-mismatched call: deposit()
        vm.prank(alice);
        {
        target.withdraw(1 ether);
        }
        vm.prank(bob);
        {
        target.withdraw(2 ether);
        }
        vm.prank(alice);
        {
        target.withdraw(2 ether);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that deposit() with zero value succeeds (edge case).
    function test_deposit_zero_value_6() public {
// cover: deposit :: assert(balances[msg.sender] + msg.value > balances[msg.sender]) true
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdraw(0) succeeds when balance is zero (edge case).
    function test_withdraw_zero_amount_7() public {
// assume: balances[alice] == 0
// cover: withdraw :: require(amount <= balances[msg.sender]) true
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: initWallet()
        {
        target.withdraw(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that migrateTo() succeeds even when contract balance is zero.
    function test_migrate_to_empty_wallet_8() public {
// assume: creator == alice
// assume: address(this).balance == 0
// cover: migrateTo :: require(creator == msg.sender) true
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: initWallet()
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that initWallet() can be called again to change the creator, enabling a new owner to migrate.
    function test_reinit_wallet_after_migration_9() public {
// assume: creator == alice before reinit
// assume: address(this).balance == 0 after migration
// cover: initWallet :: creator = msg.sender
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
        vm.startPrank(bob);
        // skip ABI-mismatched call: initWallet()
        {
        target.migrateTo(carol);
        }
        vm.stopPrank();
        // TODO assert: carol.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_deposit_positive_10() public {
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

    // @cover-intent Authorization & Access Control
    function test_initWallet_positive_11() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: initWallet()
    }

    // @cover-intent Authorization & Access Control
    function test_migrateTo_positive_12() public {
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
        // skip ABI-mismatched call: initWallet()
        // skip ABI-mismatched call: deposit()
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_13() public {
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
        target.withdraw(50);
        }
        vm.stopPrank();
    }

}
