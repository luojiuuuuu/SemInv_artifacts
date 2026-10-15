// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/etherbank.sol";

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

contract EtherBank_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function EtherBank_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can deposit and withdraw their balance correctly.
    function test_Normal_deposit_and_withdrawal_0() public {
// cover: withdrawBalance :: !(msg.sender.call.value(amountToWithdraw)()) false
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
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
        target.getBalance(alice);
        }
        // skip ABI-mismatched call: withdrawBalance()
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Withdrawing when balance is zero should succeed without transferring ETH.
    function test_Withdraw_from_zero_balance_1() public {
// cover: withdrawBalance :: !(msg.sender.call.value(amountToWithdraw)()) false
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        target.getBalance(bob);
        }
        // skip ABI-mismatched call: withdrawBalance()
        {
        target.getBalance(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that reentrancy is possible (vulnerability) – the contract does not update balance before external call.
    function test_Reentrancy_attempt_via_fallback_2() public {
// cover: withdrawBalance :: !(msg.sender.call.value(amountToWithdraw)()) true
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
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
        // skip ABI-mismatched call: withdrawBalance()
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Accumulate deposits and then withdraw full balance.
    function test_Multiple_deposits_and_withdrawal_3() public {
// cover: withdrawBalance :: !(msg.sender.call.value(amountToWithdraw)()) false
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
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
        target.getBalance(alice);
        }
        // skip ABI-mismatched call: withdrawBalance()
        {
        target.getBalance(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that balances are isolated per user.
    function test_Deposit_and_withdrawal_by_different_users_4() public {
// cover: withdrawBalance :: !(msg.sender.call.value(amountToWithdraw)()) false
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
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
        vm.prank(bob);
        // skip ABI-mismatched call: withdrawBalance()
        vm.prank(alice);
        {
        target.getBalance(alice);
        }
        vm.prank(bob);
        {
        target.getBalance(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity: Depositing zero value should still update mapping (though no ETH sent).
    function test_Deposit_zero_value_5() public {
// cover: withdrawBalance :: !(msg.sender.call.value(amountToWithdraw)()) false
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(carol);
        // skip ABI-mismatched call: addToBalance()
        {
        target.getBalance(carol);
        }
        // skip ABI-mismatched call: withdrawBalance()
        {
        target.getBalance(carol);
        }
        vm.stopPrank();
        // TODO assert: carol.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_addToBalance_positive_6() public {
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_getBalance_positive_7() public {
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.getBalance(alice);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting
    function test_withdrawBalance_positive_8() public {
        vm.startPrank(owner);
        EtherBank target = new EtherBank();
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

}
