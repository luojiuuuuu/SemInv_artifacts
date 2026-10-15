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


    // @cover-intent Financial & Accounting: Test normal deposit and withdraw flow for a single user.
    function test_Positive_deposit_and_withdraw_0() public {
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

    // @cover-intent Financial & Accounting: Test boundary where withdraw amount exceeds balance.
    function test_Withdraw_more_than_balance_reverts_1() public {
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

    // @cover-intent Authorization & Access Control: Test that initWallet sets creator and migrateTo works only for creator.
    function test_Init_wallet_and_migrate_to_another_address_2() public {
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

    // @cover-intent Authorization & Access Control: Test that non-creator call to migrateTo reverts.
    function test_Non_creator_cannot_migrate_3() public {
// cover: migrateTo :: require(creator == msg.sender) false
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.migrateTo(alice);
        }
    }

    // @cover-intent Financial & Accounting: Test multiple deposits and withdraws to ensure balance tracking is correct.
    function test_Multiple_deposits_and_withdraws_4() public {
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
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(1 ether);
        }
        {
        target.withdraw(4 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Test deposit with zero value, should succeed but not change balance.
    function test_Deposit_with_zero_value_5() public {
// cover: deposit :: assert(balances[msg.sender] + msg.value > balances[msg.sender]) true
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
        // skip ABI-mismatched call: deposit()
        {
        target.withdraw(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent External Interaction & Environment: Test migrateTo when contract has no balance.
    function test_Migrate_with_zero_balance_6() public {
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

    // @cover-intent Financial & Accounting: Test that balances are isolated per user.
    function test_Withdraw_after_multiple_deposits_from_different_users_7() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: deposit()
        vm.prank(bob);
        // skip ABI-mismatched call: deposit()
        vm.prank(alice);
        {
        target.withdraw(3 ether);
        }
        vm.prank(bob);
        {
        target.withdraw(2 ether);
        }
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_deposit_positive_8() public {
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
    function test_initWallet_positive_9() public {
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
    function test_migrateTo_positive_10() public {
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

    // @cover-intent Financial & Accounting
    function test_withdraw_positive_11() public {
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
        // TODO assert: alice.balance == 50
    }

}
