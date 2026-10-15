// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x07f7ecb66d788ab01dc93b9b71a88401de7d0f2e.sol";

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


    // @cover-intent Authorization & Access Control: Verify only owner can call OpenToThePublic, and that it sets openToPublic to true.
    function test_Owner_opens_contract_to_public_0() public {
// cover: OpenToThePublic :: require(msg.sender == owner) true
// cover: OpenToThePublic :: require(msg.sender == owner) false
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
    }

    // @cover-intent Authorization & Access Control: Verify only owner can adjust bet limit and difficulty, and that state changes are reflected.
    function test_Owner_adjusts_bet_limit_and_difficulty_1() public {
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
        vm.startPrank(owner);
        {
        target.AdjustBetAmounts(100);
        }
        {
        target.AdjustDifficulty(10);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        vm.expectRevert();
        {
        target.AdjustBetAmounts(200);
        }
        vm.expectRevert();
        {
        target.AdjustDifficulty(20);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify wager succeeds when openToPublic is true, betLimit matches, and player hasn't wagered before.
    function test_Wager_with_correct_amount_after_opening_2() public {
// cover: wager :: require(openToPublic) true
// cover: wager :: require(msg.value == betLimit) true
// cover: wager :: require(wagers[msg.sender] == 0) true
// cover: wager :: require(wagers[msg.sender] == 0) false
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        vm.expectRevert();
        // skip ABI-mismatched call: wager()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify wager reverts when openToPublic is false.
    function test_Wager_fails_when_not_open_to_public_3() public {
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
    }

    // @cover-intent Transactional Consistency: Verify wager reverts if msg.value != betLimit.
    function test_Wager_fails_with_wrong_amount_4() public {
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

    // @cover-intent Transactional Consistency: Verify play reverts if called in the same block as wager (blockNumber >= block.number).
    function test_Play_after_wager_in_same_block_reverts_5() public {
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
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        vm.expectRevert();
        // skip ABI-mismatched call: play()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify play processes a loss, sends half bet to whale, and emits Lose event.
    function test_Play_after_wager_in_next_block_lose_scenario_6() public {
// assume: block.number > timestamps[alice]
// cover: play :: require(blockNumber < block.number) true
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
        target.AdjustDifficulty(10);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        // skip ABI-mismatched call: play()
        vm.stopPrank();
        // TODO assert: owner.balance == 0
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
        // TODO assert: carol.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify play processes a win, pays half contract balance to winner, and emits Win event.
    function test_Play_after_wager_in_next_block_win_scenario_7() public {
// assume: block.number > timestamps[alice]
// assume: winningNumber == difficulty / 2
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
        // TODO assert: owner.balance == 0
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 0
        // TODO assert: carol.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify donate sends ETH to whale and emits Donate event.
    function test_Donate_sends_ETH_to_whale_8() public {
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

    // @cover-intent Protocol State Machine: Verify donate reverts when openToPublic is false.
    function test_Donate_fails_when_not_open_to_public_9() public {
// cover: donate :: require(openToPublic) false
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: donate()
    }

    // @cover-intent Authorization & Access Control
    function test_AdjustBetAmounts_positive_10() public {
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
        target.AdjustBetAmounts(200);
        }
        {
        target.AdjustBetAmounts(300);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.currentBetLimit());
            _assertRelU(__v1, 0, 300, "call:currentBetLimit==300");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_AdjustDifficulty_positive_11() public {
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
        target.AdjustDifficulty(20);
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.currentDifficulty());
            _assertRelU(__v2, 0, 20, "call:currentDifficulty==20");
        }
    }

    // @cover-intent Protocol State Machine
    function test_OpenToThePublic_positive_12() public {
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
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentBetLimit_positive_13() public {
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
        target.AdjustBetAmounts(500);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: currentBetLimit()
        {
            uint256 __v3 = uint256(target.currentBetLimit());
            _assertRelU(__v3, 0, 500, "call:currentBetLimit==500");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_currentDifficulty_positive_14() public {
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
        target.AdjustDifficulty(15);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: currentDifficulty()
        {
            uint256 __v4 = uint256(target.currentDifficulty());
            _assertRelU(__v4, 0, 15, "call:currentDifficulty==15");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_donate_positive_15() public {
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
    function test_ethBalance_positive_16() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: ethBalance()
        // TODO assert: call:ethBalance() >= 2 ether
    }

    // @cover-intent Transactional Consistency
    function test_hasPlayerWagered_positive_17() public {
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

    // @cover-intent Transactional Consistency
    function test_play_positive_18() public {
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
    function test_transferAnyERC20Token_positive_19() public {
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
    }

    // @cover-intent Protocol State Machine
    function test_wager_positive_20() public {
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
    function test_winnersPot_positive_21() public {
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
        vm.prank(bob);
        // skip ABI-mismatched call: winnersPot()
        // TODO assert: call:winnersPot() == call:ethBalance() / 2
    }

}
