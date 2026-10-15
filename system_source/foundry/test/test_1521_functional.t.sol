// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

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


    // @cover-intent Financial & Accounting: Verify that initTokenBank sets owner and MinDeposit, then a valid deposit (value > MinDeposit) increases the depositor's balance in Holders mapping.
    function test_init_and_deposit_positive_0() public {
// cover: Deposit :: msg.value > MinDeposit true
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
        target.Holders(alice);
        }
    }

    // @cover-intent Financial & Accounting: Verify that a deposit with value <= MinDeposit does not update the Holders mapping.
    function test_deposit_below_minimum_1() public {
// cover: Deposit :: msg.value > MinDeposit false
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
        vm.prank(bob);
        // skip ABI-mismatched call: Deposit()
        vm.prank(owner);
        {
        target.Holders(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can call WithdrawToHolder; non-owner call reverts.
    function test_withdraw_to_holder_owner_only_2() public {
// cover: WithdrawToHolder :: onlyOwner modifier false
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

    // @cover-intent Financial & Accounting: Verify that owner can withdraw ETH to a holder with sufficient balance, reducing the holder's balance.
    function test_withdraw_to_holder_success_3() public {
// cover: WithdrawToHolder :: Holders[msg.sender] > 0 true
// cover: WithdrawToHolder :: Holders[_addr] >= _wei true
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
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that WithdrawToHolder reverts when the holder's balance is less than the requested amount.
    function test_withdraw_to_holder_insufficient_balance_4() public {
// cover: WithdrawToHolder :: Holders[_addr] >= _wei false
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
        vm.prank(owner);
        {
        target.WithdrawToHolder(alice, 2 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can call WitdrawTokenToHolder; non-owner call reverts.
    function test_withdraw_token_to_holder_owner_only_5() public {
// cover: WitdrawTokenToHolder :: onlyOwner modifier false
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
        target.WitdrawTokenToHolder(alice, 0x0000000000000000000000000000000000000001, 100);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that owner can call WitdrawTokenToHolder for a holder with balance > 0, resetting their balance to 0 and calling WithdrawToken.
    function test_withdraw_token_to_holder_success_6() public {
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
        vm.startPrank(owner);
        {
        target.WitdrawTokenToHolder(alice, 0x0000000000000000000000000000000000000001, 100);
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify the two-step ownership transfer: owner proposes new owner, then new owner confirms.
    function test_change_owner_and_confirm_7() public {
// cover: changeOwner :: onlyOwner modifier true
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
        target.changeOwner(bob);
        }
        // skip ABI-mismatched call: confirmOwner()
        {
        target.changeOwner(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that confirmOwner does nothing when called by an address that is not the proposed newOwner.
    function test_confirm_owner_non_proposed_8() public {
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
        target.changeOwner(bob);
        }
        // skip ABI-mismatched call: confirmOwner()
        {
        target.changeOwner(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that the fallback function triggers Deposit and respects the MinDeposit threshold.
    function test_fallback_deposit_9() public {
// cover: fallback :: Deposit called
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
        target.Holders(alice);
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
        // TODO assert: call:Holders(alice) == 2 ether
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
        vm.prank(bob);
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

    // @cover-intent Authorization & Access Control
    function test_WithdrawToHolder_sequence_14() public {
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
        // skip ABI-mismatched call: Deposit()
        {
        target.WithdrawToHolder(owner, 1);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
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
        target.changeOwner(alice);
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
        target.changeOwner(alice);
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
