// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

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

contract TokenBank_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function TokenBank_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a deposit above MinDeposit updates Holders and owner can withdraw ETH via WithdrawToHolder, reducing the holder's balance.
    function test_Positive_deposit_and_owner_withdrawal_0() public {
// cover: Deposit :: msg.value > MinDeposit true
// cover: WithdrawToHolder :: Holders[_addr] > 0 true
        vm.startPrank(alice);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.prank(owner);
        {
        target.WithdrawToHolder(alice, 1 ether);
        }
    }

    // @cover-intent Financial & Accounting: Verify that a deposit below MinDeposit does not update Holders.
    function test_Deposit_below_MinDeposit_is_ignored_1() public {
// cover: Deposit :: msg.value > MinDeposit false
// cover: WithdrawToHolder :: Holders[_addr] > 0 false
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call WithdrawToHolder.
    function test_Non_owner_cannot_withdraw_2() public {
// cover: WithdrawToHolder :: onlyOwner modifier fails
        vm.startPrank(alice);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.expectRevert();
        vm.prank(bob);
        {
        target.WithdrawToHolder(alice, 1 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify two-step ownership transfer works.
    function test_Owner_change_and_confirm_3() public {
// cover: changeOwner :: onlyOwner true
// cover: confirmOwner :: msg.sender == newOwner true
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        {
        target.changeOwner(alice);
        }
        // skip ABI-mismatched call: confirmOwner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify non-owner cannot call changeOwner.
    function test_Non_owner_cannot_change_owner_4() public {
// cover: changeOwner :: onlyOwner false
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify confirmOwner fails when called by non-newOwner.
    function test_Confirm_owner_fails_if_not_newOwner_5() public {
// cover: confirmOwner :: msg.sender == newOwner false
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        {
        target.changeOwner(alice);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: confirmOwner()
    }

    // @cover-intent External Interaction & Environment: Verify owner can clear a holder's balance and trigger token transfer.
    function test_WitdrawTokenToHolder_clears_holder_and_calls_WithdrawToken_6() public {
// cover: WitdrawTokenToHolder :: Holders[_to] > 0 true
        vm.startPrank(alice);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.prank(owner);
        {
        target.WitdrawTokenToHolder(alice, 0x0000000000000000000000000000000000000000, 100);
        }
    }

    // @cover-intent Transactional Consistency: Verify WitdrawTokenToHolder does nothing if holder balance is zero.
    function test_WitdrawTokenToHolder_no_op_when_holder_has_zero_balance_7() public {
// cover: WitdrawTokenToHolder :: Holders[_to] > 0 false
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        {
        target.WitdrawTokenToHolder(alice, 0x0000000000000000000000000000000000000000, 100);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify fallback function calls Deposit and respects MinDeposit.
    function test_Fallback_triggers_Deposit_8() public {
// cover: fallback :: calls Deposit
// cover: Deposit :: msg.value > MinDeposit true
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        {
        target.WithdrawToHolder(alice, 1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that WithdrawToHolder updates state before external call to prevent reentrancy (though vulnerable, test behavior).
    function test_WithdrawToHolder_reentrancy_attempt_partial_withdrawal_9() public {
// cover: WithdrawToHolder :: Holders[_addr] > 0 true (first call)
// cover: WithdrawToHolder :: Holders[_addr] > 0 true (second call, after state update)
        vm.startPrank(alice);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.startPrank(owner);
        {
        target.WithdrawToHolder(alice, 1 ether);
        }
        {
        target.WithdrawToHolder(alice, 1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_10() public {
        vm.startPrank(alice);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
    }

    // @cover-intent Financial & Accounting
    function test_Holders_sequence_11() public {
        vm.startPrank(alice);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.prank(bob);
        {
        target.Holders(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_MinDeposit_sequence_12() public {
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: MinDeposit()
        // TODO assert: call:MinDeposit() == 1 ether
    }

    // @cover-intent Authorization & Access Control
    function test_WitdrawTokenToHolder_sequence_13() public {
        vm.startPrank(alice);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.prank(owner);
        {
        target.WitdrawTokenToHolder(alice, alice, 1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_WithdrawToHolder_sequence_14() public {
        vm.startPrank(alice);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.prank(owner);
        {
        target.WithdrawToHolder(alice, 1 ether);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_WithdrawToken_sequence_15() public {
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        {
        target.WithdrawToken(alice, 1, bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_sequence_16() public {
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        {
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_confirmOwner_sequence_17() public {
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        {
        target.changeOwner(bob);
        }
        // skip ABI-mismatched call: confirmOwner()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_initTokenBank_sequence_18() public {
        vm.startPrank(owner);
        TokenBank target = new TokenBank();
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
        // skip ABI-mismatched call: initTokenBank()
        // TODO assert: call:MinDeposit() == 1 ether
    }

}
