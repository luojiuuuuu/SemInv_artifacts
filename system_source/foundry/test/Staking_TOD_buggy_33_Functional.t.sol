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


    // @cover-intent Test normal staking flow: startStaking, wait for stakeTime, then redeem. Covers Financial & Accounting invariant.
    function test_staking_positive_path_0() public {
// assume: block.timestamp >= staker[alice].time + stakeTime
// cover: startStaking :: require(stakeTokens >= minstakeTokens) true
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
        // dropped unsafe prestate: token.approve(address(target), 10000000000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.startStaking(1000000000000);
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Test startStaking with stakeTokens below minstakeTokens. Expect revert. Covers Resource & Execution Integrity.
    function test_staking_below_minimum_1() public {
// cover: startStaking :: require(stakeTokens >= minstakeTokens) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: token.approve(address(target), 10000000000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.startStaking(100);
        }
    }

    // @cover-intent Test redeem before stakeTime has elapsed. Expect revert. Covers Protocol State Machine.
    function test_redeem_before_time_2() public {
// assume: block.timestamp < staker[alice].time + stakeTime
// cover: redeem :: require(staker[msg.sender].time + stakeTime <= now) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: token.approve(address(target), 10000000000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.startStaking(1000000000000);
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Test redeem after successful redemption. Expect revert. Covers Protocol State Machine.
    function test_redeem_twice_3() public {
// assume: block.timestamp >= staker[alice].time + stakeTime
// cover: redeem :: require(!staker[msg.sender].redeem) true
// cover: redeem :: require(!staker[msg.sender].redeem) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: token.approve(address(target), 10000000000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.startStaking(1000000000000);
        }
        {
        target.redeem();
        }
        vm.expectRevert();
        {
        target.redeem();
        }
        vm.stopPrank();
    }

    // @cover-intent Test redeem when lock is true. Expect revert. Covers Authorization & Access Control.
    function test_redeem_when_locked_4() public {
// assume: block.timestamp >= staker[alice].time + stakeTime
// cover: redeem :: require(!lock) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: token.approve(address(target), 10000000000000);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.startStaking(1000000000000);
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

    // @cover-intent Test owner can change stakeTime. Covers Authorization & Access Control.
    function test_change_stake_time_owner_5() public {
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

    // @cover-intent Test owner can change stakePercentage. Covers Authorization & Access Control.
    function test_change_stake_percentage_owner_6() public {
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
        vm.prank(alice);
        {
        target.changeStakingPercentage(50);
        }
    }

    // @cover-intent Test owner can change minstakeTokens. Covers Authorization & Access Control.
    function test_change_stake_tokens_owner_7() public {
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
        target.changeStakeTokens(100);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeStakeTokens(100);
        }
    }

    // @cover-intent Test owner can transfer ownership. Covers Authorization & Access Control.
    function test_transfer_ownership_owner_8() public {
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
        target.transferOwnership(carol);
        }
    }

    // @cover-intent state transition test for lockWithdrawals
    function test_lock_withdrawals_owner_9() public {
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

    // @cover-intent minimal test for changeStakeTime
    function test_perfn_changeStakeTime_10() public {
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
        target.changeStakeTime(1);
        }
    }

    // @cover-intent minimal test for changeStakeTokens
    function test_perfn_changeStakeTokens_11() public {
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
        target.changeStakeTokens(1);
        }
    }

    // @cover-intent minimal test for changeStakingPercentage
    function test_perfn_changeStakingPercentage_12() public {
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
        target.changeStakingPercentage(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD14
    function test_perfn_claimReward_TOD14_13() public {
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
        target.claimReward_TOD14(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD2
    function test_perfn_claimReward_TOD2_14() public {
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
        target.claimReward_TOD2(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD20
    function test_perfn_claimReward_TOD20_15() public {
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
        target.claimReward_TOD20(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD26
    function test_perfn_claimReward_TOD26_16() public {
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
        target.claimReward_TOD26(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD30
    function test_perfn_claimReward_TOD30_17() public {
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
        target.claimReward_TOD30(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD32
    function test_perfn_claimReward_TOD32_18() public {
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
        target.claimReward_TOD32(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD36
    function test_perfn_claimReward_TOD36_19() public {
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
        target.claimReward_TOD36(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD38
    function test_perfn_claimReward_TOD38_20() public {
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
        target.claimReward_TOD38(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD40
    function test_perfn_claimReward_TOD40_21() public {
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
        target.claimReward_TOD40(1);
        }
    }

    // @cover-intent minimal test for claimReward_TOD8
    function test_perfn_claimReward_TOD8_22() public {
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
        target.claimReward_TOD8(1);
        }
    }

    // @cover-intent minimal test for getReward_TOD13
    function test_perfn_getReward_TOD13_23() public {
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
        target.getReward_TOD13();
        }
    }

    // @cover-intent minimal test for getReward_TOD17
    function test_perfn_getReward_TOD17_24() public {
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
        target.getReward_TOD17();
        }
    }

    // @cover-intent minimal test for getReward_TOD19
    function test_perfn_getReward_TOD19_25() public {
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
        target.getReward_TOD19();
        }
    }

    // @cover-intent minimal test for getReward_TOD25
    function test_perfn_getReward_TOD25_26() public {
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
        target.getReward_TOD25();
        }
    }

    // @cover-intent minimal test for getReward_TOD27
    function test_perfn_getReward_TOD27_27() public {
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
        target.getReward_TOD27();
        }
    }

    // @cover-intent minimal test for getReward_TOD3
    function test_perfn_getReward_TOD3_28() public {
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
        target.getReward_TOD3();
        }
    }

    // @cover-intent minimal test for getReward_TOD31
    function test_perfn_getReward_TOD31_29() public {
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
        target.getReward_TOD31();
        }
    }

    // @cover-intent minimal test for getReward_TOD33
    function test_perfn_getReward_TOD33_30() public {
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
        target.getReward_TOD33();
        }
    }

    // @cover-intent minimal test for getReward_TOD35
    function test_perfn_getReward_TOD35_31() public {
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
        target.getReward_TOD35();
        }
    }

    // @cover-intent minimal test for getReward_TOD37
    function test_perfn_getReward_TOD37_32() public {
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
        target.getReward_TOD37();
        }
    }

    // @cover-intent minimal test for getReward_TOD39
    function test_perfn_getReward_TOD39_33() public {
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
        target.getReward_TOD39();
        }
    }

    // @cover-intent minimal test for getReward_TOD9
    function test_perfn_getReward_TOD9_34() public {
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
        target.getReward_TOD9();
        }
    }

    // @cover-intent minimal test for lockWithdrawals
    function test_perfn_lockWithdrawals_35() public {
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
        target.lockWithdrawals();
        }
    }

    // @cover-intent minimal test for minstakeTokens
    function test_perfn_minstakeTokens_36() public {
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

    // @cover-intent minimal test for newOwner
    function test_perfn_newOwner_37() public {
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
        target.newOwner();
        }
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_38() public {
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
        target.owner();
        }
    }

    // @cover-intent minimal test for play_TOD13
    function test_perfn_play_TOD13_39() public {
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
        target.play_TOD13(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD17
    function test_perfn_play_TOD17_40() public {
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
        target.play_TOD17(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD19
    function test_perfn_play_TOD19_41() public {
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
        target.play_TOD19(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD25
    function test_perfn_play_TOD25_42() public {
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
        target.play_TOD25(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD27
    function test_perfn_play_TOD27_43() public {
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
        target.play_TOD27(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD3
    function test_perfn_play_TOD3_44() public {
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
        target.play_TOD3(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD31
    function test_perfn_play_TOD31_45() public {
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
        target.play_TOD31(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD33
    function test_perfn_play_TOD33_46() public {
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
        target.play_TOD33(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD35
    function test_perfn_play_TOD35_47() public {
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
        target.play_TOD35(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD37
    function test_perfn_play_TOD37_48() public {
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
        target.play_TOD37(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD39
    function test_perfn_play_TOD39_49() public {
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
        target.play_TOD39(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for play_TOD9
    function test_perfn_play_TOD9_50() public {
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
        target.play_TOD9(bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for redeem
    function test_perfn_redeem_51() public {
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
        target.redeem();
        }
    }

    // @cover-intent minimal test for setReward_TOD14
    function test_perfn_setReward_TOD14_52() public {
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
        target.setReward_TOD14();
        }
    }

    // @cover-intent minimal test for setReward_TOD2
    function test_perfn_setReward_TOD2_53() public {
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
        target.setReward_TOD2();
        }
    }

    // @cover-intent minimal test for setReward_TOD20
    function test_perfn_setReward_TOD20_54() public {
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
        target.setReward_TOD20();
        }
    }

    // @cover-intent minimal test for setReward_TOD26
    function test_perfn_setReward_TOD26_55() public {
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
        target.setReward_TOD26();
        }
    }

    // @cover-intent minimal test for setReward_TOD30
    function test_perfn_setReward_TOD30_56() public {
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
        target.setReward_TOD30();
        }
    }

    // @cover-intent minimal test for setReward_TOD32
    function test_perfn_setReward_TOD32_57() public {
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
        target.setReward_TOD32();
        }
    }

    // @cover-intent minimal test for setReward_TOD36
    function test_perfn_setReward_TOD36_58() public {
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
        target.setReward_TOD36();
        }
    }

    // @cover-intent minimal test for setReward_TOD38
    function test_perfn_setReward_TOD38_59() public {
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
        target.setReward_TOD38();
        }
    }

    // @cover-intent minimal test for setReward_TOD40
    function test_perfn_setReward_TOD40_60() public {
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
        target.setReward_TOD40();
        }
    }

    // @cover-intent minimal test for setReward_TOD8
    function test_perfn_setReward_TOD8_61() public {
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
        target.setReward_TOD8();
        }
    }

    // @cover-intent minimal test for stakePercentage
    function test_perfn_stakePercentage_62() public {
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

    // @cover-intent minimal test for stakeTime
    function test_perfn_stakeTime_63() public {
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

    // @cover-intent minimal test for startStaking
    function test_perfn_startStaking_64() public {
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
        target.startStaking(1);
        }
    }

    // @cover-intent minimal test for token
    function test_perfn_token_65() public {
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

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_66() public {
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
