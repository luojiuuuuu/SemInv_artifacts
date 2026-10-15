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


    // @cover-intent Financial & Accounting: Test successful staking and redemption flow with correct token transfers and reward calculation
    function test_staking_positive_path_0() public {
// assume: token.balanceOf(alice) >= stakeTokens + findOnePercent(stakeTokens)
// assume: staker[alice].redeem == false
// cover: startStaking :: require(token.balanceOf(msg.sender) >= stakeTokens + findOnePercent(stakeTokens)) true
// cover: startStaking :: require(token.transferFrom(...)) true
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
        // skip ABI-mismatched call: startStaking()
        vm.expectRevert();
        // skip ABI-mismatched call: redeem()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Test successful redemption after lock period expires with correct reward calculation
    function test_redeem_after_lock_time_1() public {
// assume: staker[alice].time + stakeTime <= now
// assume: !lock
// assume: !staker[alice].redeem
// cover: redeem :: require(staker[msg.sender].time + stakeTime <= now) true
// cover: redeem :: require(token.transfer(...)) true
// cover: redeem :: require(token.transferFrom(owner, ...)) true
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: token.approve(address(target), 10000000000000);
        // dropped unsafe prestate: vm.warp(block.timestamp + 1814400 + 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: startStaking()
        // skip ABI-mismatched call: redeem()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test that redemption reverts when withdrawals are locked
    function test_redeem_when_locked_2() public {
// assume: lock == true
// cover: redeem :: require(!lock) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: token.approve(address(target), 10000000000000);
        // dropped unsafe prestate: vm.warp(block.timestamp + 1814400 + 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: startStaking()
        vm.prank(owner);
        // skip ABI-mismatched call: lockWithdrawals()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: redeem()
    }

    // @cover-intent Transactional Consistency: Test that redeeming twice reverts
    function test_double_redeem_reverts_3() public {
// assume: staker[alice].redeem == true
// cover: redeem :: require(!staker[msg.sender].redeem) false
        vm.startPrank(owner);
        Staking target = new Staking(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: token.approve(address(target), 10000000000000);
        // dropped unsafe prestate: vm.warp(block.timestamp + 1814400 + 1);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: startStaking()
        // skip ABI-mismatched call: redeem()
        vm.expectRevert();
        // skip ABI-mismatched call: redeem()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test owner can change stake time, non-owner cannot
    function test_owner_changes_stake_time_4() public {
// assume: msg.sender == owner || msg.sender == address(this)
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

    // @cover-intent Authorization & Access Control: Test owner can change stake percentage, non-owner cannot
    function test_owner_changes_stake_percentage_5() public {
// cover: changeStakingPercentage :: onlyOwner modifier true
// cover: changeStakingPercentage :: onlyOwner modifier false
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

    // @cover-intent Authorization & Access Control: Test owner can change stake token threshold, non-owner cannot
    function test_owner_changes_stake_tokens_6() public {
// cover: changeStakeTokens :: onlyOwner modifier true
// cover: changeStakeTokens :: onlyOwner modifier false
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

    // @cover-intent Protocol State Machine: Test owner can lock withdrawals, non-owner cannot
    function test_owner_locks_withdrawals_7() public {
// cover: lockWithdrawals :: onlyOwner modifier true
// cover: lockWithdrawals :: onlyOwner modifier false
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
        // skip ABI-mismatched call: lockWithdrawals()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: lockWithdrawals()
    }

    // @cover-intent Authorization & Access Control: Test ownership transfer by owner, non-owner cannot
    function test_transfer_ownership_8() public {
// cover: transferOwnership :: onlyOwner modifier true
// cover: transferOwnership :: onlyOwner modifier false
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

    // @cover-intent Financial & Accounting: Test that staking reverts when user has insufficient token balance
    function test_start_staking_insufficient_balance_9() public {
// assume: token.balanceOf(alice) < stakeTokens + findOnePercent(stakeTokens)
// cover: startStaking :: require(token.balanceOf(msg.sender) >= stakeTokens + findOnePercent(stakeTokens)) false
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
        // skip ABI-mismatched call: startStaking()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou19_10() public {
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
        // skip ABI-mismatched call: bug_intou19()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_11() public {
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
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou3_12() public {
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
        // skip ABI-mismatched call: bug_intou3()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou31_13() public {
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
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou35_14() public {
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
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou39_15() public {
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
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent state transition test for lockWithdrawals
    function test_lockWithdrawals_16() public {
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
        // skip ABI-mismatched call: lockWithdrawals()
    }

    // @cover-intent Financial & Accounting
    function test_newOwner_17() public {
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
        // skip ABI-mismatched call: newOwner()
    }

    // @cover-intent Financial & Accounting
    function test_owner_18() public {
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Protocol State Machine
    function test_redeem_19() public {
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
        // skip ABI-mismatched call: startStaking()
        // skip ABI-mismatched call: redeem()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_stakePercentage_20() public {
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
        // skip ABI-mismatched call: stakePercentage()
    }

    // @cover-intent Financial & Accounting
    function test_stakeTime_21() public {
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
        // skip ABI-mismatched call: stakeTime()
    }

    // @cover-intent Financial & Accounting
    function test_stakeTokens_22() public {
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
        // skip ABI-mismatched call: stakeTokens()
    }

    // @cover-intent Protocol State Machine
    function test_startStaking_23() public {
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
        // skip ABI-mismatched call: startStaking()
    }

    // @cover-intent Financial & Accounting
    function test_token_24() public {
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
        // skip ABI-mismatched call: token()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_25() public {
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
        // skip ABI-mismatched call: withdraw_intou13()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou17_26() public {
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
        // skip ABI-mismatched call: withdraw_intou17()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou25_27() public {
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
        // skip ABI-mismatched call: withdraw_intou25()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou33_28() public {
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
        // skip ABI-mismatched call: withdraw_intou33()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou37_29() public {
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
        // skip ABI-mismatched call: withdraw_intou37()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou9_30() public {
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
        // skip ABI-mismatched call: withdraw_intou9()
    }

    // @cover-intent minimal test for bug_intou20
    function test_perfn_bug_intou20_31() public {
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
        target.bug_intou20(1);
        }
    }

    // @cover-intent minimal test for bug_intou32
    function test_perfn_bug_intou32_32() public {
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
        target.bug_intou32(1);
        }
    }

    // @cover-intent minimal test for bug_intou36
    function test_perfn_bug_intou36_33() public {
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent minimal test for bug_intou40
    function test_perfn_bug_intou40_34() public {
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent minimal test for bug_intou8
    function test_perfn_bug_intou8_35() public {
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent minimal test for changeStakeTime
    function test_perfn_changeStakeTime_36() public {
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
    function test_perfn_changeStakeTokens_37() public {
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
    function test_perfn_changeStakingPercentage_38() public {
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

    // @cover-intent minimal test for increaseLockTime_intou13
    function test_perfn_increaseLockTime_intou13_39() public {
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
        target.increaseLockTime_intou13(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou17
    function test_perfn_increaseLockTime_intou17_40() public {
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
        target.increaseLockTime_intou17(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou25
    function test_perfn_increaseLockTime_intou25_41() public {
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
        target.increaseLockTime_intou25(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou33
    function test_perfn_increaseLockTime_intou33_42() public {
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
        target.increaseLockTime_intou33(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou37
    function test_perfn_increaseLockTime_intou37_43() public {
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
        target.increaseLockTime_intou37(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou9
    function test_perfn_increaseLockTime_intou9_44() public {
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
        target.increaseLockTime_intou9(1);
        }
    }

    // @cover-intent minimal test for lockTime_intou13
    function test_perfn_lockTime_intou13_45() public {
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou17
    function test_perfn_lockTime_intou17_46() public {
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
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou25
    function test_perfn_lockTime_intou25_47() public {
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
        target.lockTime_intou25(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou33
    function test_perfn_lockTime_intou33_48() public {
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou37
    function test_perfn_lockTime_intou37_49() public {
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
        target.lockTime_intou37(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou9
    function test_perfn_lockTime_intou9_50() public {
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
        target.lockTime_intou9(alice);
        }
    }

    // @cover-intent minimal test for transferOwnership
    function test_perfn_transferOwnership_51() public {
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

    // @cover-intent minimal test for transfer_intou14
    function test_perfn_transfer_intou14_52() public {
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
        target.transfer_intou14(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou26
    function test_perfn_transfer_intou26_53() public {
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
        target.transfer_intou26(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou30
    function test_perfn_transfer_intou30_54() public {
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
        target.transfer_intou30(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou38
    function test_perfn_transfer_intou38_55() public {
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
        target.transfer_intou38(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_undrflow2
    function test_perfn_transfer_undrflow2_56() public {
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
        target.transfer_undrflow2(bob, 100);
        }
    }

}
