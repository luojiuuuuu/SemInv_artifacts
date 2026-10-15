// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/wallet_04_confused_sign.sol";

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


    // @cover-intent Financial & Accounting: Verify that a user can deposit and then withdraw their own balance correctly.
    function test_Deposit_and_withdraw_positive_path_0() public {
// cover: withdraw :: require(amount >= balances[msg.sender]) true
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
        target.deposit.value(5 ether)();
        }
        {
        target.withdraw(5 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 5 ether
    }

    // @cover-intent Authorization & Access Control: Verify that withdrawing more than the user's balance reverts due to the require guard.
    function test_Withdraw_more_than_balance_reverts_1() public {
// cover: withdraw :: require(amount >= balances[msg.sender]) false
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
        target.deposit.value(3 ether)();
        }
        vm.expectRevert();
        {
        target.withdraw(5 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 7 ether
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can migrate all funds to another address.
    function test_MigrateTo_by_owner_succeeds_2() public {
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
        vm.startPrank(owner);
        {
        target.deposit.value(5 ether)();
        }
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 5 ether
        // TODO assert: owner.balance == 5 ether
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call migrateTo.
    function test_MigrateTo_by_non_owner_reverts_3() public {
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
        vm.prank(owner);
        {
        target.deposit.value(5 ether)();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.migrateTo(bob);
        }
        // TODO assert: owner.balance == 5 ether
        // TODO assert: alice.balance == 10 ether
    }

    // @cover-intent Resource & Execution Integrity: Verify that deposit's assert prevents overflow (though practically impossible with large values).
    function test_Deposit_overflow_assertion_4() public {
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
        target.deposit.value(1 ether)();
        }
        vm.expectRevert();
        {
        target.deposit.value(115792089237316195423570985008687907853269984665640564039457584007913129639935 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 99 ether
    }

    // @cover-intent Financial & Accounting: Verify that multiple deposits and withdrawals maintain correct balances.
    function test_Multiple_deposits_and_withdrawals_5() public {
// cover: withdraw :: require(amount >= balances[msg.sender]) true
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
        target.deposit.value(5 ether)();
        }
        vm.prank(bob);
        {
        target.deposit.value(3 ether)();
        }
        vm.prank(alice);
        {
        target.withdraw(2 ether);
        }
        vm.prank(bob);
        {
        target.withdraw(3 ether);
        }
        vm.prank(alice);
        {
        target.withdraw(3 ether);
        }
        // TODO assert: alice.balance == 15 ether
        // TODO assert: bob.balance == 20 ether
    }

    // @cover-intent Financial & Accounting
    function test_deposit_sequence_6() public {
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
        target.deposit.value(1 ether)();
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_sequence_7() public {
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
        target.deposit.value(1 ether)();
        }
        {
        target.withdraw(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
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
        {
        target.deposit.value(1 ether)();
        }
        {
        target.migrateTo(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 1 ether
    }

}
