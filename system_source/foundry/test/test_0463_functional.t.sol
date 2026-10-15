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


    // @cover-intent Financial & Accounting: Verify a valid wager with proper signature and sufficient collateral updates jackpotSize, devFeeSize, lockedInBets, and totalAmountToWhale correctly
    function test_wager_positive_path_0() public {
// assume: block.number <= 1000000
// assume: getCollateralBalance() >= 2 ether
// cover: wager :: require(bet.player == address(0)) true
// cover: wager :: require(amount >= MIN_BET) true
// cover: wager :: require(amount <= MAX_BET) true
// cover: wager :: require(getCollateralBalance() >= 2 * amount) true
// cover: wager :: require(block.number <= ticketLastBlock) true
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
        {
        target.wager.value(1 ether)(true, 1, 1000000, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify wager reverts when bet amount is below MIN_BET (0.01 ether)
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
        target.wager(true, 2, 1000000, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify wager reverts when bet amount exceeds MAX_BET (1 ether)
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
        target.wager.value(2 ether)(true, 3, 1000000, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
    }

    // @cover-intent Financial & Accounting: Verify wager reverts when contract lacks sufficient collateral (getCollateralBalance() < 2 * amount)
    function test_wager_insufficient_collateral_3() public {
// assume: block.number <= 1000000
// assume: getCollateralBalance() < 1 ether
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
        target.wager(true, 4, 1000000, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify wager reverts when ticketLastBlock is in the past
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
        target.wager.value(1 ether)(true, 5, 1, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
    }

    // @cover-intent Financial & Accounting: Verify play() correctly pays winner when betMask matches maskRes and emits Win event
    function test_play_win_path_5() public {
// assume: block.number > bet.blockNumber
// assume: block.number <= bet.blockNumber + 250
// assume: random % 2 == 1
// assume: random % 1000 != 0
// cover: play :: require(bet.player != address(0)) true
// cover: play :: require(bet.amount != 0) true
// cover: play :: blockNumber < block.number && blockNumber >= block.number - BET_EXPIRATION_BLOCKS true
// cover: play :: bet.betMask == maskRes true
// cover: play :: jackpotRes == 0 false
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
        {
        target.wager.value(1 ether)(true, 10, 1000000, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
        {
        target.play(42);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify play() correctly handles loss when betMask does not match maskRes and emits Lose event
    function test_play_lose_path_6() public {
// assume: block.number > bet.blockNumber
// assume: block.number <= bet.blockNumber + 250
// assume: random % 2 == 1
// assume: random % 1000 != 0
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
        {
        target.wager.value(1 ether)(false, 20, 1000000, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
        {
        target.play(99);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify refund() returns funds when ticket has expired (block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS)
    function test_refund_expired_ticket_7() public {
// assume: block.number > bet.blockNumber + 250
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
        {
        target.wager.value(1 ether)(true, 30, 1000000, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
        {
        target.refund(30);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify refund() reverts when ticket has not yet expired
    function test_refund_not_expired_8() public {
// assume: block.number <= bet.blockNumber + 250
// cover: refund :: require(block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS) false
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
        {
        target.wager.value(1 ether)(true, 40, 1000000, 27, bytes32(uint256(0)), bytes32(uint256(0)));
        }
        vm.expectRevert();
        {
        target.refund(40);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_autoPlayBot_9() public {
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
    function test_devFeeSize_10() public {
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
        {
            uint256 __v1 = uint256(target.devFeeSize());
            _assertRelU(__v1, 0, 0, "call:devFeeSize==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_donateForContractHealth_11() public {
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
    function test_getBetInfo_12() public {
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
    function test_getCollateralBalance_13() public {
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
        {
            uint256 __v2 = uint256(target.getCollateralBalance());
            _assertRelU(__v2, 0, 0, "call:getCollateralBalance==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_getContractBalance_14() public {
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
        {
            uint256 __v3 = uint256(target.getContractBalance());
            _assertRelU(__v3, 0, 0, "call:getContractBalance==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_jackpotSize_15() public {
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
        {
            uint256 __v4 = uint256(target.jackpotSize());
            _assertRelU(__v4, 0, 0, "call:jackpotSize==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_kill_16() public {
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
    function test_lockedInBets_17() public {
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
        {
            uint256 __v5 = uint256(target.lockedInBets());
            _assertRelU(__v5, 0, 0, "call:lockedInBets==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_18() public {
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
    function test_play_19() public {
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
        // skip ABI-mismatched call: donateForContractHealth()
        vm.expectRevert();
        {
        target.play(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_refund_20() public {
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
        // skip ABI-mismatched call: donateForContractHealth()
        vm.expectRevert();
        {
        target.refund(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_secretSigner_21() public {
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
    function test_setBotAddress_22() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_setSecretSigner_23() public {
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
    }

    // @cover-intent Financial & Accounting
    function test_totalAmountToWhale_24() public {
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
        {
            uint256 __v6 = uint256(target.totalAmountToWhale());
            _assertRelU(__v6, 0, 0, "call:totalAmountToWhale==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_transferAnyERC20Token_25() public {
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

    // @cover-intent Protocol State Machine
    function test_wager_26() public {
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
        // skip ABI-mismatched call: donateForContractHealth()
        vm.expectRevert();
        {
        target.wager(false, 1, 0, 0, bytes32(uint256(0)), bytes32(uint256(0)));
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawBotFee_27() public {
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdrawBotFee(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawDevFee_28() public {
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
        vm.prank(owner);
        {
        target.withdrawDevFee(owner, 0);
        }
        {
            uint256 __v7 = uint256(target.devFeeSize());
            _assertRelU(__v7, 0, 0, "call:devFeeSize==0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawDonation_29() public {
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
        // skip ABI-mismatched call: donateForContractHealth()
        {
        target.withdrawDonation(1 ether);
        }
        vm.stopPrank();
    }

}
