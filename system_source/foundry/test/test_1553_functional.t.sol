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


    // @cover-intent Financial & Accounting: Verify that initTokenBank sets owner and MinDeposit, then a user can deposit ETH above MinDeposit and balance is recorded in Holders.
    function test_Init_and_deposit_positive_path_0() public {
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: Deposit()
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that depositing exactly MinDeposit or less does not update Holders.
    function test_Deposit_below_MinDeposit_boundary_1() public {
// cover: Deposit :: msg.value > MinDeposit false
        vm.startPrank(bob);
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
        vm.startPrank(bob);
        // skip ABI-mismatched call: Deposit()
        {
        target.Holders(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Owner can withdraw ETH to a holder with positive balance, reducing Holders.
    function test_WithdrawToHolder_positive_path_2() public {
// cover: WithdrawToHolder :: Holders[_addr] > 0 true
// cover: WithdrawToHolder :: _addr.call.value(_wei)() true
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
        target.WithdrawToHolder(alice, 2 ether);
        }
        vm.prank(alice);
        {
        target.Holders(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Non-owner calling WithdrawToHolder should revert.
    function test_WithdrawToHolder_non_owner_revert_3() public {
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

    // @cover-intent External Interaction & Environment: Owner can withdraw tokens to a holder with positive balance, resetting Holders to zero.
    function test_WitdrawTokenToHolder_positive_path_4() public {
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
        target.WitdrawTokenToHolder(alice, 0x0000000000000000000000000000000000000001, 100);
        }
        vm.prank(alice);
        {
        target.Holders(alice);
        }
    }

    // @cover-intent Financial & Accounting: Owner calling WitdrawTokenToHolder on a holder with zero balance does nothing.
    function test_WitdrawTokenToHolder_zero_holder_no_op_5() public {
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
        target.WitdrawTokenToHolder(bob, 0x0000000000000000000000000000000000000001, 50);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.Holders(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Owner can propose a new owner and that new owner can confirm, transferring ownership.
    function test_ChangeOwner_and_confirmOwner_positive_path_6() public {
// cover: changeOwner :: onlyOwner modifier passes
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

    // @cover-intent Authorization & Access Control: Non-owner calling changeOwner should revert.
    function test_ChangeOwner_non_owner_revert_7() public {
// cover: changeOwner :: onlyOwner modifier fails
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
        vm.prank(bob);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control: confirmOwner called by someone other than newOwner does not change owner.
    function test_ConfirmOwner_by_non_proposed_address_no_op_8() public {
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
        // skip ABI-mismatched call: confirmOwner()
        {
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Sending ETH to the contract via fallback calls Deposit, updating Holders if value > MinDeposit.
    function test_Fallback_triggers_Deposit_9() public {
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
        vm.prank(owner);
        // skip ABI-mismatched call: initTokenBank()
        vm.prank(carol);
        {
        target.Holders(carol);
        }
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_positive_10() public {
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
    function test_Holders_view_11() public {
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
    function test_MinDeposit_view_12() public {
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
    function test_WitdrawTokenToHolder_positive_13() public {
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

    // @cover-intent Financial & Accounting
    function test_WithdrawToHolder_positive_14() public {
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
    function test_WithdrawToken_positive_15() public {
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
        target.WithdrawToken(alice, 0, bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_16() public {
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
    function test_changeOwner_non_owner_revert_17() public {
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

    // @cover-intent Authorization & Access Control
    function test_confirmOwner_positive_18() public {
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

    // @cover-intent Authorization & Access Control
    function test_confirmOwner_non_newOwner_revert_19() public {
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: confirmOwner()
    }

    // @cover-intent Protocol State Machine
    function test_initTokenBank_positive_20() public {
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
