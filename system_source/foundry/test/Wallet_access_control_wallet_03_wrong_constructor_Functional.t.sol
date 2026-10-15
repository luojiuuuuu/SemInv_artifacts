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


    // @cover-intent Authorization & Access Control: Verify that initWallet sets creator to msg.sender, allowing subsequent deposit and withdraw operations.
    function test_init_wallet_and_deposit_0() public {
// assume: alice.balance >= 50
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
        {
        target.initWallet();
        }
        {
        target.deposit.value(50)();
        }
        {
        target.withdraw(30);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 20
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdraw reverts when amount exceeds the caller's balance.
    function test_withdraw_exceeds_balance_1() public {
// assume: balances[alice] == 10
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
        {
        target.initWallet();
        }
        {
        target.deposit.value(10)();
        }
        vm.expectRevert();
        {
        target.withdraw(20);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10
    }

    // @cover-intent Authorization & Access Control: Verify that migrateTo succeeds when called by the creator (set via initWallet).
    function test_migrate_to_by_creator_2() public {
// assume: creator == alice
// assume: address(this).balance >= 50
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
        {
        target.initWallet();
        }
        {
        target.deposit.value(50)();
        }
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that migrateTo reverts when called by a non-creator address.
    function test_migrate_to_by_non_creator_3() public {
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
        {
        target.initWallet();
        }
        {
        target.deposit.value(50)();
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        {
        target.migrateTo(carol);
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits and withdrawals correctly update balances and conserve total supply.
    function test_multiple_deposits_and_withdrawals_4() public {
// assume: alice.balance >= 45
// assume: bob.balance >= 25
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
        {
        target.initWallet();
        }
        {
        target.deposit.value(30)();
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.deposit.value(20)();
        }
        vm.prank(alice);
        {
        target.withdraw(10);
        }
        vm.prank(bob);
        {
        target.withdraw(5);
        }
        vm.prank(alice);
        {
        target.deposit.value(15)();
        }
        // TODO assert: alice.balance == 35
        // TODO assert: bob.balance == 15
    }

    // @cover-intent Resource & Execution Integrity: Verify that deposit with zero value succeeds (edge case).
    function test_deposit_zero_value_5() public {
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
        {
        target.initWallet();
        }
        {
        target.deposit();
        }
        {
        target.withdraw(0);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdraw reverts when balance is zero and amount is positive.
    function test_withdraw_zero_balance_6() public {
// assume: balances[alice] == 0
// cover: withdraw :: require(amount <= balances[msg.sender]) false
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
        {
        target.initWallet();
        }
        vm.expectRevert();
        {
        target.withdraw(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that initWallet can be called multiple times, overwriting the creator.
    function test_init_wallet_multiple_times_7() public {
// assume: bob.balance >= 50
// cover: initWallet :: creator = msg.sender
// cover: migrateTo :: require(creator == msg.sender) true
        vm.startPrank(bob);
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
        {
        target.initWallet();
        }
        vm.startPrank(bob);
        {
        target.initWallet();
        }
        {
        target.deposit.value(50)();
        }
        {
        target.migrateTo(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that deposit's assert prevents overflow (though unlikely with uint256, the assertion is tested).
    function test_deposit_overflow_assertion_8() public {
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
        {
        target.initWallet();
        }
        {
        target.deposit.value(1)();
        }
        vm.expectRevert();
        {
        target.deposit.value(115792089237316195423570985008687907853269984665640564039457584007913129639935)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1
    }

    // @cover-intent External Interaction & Environment: Verify that migrateTo works even when wallet balance is zero.
    function test_migrate_to_empty_wallet_9() public {
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
        {
        target.initWallet();
        }
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 0
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
        {
        target.deposit.value(100)();
        }
        // TODO assert: alice.balance == 100
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
        {
        target.initWallet();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_migrateTo_positive_12() public {
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
        {
        target.initWallet();
        }
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance >= 0
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
        {
        target.deposit.value(100)();
        }
        {
        target.withdraw(50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50
    }

}
