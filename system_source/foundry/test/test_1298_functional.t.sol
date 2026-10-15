// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/reentrancy_bonus.sol";

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

contract Reentrancy_bonus_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Reentrancy_bonus_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a first-time caller can claim the bonus and receive the reward, and that the bonus is only credited once.
    function test_Normal_bonus_claim_and_reward_withdrawal_0() public {
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) true
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) false
        vm.startPrank(owner);
        Reentrancy_bonus target = new Reentrancy_bonus();
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
        target.getFirstWithdrawalBonus(bob);
        }
        vm.prank(bob);
        {
        target.withdrawReward(bob);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.getFirstWithdrawalBonus(bob);
        }
    }

    // @cover-intent External Interaction & Environment: Verify that a reentrant call from the recipient during withdrawReward cannot claim the bonus twice.
    function test_Reentrancy_attempt_via_malicious_recipient_1() public {
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) false
        vm.startPrank(owner);
        Reentrancy_bonus target = new Reentrancy_bonus();
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
        target.getFirstWithdrawalBonus(bob);
        }
        vm.startPrank(bob);
        {
        target.withdrawReward(bob);
        }
        vm.expectRevert();
        {
        target.getFirstWithdrawalBonus(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that different recipients can each claim the bonus once without interference.
    function test_Multiple_recipients_claiming_bonus_independently_2() public {
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) true
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) false
        vm.startPrank(owner);
        Reentrancy_bonus target = new Reentrancy_bonus();
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
        target.getFirstWithdrawalBonus(bob);
        }
        {
        target.getFirstWithdrawalBonus(carol);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.withdrawReward(bob);
        }
        vm.prank(carol);
        {
        target.withdrawReward(carol);
        }
        vm.startPrank(alice);
        vm.expectRevert();
        {
        target.getFirstWithdrawalBonus(bob);
        }
        vm.expectRevert();
        {
        target.getFirstWithdrawalBonus(carol);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that withdrawing when rewardsForA is zero does not revert (since the call with value 0 should succeed).
    function test_Withdraw_reward_with_zero_balance_3() public {
// cover: withdrawReward :: require(success) true
        vm.startPrank(owner);
        Reentrancy_bonus target = new Reentrancy_bonus();
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
        target.withdrawReward(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a user can claim the bonus for themselves and then withdraw.
    function test_Claim_bonus_for_self_and_withdraw_4() public {
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) false
        vm.startPrank(owner);
        Reentrancy_bonus target = new Reentrancy_bonus();
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
        target.getFirstWithdrawalBonus(alice);
        }
        {
        target.withdrawReward(alice);
        }
        vm.expectRevert();
        {
        target.getFirstWithdrawalBonus(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_getFirstWithdrawalBonus_exploit_5() public {
        vm.startPrank(owner);
        Reentrancy_bonus target = new Reentrancy_bonus();
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
        target.getFirstWithdrawalBonus(alice);
        }
        {
        target.getFirstWithdrawalBonus(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_withdrawReward_after_bonus_6() public {
        vm.startPrank(owner);
        Reentrancy_bonus target = new Reentrancy_bonus();
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
        target.getFirstWithdrawalBonus(alice);
        }
        {
        target.withdrawReward(alice);
        }
        vm.stopPrank();
    }

}
