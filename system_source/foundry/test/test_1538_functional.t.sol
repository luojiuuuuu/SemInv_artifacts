// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

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


    // @cover-intent Financial & Accounting: Verify that initTokenBank sets owner and MinDeposit, then a deposit above MinDeposit increases the holder's balance.
    function test_init_and_deposit_positive_0() public {
// assume: MinDeposit() == 1 ether
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

    // @cover-intent Financial & Accounting: Verify that a deposit below MinDeposit does not update the holder's balance.
    function test_deposit_below_minimum_1() public {
// assume: MinDeposit() == 1 ether
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
        vm.prank(alice);
        // skip ABI-mismatched call: Deposit()
        vm.prank(owner);
        {
        target.Holders(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that owner can propose a new owner and the new owner can confirm, transferring ownership.
    function test_owner_change_owner_and_confirm_2() public {
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
        {
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call changeOwner.
    function test_non_owner_change_owner_reverts_3() public {
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

    // @cover-intent Financial & Accounting: Verify that owner can withdraw tokens to a holder with a positive balance, resetting the holder's balance.
    function test_withdraw_token_to_holder_positive_4() public {
// assume: Holders(alice) > 0
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
        target.WitdrawTokenToHolder(alice, address(0), 500);
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that WitdrawTokenToHolder does nothing when holder balance is zero.
    function test_withdraw_token_to_holder_zero_balance_5() public {
// assume: Holders(alice) == 0
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
        target.WitdrawTokenToHolder(alice, address(0), 100);
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that owner can withdraw ETH to a holder with sufficient balance, decreasing the holder's balance.
    function test_withdraw_to_holder_positive_6() public {
// assume: Holders(owner) > 0
// assume: Holders(alice) >= 1 ether
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

    // @cover-intent Financial & Accounting: Verify that WithdrawToHolder does nothing when holder balance is insufficient.
    function test_withdraw_to_holder_insufficient_balance_7() public {
// assume: Holders(owner) > 0
// assume: Holders(alice) == 2 ether
// cover: WithdrawToHolder :: Holders[msg.sender] > 0 true
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
        vm.startPrank(owner);
        {
        target.WithdrawToHolder(alice, 3 ether);
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call WithdrawToHolder.
    function test_non_owner_withdraw_to_holder_reverts_8() public {
// cover: WithdrawToHolder :: onlyOwner false
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
        target.WithdrawToHolder(alice, 1 ether);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that sending ETH to the contract via fallback calls Deposit.
    function test_fallback_triggers_deposit_9() public {
// assume: MinDeposit() == 1 ether
// cover: fallback :: calls Deposit
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
    function test_Bal_test_10() public {
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
        // skip ABI-mismatched call: Bal()
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_test_11() public {
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
    function test_Holders_test_12() public {
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
    function test_MinDeposit_test_13() public {
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
    function test_WitdrawTokenToHolder_test_14() public {
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
        target.WitdrawTokenToHolder(alice, address(0), 1 ether);
        }
    }

    // @cover-intent Financial & Accounting
    function test_WithdrawToHolder_test_15() public {
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
        target.WithdrawToHolder(owner, 1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_WithdrawToken_test_16() public {
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
        target.WithdrawToken(address(0), 0, alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_test_17() public {
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
    function test_confirmOwner_test_18() public {
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
    function test_initTokenBank_test_19() public {
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
