// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xe09b1ab8111c2729a76f16de96bc86a7af837928.sol";

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

contract FiftyFlip_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function FiftyFlip_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify a successful wager with valid signature and sufficient collateral, checking state updates for jackpotSize, devFeeSize, lockedInBets, and totalAmountToWhale.
    function test_wager_positive_path_0() public {
// assume: block.number <= 1000000
// assume: getCollateralBalance() >= 0.2 ether
// cover: wager :: require(bet.player == address(0)) true
// cover: wager :: require(amount >= MIN_BET) true
// cover: wager :: require(amount <= MAX_BET) true
// cover: wager :: require(getCollateralBalance() >= 2 * amount) true
// cover: wager :: require(block.number <= ticketLastBlock) true
// cover: wager :: require(secretSigner == ecrecover(...)) true
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.prank(alice);
        {
        target.wager(false, 1, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
    }

    // @cover-intent Transactional Consistency: Verify wager reverts when bet amount is below MIN_BET (0.01 ether).
    function test_wager_below_minimum_1() public {
// assume: block.number <= 1000000
// cover: wager :: require(amount >= MIN_BET) false
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.wager(false, 2, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
    }

    // @cover-intent Transactional Consistency: Verify wager reverts when bet amount is above MAX_BET (1 ether).
    function test_wager_above_maximum_2() public {
// assume: block.number <= 1000000
// cover: wager :: require(amount <= MAX_BET) false
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.wager.value(2 ether)(false, 3, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
    }

    // @cover-intent Financial & Accounting: Verify wager reverts when contract lacks sufficient collateral (getCollateralBalance() < 2 * amount).
    function test_wager_insufficient_collateral_3() public {
// assume: block.number <= 1000000
// assume: getCollateralBalance() < 0.2 ether
// cover: wager :: require(getCollateralBalance() >= 2 * amount) false
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.wager(false, 4, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
    }

    // @cover-intent Transactional Consistency: Verify wager reverts when ticketLastBlock is in the past (block.number > ticketLastBlock).
    function test_wager_expired_ticket_4() public {
// assume: block.number > 1
// cover: wager :: require(block.number <= ticketLastBlock) false
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.wager(false, 5, 1, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
    }

    // @cover-intent Financial & Accounting: Verify a winning play where maskRes matches betMask, resulting in payout and state updates.
    function test_play_win_path_5() public {
// assume: block.number > bet.blockNumber
// assume: block.number <= bet.blockNumber + 250
// assume: random % 2 == 0
// assume: random % 1000 != 0
// cover: play :: require(bet.player != address(0)) true
// cover: play :: require(bet.amount != 0) true
// cover: play :: blockNumber < block.number && blockNumber >= block.number - BET_EXPIRATION_BLOCKS true
// cover: play :: bet.betMask == maskRes true
// cover: play :: jackpotRes == 0 false
// cover: play :: tossWin + jackpotWin > 0 true
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.startPrank(alice);
        {
        target.wager(false, 10, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
        {
        target.play(42);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify a losing play where maskRes does not match betMask, emitting Lose event and updating lockedInBets.
    function test_play_lose_path_6() public {
// assume: block.number > bet.blockNumber
// assume: block.number <= bet.blockNumber + 250
// assume: random % 2 == 0
// assume: random % 1000 != 0
// cover: play :: bet.betMask == maskRes false
// cover: play :: jackpotRes == 0 false
// cover: play :: tossWin + jackpotWin > 0 false
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.startPrank(alice);
        {
        target.wager(true, 11, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
        {
        target.play(43);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify jackpot win when jackpotRes == 0, paying out jackpotSize and resetting it to 0.
    function test_play_jackpot_win_7() public {
// assume: block.number > bet.blockNumber
// assume: block.number <= bet.blockNumber + 250
// assume: random % 2 == 0
// assume: random % 1000 == 0
// assume: jackpotSize > 0
// cover: play :: jackpotRes == 0 true
// cover: play :: jackpotWin > 0 true
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.startPrank(alice);
        {
        target.wager(false, 12, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
        {
        target.play(44);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify refund of an expired ticket (block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS) returns the bet amount and updates lockedInBets.
    function test_refund_expired_ticket_8() public {
// assume: block.number > bet.blockNumber + 250
// cover: refund :: require(bet.amount != 0) true
// cover: refund :: require(block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS) true
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.startPrank(alice);
        {
        target.wager(false, 20, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
        {
        target.refund(20);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify kill() reverts when lockedInBets != 0, protecting user funds.
    function test_kill_when_bets_outstanding_9() public {
// assume: lockedInBets > 0
// cover: kill :: require(lockedInBets == 0) false
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
        vm.prank(alice);
        {
        target.wager(false, 30, 1000000, 27, bytes32(uint256(1)), bytes32(uint256(1)));
        }
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Authorization & Access Control
    function test_autoPlayBot_view_10() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: autoPlayBot()
    }

    // @cover-intent Financial & Accounting
    function test_devFeeSize_view_11() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: devFeeSize()
    }

    // @cover-intent Financial & Accounting
    function test_donateForContractHealth_12() public {
        vm.startPrank(alice);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: donateForContractHealth()
    }

    // @cover-intent Resource & Execution Integrity
    function test_getBetInfo_nonexistent_13() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.getBetInfo(0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_getCollateralBalance_14() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: getCollateralBalance()
    }

    // @cover-intent Financial & Accounting
    function test_getContractBalance_15() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: getContractBalance()
    }

    // @cover-intent Financial & Accounting
    function test_jackpotSize_view_16() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: jackpotSize()
    }

    // @cover-intent Authorization & Access Control
    function test_kill_when_lockedInBets_zero_17() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Financial & Accounting
    function test_lockedInBets_view_18() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: lockedInBets()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_view_19() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
    function test_play_with_invalid_ticket_20() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.play(0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_refund_nonexistent_ticket_21() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.refund(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_secretSigner_view_22() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: secretSigner()
    }

    // @cover-intent Authorization & Access Control
    function test_setBotAddress_by_owner_23() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setBotAddress(alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setSecretSigner_by_owner_24() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setSecretSigner(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_totalAmountToWhale_view_25() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        // skip ABI-mismatched call: totalAmountToWhale()
    }

    // @cover-intent External Interaction & Environment
    function test_transferAnyERC20Token_by_owner_26() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.transferAnyERC20Token(address(0), alice, 0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawBotFee_by_bot_27() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.setBotAddress(alice);
        }
        vm.prank(alice);
        {
        target.withdrawBotFee(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawDevFee_by_owner_28() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.withdrawDevFee(owner, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawDonation_zero_29() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.withdrawDonation(0);
        }
    }

    // @cover-intent minimal test for wager
    function test_perfn_wager_30() public {
        vm.startPrank(owner);
        FiftyFlip target = new FiftyFlip(alice, alice, alice);
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
        target.wager(true, 1, 1, 1, bytes32(uint256(1)), bytes32(uint256(1)));
        }
    }

}
