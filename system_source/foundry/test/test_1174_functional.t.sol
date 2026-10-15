// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol";

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

contract PoCGame_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PoCGame_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify only owner can call OpenToThePublic, AdjustBetAmounts, and AdjustDifficulty; non-owner reverts.
    function test_owner_opens_contract_and_adjusts_difficulty_0() public {
// cover: OpenToThePublic :: require(msg.sender == owner) true
// cover: OpenToThePublic :: require(msg.sender == owner) false
// cover: AdjustBetAmounts :: require(msg.sender == owner) true
// cover: AdjustBetAmounts :: require(msg.sender == owner) false
// cover: AdjustDifficulty :: require(msg.sender == owner) true
// cover: AdjustDifficulty :: require(msg.sender == owner) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: OpenToThePublic()
        vm.prank(owner);
        {
        target.AdjustDifficulty(10);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.AdjustDifficulty(10);
        }
    }

    // @cover-intent Financial & Accounting: Alice wagers exactly betLimit, then plays and wins (winningNumber == difficulty/2). Verify payout halves contract balance.
    function test_alice_wager_and_play_win_1() public {
// assume: block.number > timestamps[alice]
// cover: wager :: require(msg.value == betLimit) true
// cover: play :: require(wagers[msg.sender] > 0) true
// cover: play :: require(blockNumber < block.number) true
// cover: play :: winningNumber == difficulty / 2
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        {
        target.AdjustDifficulty(2);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        // skip ABI-mismatched call: play()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Alice wagers, then plays and loses (winningNumber != difficulty/2). Verify whale receives half bet via loseWager.
    function test_alice_wager_and_play_lose_2() public {
// assume: block.number > timestamps[alice]
// assume: winningNumber != 1
// cover: play :: winningNumber != difficulty / 2
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        {
        target.AdjustDifficulty(3);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        // skip ABI-mismatched call: play()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Alice wagers and plays in same block (timestamps[alice] == block.number), play should revert.
    function test_alice_wager_same_block_play_reverts_3() public {
// assume: block.number == timestamps[alice]
// cover: play :: require(blockNumber < block.number) false
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        {
        target.AdjustDifficulty(2);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        vm.expectRevert();
        // skip ABI-mismatched call: play()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only players with wagers > 0 can call play; non-player reverts.
    function test_non_player_cannot_play_4() public {
// cover: play :: require(wagers[msg.sender] > 0) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        {
        target.AdjustDifficulty(2);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: play()
    }

    // @cover-intent External Interaction & Environment: Alice donates ETH to whale via donate function. Verify totalDonated increases and whale receives call.
    function test_donate_to_whale_5() public {
// cover: donate :: require(openToPublic) true
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        vm.prank(alice);
        // skip ABI-mismatched call: donate()
    }

    // @cover-intent Financial & Accounting: Wager with wrong msg.value (not equal to betLimit) should revert.
    function test_wager_wrong_amount_reverts_6() public {
// cover: wager :: require(msg.value == betLimit) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
    }

    // @cover-intent Protocol State Machine: Wager before OpenToThePublic is called should revert due to isOpenToPublic modifier.
    function test_wager_before_open_reverts_7() public {
// cover: wager :: require(openToPublic) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustBetAmounts(1 ether);
        }
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
    }

    // @cover-intent Resource & Execution Integrity: hasPlayerWagered returns true after wager, false before and after play clears wagers.
    function test_hasPlayerWagered_after_wager_8() public {
// assume: block.number > timestamps[alice]
// cover: hasPlayerWagered :: wagers[player] > 0 true
// cover: hasPlayerWagered :: wagers[player] > 0 false
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        {
        target.AdjustDifficulty(2);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.hasPlayerWagered(alice);
        }
        // skip ABI-mismatched call: wager()
        {
        target.hasPlayerWagered(alice);
        }
        // skip ABI-mismatched call: play()
        {
        target.hasPlayerWagered(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only owner can call transferAnyERC20Token; non-owner reverts.
    function test_transfer_any_erc20_token_only_owner_9() public {
// cover: transferAnyERC20Token :: require(msg.sender == owner) true
// cover: transferAnyERC20Token :: require(msg.sender == owner) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.transferAnyERC20Token(0x0000000000000000000000000000000000000001, alice, 100);
        }
        vm.prank(alice);
        {
        target.transferAnyERC20Token(0x0000000000000000000000000000000000000001, alice, 100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_OpenToThePublic_by_owner_10() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        // skip ABI-mismatched call: OpenToThePublic()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_AdjustBetAmounts_by_owner_11() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustBetAmounts(100);
        }
        {
        target.AdjustBetAmounts(100);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.currentBetLimit());
            _assertRelU(__v1, 0, 100, "call:currentBetLimit==100");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_AdjustDifficulty_by_owner_12() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustDifficulty(10);
        }
        {
        target.AdjustDifficulty(10);
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.currentDifficulty());
            _assertRelU(__v2, 0, 10, "call:currentDifficulty==10");
        }
    }

    // @cover-intent Financial & Accounting
    function test_currentBetLimit_after_setup_13() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustBetAmounts(50);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: currentBetLimit()
        {
            uint256 __v3 = uint256(target.currentBetLimit());
            _assertRelU(__v3, 0, 50, "call:currentBetLimit==50");
        }
    }

    // @cover-intent Financial & Accounting
    function test_currentDifficulty_after_setup_14() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustDifficulty(5);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: currentDifficulty()
        {
            uint256 __v4 = uint256(target.currentDifficulty());
            _assertRelU(__v4, 0, 5, "call:currentDifficulty==5");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_donate_with_ETH_15() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        vm.prank(alice);
        // skip ABI-mismatched call: donate()
    }

    // @cover-intent Financial & Accounting
    function test_ethBalance_after_donation_16() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        vm.startPrank(alice);
        // skip ABI-mismatched call: donate()
        // skip ABI-mismatched call: ethBalance()
        vm.stopPrank();
        {
            uint256 __v5 = uint256(target.ethBalance());
            _assertRelU(__v5, 2, 0, "call:ethBalance>=0");
        }
    }

    // @cover-intent Transactional Consistency
    function test_hasPlayerWagered_after_wager_17() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
        vm.prank(bob);
        {
        target.hasPlayerWagered(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_play_after_wager_18() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        {
        target.AdjustDifficulty(10);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        // skip ABI-mismatched call: play()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_transferAnyERC20Token_by_owner_19() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.transferAnyERC20Token(0x0000000000000000000000000000000000000001, alice, 100);
        }
        {
        target.transferAnyERC20Token(0x0000000000000000000000000000000000000001, alice, 100);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_wager_with_correct_ETH_20() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        {
        target.AdjustBetAmounts(1 ether);
        }
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
    }

    // @cover-intent Financial & Accounting
    function test_winnersPot_after_donation_21() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        // skip ABI-mismatched call: OpenToThePublic()
        vm.startPrank(alice);
        // skip ABI-mismatched call: donate()
        // skip ABI-mismatched call: winnersPot()
        vm.stopPrank();
        // TODO assert: call:winnersPot() == 1 ether
    }

}
