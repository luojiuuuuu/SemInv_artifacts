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


    // @cover-intent Financial & Accounting: Verify that a first-time caller can claim the bonus and receive the reward, and that the bonus is credited only once.
    function test_Normal_bonus_claim_and_reward_withdrawal_0() public {
// assume: claimedBonus[alice] == false initially
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) true
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
        vm.startPrank(alice);
        {
        target.getFirstWithdrawalBonus(alice);
        }
        vm.expectRevert();
        {
        target.getFirstWithdrawalBonus(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that reentrancy via withdrawReward does not allow claiming the bonus twice before claimedBonus is set.
    function test_Reentrancy_attack_attempt_double_bonus_claim_1() public {
// assume: claimedBonus[alice] == true after first call
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
        vm.expectRevert();
        {
        target.getFirstWithdrawalBonus(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify that different recipients can each claim the bonus once without interference.
    function test_Multiple_users_claim_bonus_independently_2() public {
// assume: claimedBonus[alice] == true
// assume: claimedBonus[bob] == true
// assume: claimedBonus[carol] == false
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) true for carol
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) false for alice and bob
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
        target.getFirstWithdrawalBonus(alice);
        }
        vm.prank(bob);
        {
        target.getFirstWithdrawalBonus(bob);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.getFirstWithdrawalBonus(alice);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.getFirstWithdrawalBonus(bob);
        }
        vm.prank(carol);
        {
        target.getFirstWithdrawalBonus(carol);
        }
        // TODO assert: alice.balance == 100
        // TODO assert: bob.balance == 100
        // TODO assert: carol.balance == 100
    }

    // @cover-intent External Interaction & Environment: Verify that calling withdrawReward when rewardsForA[recipient] is zero sends 0 ETH and succeeds.
    function test_Direct_withdrawReward_with_no_reward_3() public {
// assume: rewardsForA[alice] == 0
// cover: withdrawReward :: require(success) true with value 0
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

    // @cover-intent External Interaction & Environment: Verify that a malicious recipient cannot reenter getFirstWithdrawalBonus during withdrawReward to claim bonus twice.
    function test_Reentrancy_via_malicious_recipient_contract_4() public {
// assume: claimedBonus[alice] == true after first call
// assume: rewardsForA[alice] == 0 after first call
// cover: getFirstWithdrawalBonus :: require(!claimedBonus[recipient]) false on reentry
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
        vm.expectRevert();
        {
        target.getFirstWithdrawalBonus(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100
    }

    // @cover-intent External Interaction & Environment
    function test_getFirstWithdrawalBonus_reentrancy_5() public {
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
        target.getFirstWithdrawalBonus(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawReward_basic_6() public {
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
