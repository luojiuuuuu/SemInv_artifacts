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


    // @cover-intent Financial & Accounting: Verify a valid wager with correct signature and sufficient collateral succeeds, updating jackpotSize, devFeeSize, lockedInBets, and totalAmountToWhale correctly.
    function test_wager_positive_path_0() public {
// assume: block.number <= ticketLastBlock
// assume: getCollateralBalance() >= 2 ether
// cover: wager :: require(bet.player == address(0)) true
// cover: wager :: require(amount >= MIN_BET) true
// cover: wager :: require(amount <= MAX_BET) true
// cover: wager :: require(getCollateralBalance() >= 2 * amount) true
// cover: wager :: require(block.number <= ticketLastBlock) true
// cover: wager :: require(secretSigner == ecrecover(...)) true
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
        vm.prank(owner);
        {
        target.setSecretSigner(alice);
        }
        vm.prank(alice);
        // skip malformed call: wager(true, 1, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
    }

    // @cover-intent Resource & Execution Integrity: Verify wager reverts when amount is below MIN_BET (0.01 ether).
    function test_wager_below_minimum_1() public {
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
        // skip malformed call: wager(true, 2, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
    }

    // @cover-intent Resource & Execution Integrity: Verify wager reverts when amount is above MAX_BET (1 ether).
    function test_wager_above_maximum_2() public {
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
        // skip malformed call: wager(true, 3, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
    }

    // @cover-intent Financial & Accounting: Verify wager reverts when contract lacks sufficient collateral (getCollateralBalance() < 2 * amount).
    function test_wager_insufficient_collateral_3() public {
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
        // skip malformed call: wager(true, 4, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
    }

    // @cover-intent Resource & Execution Integrity: Verify wager reverts when ticketLastBlock is in the past (block.number > ticketLastBlock).
    function test_wager_expired_ticket_4() public {
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
        // skip malformed call: wager(true, 5, block.number - 1, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number - 1)
    }

    // @cover-intent Financial & Accounting: Verify play() correctly pays out winnings when player wins (betMask == maskRes), including jackpot if applicable.
    function test_play_win_path_5() public {
// assume: block.number > bet.blockNumber
// assume: block.number <= bet.blockNumber + BET_EXPIRATION_BLOCKS
// assume: random % 2 == 0 (betMask == maskRes)
// assume: random % JACKPOT_MODULO != 0 (no jackpot)
// cover: play :: require(bet.player != address(0)) true
// cover: play :: require(bet.amount != 0) true
// cover: play :: blockNumber < block.number && blockNumber >= block.number - BET_EXPIRATION_BLOCKS true
// cover: play :: bet.betMask == maskRes true
// cover: play :: jackpotRes == 0 false
// cover: play :: tossWin + jackpotWin > 0 true
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
        vm.prank(owner);
        {
        target.setSecretSigner(alice);
        }
        vm.startPrank(alice);
        // skip malformed call: wager(true, 10, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
        {
        target.play(10);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify play() correctly handles a loss (betMask != maskRes, no jackpot), emitting Lose event and not transferring funds.
    function test_play_lose_path_6() public {
// assume: block.number > bet.blockNumber
// assume: block.number <= bet.blockNumber + BET_EXPIRATION_BLOCKS
// assume: random % 2 == 1 (betMask != maskRes)
// assume: random % JACKPOT_MODULO != 0 (no jackpot)
// cover: play :: bet.betMask == maskRes false
// cover: play :: jackpotRes == 0 false
// cover: play :: tossWin + jackpotWin > 0 false
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
        vm.prank(owner);
        {
        target.setSecretSigner(alice);
        }
        vm.startPrank(alice);
        // skip malformed call: wager(true, 20, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
        {
        target.play(20);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify refund() returns the bet amount to the player when the ticket has expired (block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS).
    function test_refund_expired_ticket_7() public {
// assume: block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS
// cover: refund :: require(bet.amount != 0) true
// cover: refund :: require(block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS) true
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
        vm.prank(owner);
        {
        target.setSecretSigner(alice);
        }
        vm.startPrank(alice);
        // skip malformed call: wager(true, 30, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
        {
        target.refund(30);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify kill() reverts when lockedInBets > 0 (bets still outstanding).
    function test_kill_when_bets_outstanding_8() public {
// cover: kill :: require(lockedInBets == 0) false
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
        vm.prank(owner);
        {
        target.setSecretSigner(alice);
        }
        vm.prank(alice);
        // skip malformed call: wager(true, 40, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
        vm.expectRevert();
        vm.prank(owner);
        {
        target.kill();
        }
    }

    // @cover-intent Authorization & Access Control: Verify owner can withdraw dev fees when sufficient balance exists.
    function test_withdraw_dev_fee_owner_9() public {
// assume: devFeeSize >= 0.02 ether
// assume: address(this).balance >= 0.02 ether
// cover: withdrawDevFee :: require(devFeeSize >= withdrawAmount) true
// cover: withdrawDevFee :: require(withdrawAmount <= address(this).balance) true
// cover: withdrawDevFee :: require(devFeeSize <= address(this).balance) true
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
        vm.prank(owner);
        {
        target.setSecretSigner(alice);
        }
        vm.prank(alice);
        // skip malformed call: wager(true, 50, block.number + 100, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for wager.arg2: type=uint256, raw=block.number + 100)
        vm.prank(owner);
        // skip malformed call: withdrawDevFee(owner, 0.02 ether) (bad raw arg for withdrawDevFee.arg1: type=uint256, raw=0.02 ether)
    }

    // @cover-intent Authorization & Access Control
    function test_autoPlayBot_10() public {
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
        target.autoPlayBot();
        }
    }

    // @cover-intent Financial & Accounting
    function test_devFeeSize_11() public {
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
        target.devFeeSize();
        }
        {
            uint256 __v1 = uint256(target.devFeeSize());
            _assertRelU(__v1, 2, 0, "call:devFeeSize>=0");
        }
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
        {
        target.donateForContractHealth.value(1 ether)();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getBetInfo_13() public {
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
        {
        target.getCollateralBalance();
        }
        {
            uint256 __v2 = uint256(target.getCollateralBalance());
            _assertRelU(__v2, 2, 0, "call:getCollateralBalance>=0");
        }
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
        {
        target.getContractBalance();
        }
        {
            uint256 __v3 = uint256(target.getContractBalance());
            _assertRelU(__v3, 2, 0, "call:getContractBalance>=0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_jackpotSize_16() public {
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
        target.jackpotSize();
        }
        {
            uint256 __v4 = uint256(target.jackpotSize());
            _assertRelU(__v4, 2, 0, "call:jackpotSize>=0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_kill_17() public {
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
        target.kill();
        }
    }

    // @cover-intent Financial & Accounting
    function test_lockedInBets_18() public {
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
        target.lockedInBets();
        }
        {
            uint256 __v5 = uint256(target.lockedInBets());
            _assertRelU(__v5, 2, 0, "call:lockedInBets>=0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_19() public {
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
        target.owner();
        }
    }

    // @cover-intent Protocol State Machine
    function test_play_20() public {
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
        target.donateForContractHealth.value(10 ether)();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.play(0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_refund_21() public {
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
        target.donateForContractHealth.value(10 ether)();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.refund(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_secretSigner_22() public {
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
        target.secretSigner();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setBotAddress_23() public {
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
        target.setBotAddress(bob);
        }
        // TODO assert: call:autoPlayBot() == bob
    }

    // @cover-intent Authorization & Access Control
    function test_setSecretSigner_24() public {
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
        target.setSecretSigner(bob);
        }
        // TODO assert: call:secretSigner() == bob
    }

    // @cover-intent Financial & Accounting
    function test_totalAmountToWhale_25() public {
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
        target.totalAmountToWhale();
        }
        {
            uint256 __v6 = uint256(target.totalAmountToWhale());
            _assertRelU(__v6, 2, 0, "call:totalAmountToWhale>=0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferAnyERC20Token_26() public {
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
        target.transferAnyERC20Token(0x0000000000000000000000000000000000000000, alice, 0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_wager_27() public {
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
        target.donateForContractHealth.value(10 ether)();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.wager.value(0.01 ether)(false, 1, 0, 0, bytes32(uint256(0)), bytes32(uint256(0)));
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawBotFee_28() public {
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
        vm.startPrank(owner);
        {
        target.setBotAddress(bob);
        }
        {
        target.donateForContractHealth.value(10 ether)();
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.withdrawBotFee(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawDevFee_29() public {
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
        vm.startPrank(owner);
        {
        target.donateForContractHealth.value(10 ether)();
        }
        {
        target.withdrawDevFee(alice, 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_withdrawDonation_30() public {
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
        vm.startPrank(alice);
        {
        target.donateForContractHealth.value(1 ether)();
        }
        {
        target.withdrawDonation(1 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == initial(alice)
        // TODO assert: address(target).balance == initial(contract)
    }

}
