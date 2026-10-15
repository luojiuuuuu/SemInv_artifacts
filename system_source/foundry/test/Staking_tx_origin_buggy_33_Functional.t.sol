// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_33.sol";

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


    // @cover-intent Financial & Accounting: Verify that a user can successfully stake tokens and redeem them with reward after the stake time has elapsed.
    function test_staking_positive_path_0() public {
// assume: stakeTime == 1814400
// assume: minstakeTokens == 5000000000000
// cover: startStaking :: require(stakeTokens >= minstakeTokens) true
// cover: startStaking :: require(token.balanceOf(msg.sender) >= stakeTokens + findOnePercent(stakeTokens)) true
// cover: redeem :: require(!lock) true
// cover: redeem :: require(!staker[msg.sender].redeem) true
// cover: redeem :: require(staker[msg.sender].time + stakeTime <= now) false
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
        target.startStaking(500000000000);
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that staking with tokens below the minimum threshold reverts.
    function test_staking_below_minimum_1() public {
// assume: minstakeTokens == 5000000000000
// cover: startStaking :: require(stakeTokens >= minstakeTokens) false
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
        target.startStaking(100000000000);
        }
    }

    // @cover-intent Protocol State Machine: Verify that redeeming is blocked when withdrawals are locked.
    function test_redeem_locked_withdrawals_2() public {
// assume: lock == true
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
        target.startStaking(500000000000);
        }
        vm.prank(owner);
        {
        target.lockWithdrawals();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.redeem();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can change the stake time.
    function test_change_stake_time_owner_3() public {
// cover: changeStakeTime :: require(msg.sender == owner || msg.sender == address(this)) true
// cover: changeStakeTime :: require(msg.sender == owner || msg.sender == address(this)) false
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
        target.changeStakeTime(604800);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeStakeTime(604800);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can change the staking percentage.
    function test_change_stake_percentage_owner_4() public {
// cover: changeStakingPercentage :: require(msg.sender == owner || msg.sender == address(this)) true
// cover: changeStakingPercentage :: require(msg.sender == owner || msg.sender == address(this)) false
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.changeStakingPercentage(50);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can change the minimum stake tokens threshold.
    function test_change_min_stake_tokens_owner_5() public {
// cover: changeStakeTokens :: require(msg.sender == owner || msg.sender == address(this)) true
// cover: changeStakeTokens :: require(msg.sender == owner || msg.sender == address(this)) false
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
        vm.expectRevert();
        vm.prank(carol);
        {
        target.changeStakeTokens(1000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can transfer ownership.
    function test_transfer_ownership_owner_6() public {
// cover: transferOwnership :: require(msg.sender == owner || msg.sender == address(this)) true
// cover: transferOwnership :: require(msg.sender == owner || msg.sender == address(this)) false
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transferOwnership(bob);
        }
    }

    // @cover-intent Protocol State Machine: Verify that only the owner can lock withdrawals.
    function test_lock_withdrawals_owner_7() public {
// cover: lockWithdrawals :: require(msg.sender == owner || msg.sender == address(this)) true
// cover: lockWithdrawals :: require(msg.sender == owner || msg.sender == address(this)) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.lockWithdrawals();
        }
    }

    // @cover-intent Transactional Consistency: Verify that a user cannot redeem twice.
    function test_redeem_double_redeem_8() public {
// assume: staker[alice].redeem == false
// cover: redeem :: require(!staker[msg.sender].redeem) true
// cover: redeem :: require(staker[msg.sender].time + stakeTime <= now) false
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
        target.startStaking(500000000000);
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin20_test_9() public {
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
        target.bug_txorigin20(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin32_test_10() public {
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
        vm.prank(bob);
        {
        target.bug_txorigin32(bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin36_test_11() public {
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
        vm.prank(carol);
        {
        target.bug_txorigin36(carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin40_test_12() public {
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
        target.bug_txorigin40(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_bug_txorigin8_test_13() public {
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
        vm.prank(bob);
        {
        target.bug_txorigin8(bob);
        }
    }

    // @cover-intent Protocol State Machine
    function test_changeStakeTime_positive_14() public {
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
        target.changeStakeTime(1000000);
        }
    }

    // @cover-intent Protocol State Machine
    function test_changeStakeTokens_positive_15() public {
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
        target.changeStakeTokens(100);
        }
    }

    // @cover-intent Protocol State Machine
    function test_changeStakingPercentage_positive_16() public {
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
    function test_lockWithdrawals_positive_17() public {
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

    // @cover-intent Financial & Accounting
    function test_minstakeTokens_view_18() public {
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
        target.minstakeTokens();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_newOwner_view_19() public {
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
    function test_owner_view_20() public {
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

    // @cover-intent Financial & Accounting
    function test_redeem_positive_21() public {
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
        target.startStaking(500000000000);
        }
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin13_test_22() public {
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
        target.sendto_txorigin13(bob, 0, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin17_test_23() public {
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
        vm.prank(bob);
        {
        target.sendto_txorigin17(carol, 0, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin25_test_24() public {
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
        vm.prank(carol);
        {
        target.sendto_txorigin25(alice, 0, carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin33_test_25() public {
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
        target.sendto_txorigin33(bob, 0, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin37_test_26() public {
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
        vm.prank(bob);
        {
        target.sendto_txorigin37(carol, 0, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sendto_txorigin9_test_27() public {
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
        vm.prank(carol);
        {
        target.sendto_txorigin9(alice, 0, carol);
        }
    }

    // @cover-intent Financial & Accounting
    function test_stakePercentage_view_28() public {
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
    function test_stakeTime_view_29() public {
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
    function test_startStaking_positive_30() public {
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
        target.startStaking(500000000000);
        }
    }

    // @cover-intent Financial & Accounting
    function test_token_view_31() public {
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
    function test_transferOwnership_positive_32() public {
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

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin19_test_33() public {
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
        target.transferTo_txorigin19(bob, 0, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin27_test_34() public {
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
        vm.prank(bob);
        {
        target.transferTo_txorigin27(carol, 0, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin3_test_35() public {
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
        vm.prank(carol);
        {
        target.transferTo_txorigin3(alice, 0, carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin31_test_36() public {
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
        target.transferTo_txorigin31(bob, 0, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin35_test_37() public {
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
        vm.prank(bob);
        {
        target.transferTo_txorigin35(carol, 0, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferTo_txorigin39_test_38() public {
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
        vm.prank(carol);
        {
        target.transferTo_txorigin39(alice, 0, carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin14_test_39() public {
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
        target.withdrawAll_txorigin14(bob, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin2_test_40() public {
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
        vm.prank(bob);
        {
        target.withdrawAll_txorigin2(carol, bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin26_test_41() public {
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
        vm.prank(carol);
        {
        target.withdrawAll_txorigin26(alice, carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin30_test_42() public {
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
        target.withdrawAll_txorigin30(bob, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawAll_txorigin38_test_43() public {
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
        vm.prank(bob);
        {
        target.withdrawAll_txorigin38(carol, bob);
        }
    }

}
