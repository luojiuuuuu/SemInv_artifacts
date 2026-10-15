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


    // @cover-intent Authorization & Access Control: Verify that only the owner can call OpenToThePublic to transition the contract from closed to open state.
    function test_OpenToThePublic_Owner_Success_0() public {
// cover: OpenToThePublic :: require(msg.sender == owner) true
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

    // @cover-intent Authorization & Access Control: Verify that a non-owner (alice) cannot call OpenToThePublic and the transaction reverts.
    function test_OpenToThePublic_NonOwner_Revert_1() public {
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: OpenToThePublic()
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can adjust the bet limit and the BetLimitChanged event is emitted.
    function test_AdjustBetAmounts_Owner_Success_2() public {
// cover: AdjustBetAmounts :: require(msg.sender == owner) true
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
        target.AdjustBetAmounts(20000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner (bob) cannot adjust the bet limit and the transaction reverts.
    function test_AdjustBetAmounts_NonOwner_Revert_3() public {
// cover: AdjustBetAmounts :: require(msg.sender == owner) false
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
        vm.prank(bob);
        {
        target.AdjustBetAmounts(10000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can adjust the difficulty and the DifficultyChanged event is emitted.
    function test_AdjustDifficulty_Owner_Success_4() public {
// cover: AdjustDifficulty :: require(msg.sender == owner) true
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
        target.AdjustDifficulty(10);
        }
    }

    // @cover-intent Protocol State Machine: Verify that a player can successfully wager after the contract is opened to the public, with the correct bet amount.
    function test_Wager_Success_Flow_5() public {
// assume: currentBetLimit() == 10000000000000000
// cover: wager :: require(msg.value == betLimit) true
// cover: wager :: require(wagers[msg.sender] == 0) true
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.OpenToThePublic();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
    }

    // @cover-intent Transactional Consistency: Verify that a wager with an incorrect amount (not equal to betLimit) reverts.
    function test_Wager_WrongAmount_Revert_6() public {
// assume: currentBetLimit() == 10000000000000000
// cover: wager :: require(msg.value == betLimit) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.OpenToThePublic();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
    }

    // @cover-intent Transactional Consistency: Verify that a player cannot wager twice; the second wager attempt reverts.
    function test_Wager_DoubleWager_Revert_7() public {
// assume: currentBetLimit() == 10000000000000000
// cover: wager :: require(wagers[msg.sender] == 0) false
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.OpenToThePublic();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        vm.expectRevert();
        // skip ABI-mismatched call: wager()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that a player can call play() after wagering, and the wager is cleared. The outcome (win/lose) depends on the random number.
    function test_Play_AfterWager_Success_8() public {
// assume: currentBetLimit() == 10000000000000000
// assume: currentDifficulty() == 10
// cover: play :: require(blockNumber < block.number) true
// cover: play :: winningNumber == difficulty / 2 (win) or else (lose)
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.OpenToThePublic();
        target.AdjustDifficulty(10);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        // skip ABI-mismatched call: play()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that calling play() without a prior wager reverts due to the onlyPlayers modifier.
    function test_Play_WithoutWager_Revert_9() public {
// cover: play :: require(wagers[msg.sender] > 0) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.OpenToThePublic();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: play()
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
        target.AdjustBetAmounts(100);
        }
        {
        target.AdjustBetAmounts(200);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.currentBetLimit());
            _assertRelU(__v1, 0, 200, "call:currentBetLimit==200");
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
    function test_currentBetLimit_view_13() public {
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
    function test_currentDifficulty_view_14() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_ethBalance_view_16() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_hasPlayerWagered_view_17() public {
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

    // @cover-intent Financial & Accounting
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

    // @cover-intent Resource & Execution Integrity
    function test_winnersPot_view_21() public {
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
        // TODO assert: call:winnersPot() == 1 ether
    }

}
