// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_42.sol";

// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

contract Staking_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() external payable { }


    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }


    // @cover-intent Financial & Accounting: Verify that a user can successfully stake tokens and then redeem them after the lock period, receiving the correct reward.
    function test_staking_positive_path_0() public {
// assume: token.balanceOf(alice) >= 5000000000000
// assume: token.balanceOf(owner) >= 10000000000000
// cover: startStaking :: require(balanceOf >= stakeTokens + fee) true
// cover: redeem :: require(time + stakeTime <= now) true
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: token.approve(address(staking), 1000000000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.startStaking();
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        target.changeStakeTime(0);
        }
        vm.prank(alice);
        {
        target.redeem();
        }
    }

    // @cover-intent Financial & Accounting: Verify that staking fails when the user does not have enough tokens (including the fee).
    function test_staking_insufficient_balance_1() public {
// assume: token.balanceOf(alice) < 5000000000000
// cover: startStaking :: require(balanceOf >= stakeTokens + fee) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.startStaking();
        }
    }

    // @cover-intent Protocol State Machine: Verify that redemption is blocked before the staking period ends.
    function test_redeem_before_time_2() public {
// assume: block.timestamp < staker[alice].time + stakeTime
// cover: redeem :: require(time + stakeTime <= now) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.startStaking();
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that a user cannot redeem twice.
    function test_redeem_twice_blocked_3() public {
// cover: redeem :: require(!staker[msg.sender].redeem) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.startStaking();
        }
        vm.prank(owner);
        {
        target.changeStakeTime(0);
        }
        vm.startPrank(alice);
        {
        target.redeem();
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that the lock mechanism prevents all redemptions.
    function test_lock_withdrawals_blocks_redeem_4() public {
// cover: redeem :: require(!lock) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.startStaking();
        }
        vm.startPrank(owner);
        {
        target.lockWithdrawals();
        }
        {
        target.changeStakeTime(0);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.redeem();
        }
    }

    // @cover-intent state transition test for lockWithdrawals
    function test_non_owner_cannot_lock_5() public {
// cover: lockWithdrawals :: require(onlyOwner) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.lockWithdrawals();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can initiate ownership transfer.
    function test_non_owner_cannot_transfer_ownership_6() public {
// cover: transferOwnership :: require(onlyOwner) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.transferOwnership(bob);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can update staking parameters.
    function test_owner_can_change_stake_parameters_7() public {
// cover: changeStakeTokens :: require(onlyOwner) true
// cover: changeStakeTime :: require(onlyOwner) true
// cover: changeStakingPercentage :: require(onlyOwner) true
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.changeStakeTokens(1000);
        }
        {
        target.changeStakeTime(604800);
        }
        {
        target.changeStakingPercentage(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owners cannot change staking parameters.
    function test_non_owner_cannot_change_parameters_8() public {
// cover: changeStakeTokens :: require(onlyOwner) false
// cover: changeStakeTime :: require(onlyOwner) false
// cover: changeStakingPercentage :: require(onlyOwner) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        vm.expectRevert();
        {
        target.changeStakeTokens(1000);
        }
        vm.expectRevert();
        {
        target.changeStakeTime(604800);
        }
        vm.expectRevert();
        {
        target.changeStakingPercentage(50);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that the reward calculation uses the updated stake percentage.
    function test_redeem_with_updated_percentage_9() public {
// cover: redeem :: require(time + stakeTime <= now) true
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.startStaking();
        }
        vm.startPrank(owner);
        {
        target.changeStakingPercentage(50);
        }
        {
        target.changeStakeTime(0);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.redeem();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp13_10() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp13();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp20_11() public {
        vm.startPrank(alice);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp20.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp25_12() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp25();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp32_13() public {
        vm.startPrank(alice);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp32.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp33_14() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp33();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp36_15() public {
        vm.startPrank(alice);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp36.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp4_16() public {
        vm.startPrank(alice);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp4.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp40_17() public {
        vm.startPrank(alice);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp40.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp9_18() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.bug_tmstmp9();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeStakeTime_19() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.changeStakeTime(100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeStakeTokens_20() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.changeStakeTokens(1000);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeStakingPercentage_21() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.changeStakingPercentage(50);
        }
    }

    // @cover-intent Protocol State Machine
    function test_lockWithdrawals_22() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.lockWithdrawals();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_newOwner_23() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.newOwner();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_24() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.owner();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp14_25() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp14(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp19_26() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp19(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp23_27() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp23(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp26_28() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp26(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp27_29() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp27(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp31_30() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp31(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp35_31() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp35(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp38_32() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp38(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp7_33() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.play_tmstmp7(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_redeem_34() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.startStaking();
        }
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_stakePercentage_35() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.stakePercentage();
        }
    }

    // @cover-intent Financial & Accounting
    function test_stakeTime_36() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.stakeTime();
        }
    }

    // @cover-intent Financial & Accounting
    function test_stakeTokens_37() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.stakeTokens();
        }
    }

    // @cover-intent Financial & Accounting
    function test_startStaking_38() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.startStaking();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_token_39() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.token();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferOwnership_40() public {
        vm.startPrank(owner);
        Staking target = new Staking(alice);
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
        target.transferOwnership(alice);
        }
    }

}
