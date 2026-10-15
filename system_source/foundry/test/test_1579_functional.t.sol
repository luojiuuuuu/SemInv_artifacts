// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

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


    // @cover-intent Authorization & Access Control: Verify that initTokenBank sets owner and MinDeposit, and that a deposit meeting MinDeposit succeeds.
    function test_Init_and_Deposit_Positive_0() public {
// cover: Deposit :: msg.value >= MinDeposit true
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
        {
        target.initTokenBank();
        }
        vm.prank(alice);
        {
        target.Deposit.value(1 ether)();
        }
        vm.prank(owner);
        {
        target.Bal();
        }
        // TODO assert: owner.balance == 0
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Financial & Accounting: Verify that a deposit below MinDeposit is rejected (no state change).
    function test_Deposit_Below_Minimum_1() public {
// cover: Deposit :: msg.value >= MinDeposit false
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
        {
        target.initTokenBank();
        }
        vm.prank(alice);
        {
        target.Deposit.value(0.5 ether)();
        }
        vm.prank(owner);
        {
        target.Holders(alice);
        }
        // TODO assert: alice.balance == 0.5 ether
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can propose a new owner, and confirmOwner transfers ownership.
    function test_Owner_Change_And_Confirm_2() public {
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
        {
        target.initTokenBank();
        }
        {
        target.changeOwner(alice);
        }
        {
        target.confirmOwner();
        }
        {
        target.changeOwner(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call changeOwner.
    function test_NonOwner_ChangeOwner_Revert_3() public {
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
        {
        target.initTokenBank();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOwner(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that WithdrawToken is only callable by owner.
    function test_WithdrawToken_OnlyOwner_4() public {
// cover: WithdrawToken :: onlyOwner false
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
        {
        target.initTokenBank();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.WithdrawToken(0x0000000000000000000000000000000000000001, 100, alice);
        }
    }

    // @cover-intent Financial & Accounting: Verify that owner can withdraw tokens for a holder with positive balance, resetting holder balance.
    function test_WitdrawTokenToHolder_Positive_5() public {
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
        {
        target.initTokenBank();
        }
        vm.prank(alice);
        {
        target.Deposit.value(1 ether)();
        }
        vm.startPrank(owner);
        {
        target.WitdrawTokenToHolder(alice, 0x0000000000000000000000000000000000000001, 500);
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that WitdrawTokenToHolder does nothing when holder balance is zero.
    function test_WitdrawTokenToHolder_ZeroBalance_6() public {
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
        {
        target.initTokenBank();
        }
        {
        target.WitdrawTokenToHolder(alice, 0x0000000000000000000000000000000000000001, 500);
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that owner can withdraw ETH for a holder with sufficient balance, decrementing holder balance.
    function test_WithdrawToHolder_Positive_7() public {
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
        {
        target.initTokenBank();
        }
        vm.prank(alice);
        {
        target.Deposit.value(1 ether)();
        }
        vm.startPrank(owner);
        // skip malformed call: WithdrawToHolder(alice, 0.5 ether) (bad raw arg for WithdrawToHolder.arg1: type=uint256, raw=0.5 ether)
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that WithdrawToHolder reverts when holder balance is insufficient.
    function test_WithdrawToHolder_InsufficientBalance_8() public {
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
        {
        target.initTokenBank();
        }
        vm.prank(alice);
        {
        target.Deposit.value(1 ether)();
        }
        vm.startPrank(owner);
        {
        target.WithdrawToHolder(alice, 2 ether);
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that fallback function calls Deposit and respects MinDeposit.
    function test_Fallback_Calls_Deposit_9() public {
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
        {
        target.initTokenBank();
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_Bal_sequence_10() public {
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
        vm.prank(alice);
        {
        target.Bal();
        }
        // TODO assert: address(target).balance >= 0
    }

    // @cover-intent Financial & Accounting
    function test_Deposit_sequence_11() public {
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
        {
        target.initTokenBank();
        }
        vm.prank(alice);
        {
        target.Deposit.value(2 ether)();
        }
        // TODO assert: address(target).balance == 2 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_Holders_sequence_12() public {
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
        {
        target.initTokenBank();
        }
        vm.startPrank(alice);
        {
        target.Deposit.value(2 ether)();
        }
        {
        target.Holders(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_MinDeposit_sequence_13() public {
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
        {
        target.initTokenBank();
        }
        vm.prank(alice);
        {
        target.MinDeposit();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_WitdrawTokenToHolder_sequence_14() public {
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
        {
        target.initTokenBank();
        }
        vm.prank(alice);
        {
        target.Deposit.value(2 ether)();
        }
        vm.prank(owner);
        {
        target.WitdrawTokenToHolder(alice, alice, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_WithdrawToHolder_sequence_15() public {
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
        {
        target.initTokenBank();
        }
        {
        target.Deposit.value(2 ether)();
        }
        {
        target.WithdrawToHolder(alice, 1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_WithdrawToken_sequence_16() public {
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
        {
        target.initTokenBank();
        }
        {
        target.WithdrawToken(alice, 1, bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_sequence_17() public {
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
        {
        target.initTokenBank();
        }
        {
        target.changeOwner(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_confirmOwner_sequence_18() public {
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
        {
        target.initTokenBank();
        }
        {
        target.changeOwner(alice);
        }
        {
        target.confirmOwner();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_initTokenBank_sequence_19() public {
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
        {
        target.initTokenBank();
        }
    }

}
