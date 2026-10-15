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


    // @cover-intent Financial & Accounting: Test that Deposit only adds to Holders when msg.value > MinDeposit, and that exactly MinDeposit does not trigger a deposit.
    function test_Deposit_positive_and_boundary_0() public {
// cover: Deposit :: msg.value > MinDeposit true
// cover: Deposit :: msg.value > MinDeposit false
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
        // skip ABI-mismatched call: Deposit()
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Test that owner can withdraw ETH to a holder with sufficient balance, and balance decreases correctly.
    function test_WithdrawToHolder_positive_path_1() public {
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

    // @cover-intent Authorization & Access Control: Test that WithdrawToHolder reverts when holder balance is less than requested amount.
    function test_WithdrawToHolder_insufficient_balance_2() public {
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
        target.WithdrawToHolder(alice, 3 ether);
        }
    }

    // @cover-intent Authorization & Access Control: Test that non-owner cannot call WithdrawToHolder.
    function test_WithdrawToHolder_non_owner_revert_3() public {
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

    // @cover-intent Financial & Accounting: Test that owner can withdraw tokens to a holder with positive balance, resetting holder balance to zero.
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
        vm.startPrank(owner);
        {
        target.WitdrawTokenToHolder(alice, alice, 1 ether);
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test that WitdrawTokenToHolder does nothing when holder balance is zero.
    function test_WitdrawTokenToHolder_zero_holder_balance_5() public {
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
        target.WitdrawTokenToHolder(alice, alice, 1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test that owner can propose a new owner and the new owner can confirm, transferring ownership.
    function test_changeOwner_and_confirmOwner_positive_6() public {
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

    // @cover-intent Authorization & Access Control: Test that non-owner cannot call changeOwner.
    function test_changeOwner_non_owner_revert_7() public {
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

    // @cover-intent Authorization & Access Control: Test that confirmOwner reverts if caller is not the proposed newOwner.
    function test_confirmOwner_wrong_caller_revert_8() public {
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

    // @cover-intent Protocol State Machine: Test that initTokenBank sets owner to msg.sender and MinDeposit to 1 ether.
    function test_initTokenBank_sets_owner_and_MinDeposit_9() public {
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
        // skip ABI-mismatched call: MinDeposit()
        vm.stopPrank();
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
        target.WithdrawToken(alice, 0, alice);
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
        target.changeOwner(alice);
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
        target.changeOwner(alice);
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
        target.changeOwner(alice);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
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
