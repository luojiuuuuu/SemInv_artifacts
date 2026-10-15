// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_25.sol";

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

contract WhiteBetting_FunctionalTest {
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


    // @cover-intent Test the normal flow of setting up a game, placing a bet, and verifying the bet is recorded correctly. Covers Protocol State Machine and Transactional Consistency invariants.
    function test_Game_Setup_and_Betting_Flow_0() public {
// assume: gameList[1].open_status == 3
// assume: now < gameList[1].timestamp - 600
// cover: placeBet :: require(stake >= .001 ether) true
// cover: placeBet :: require(_odd != 0) true
// cover: placeBet :: require(gameList[_fixtureId].odd_homeTeam == _odd) true
// cover: placeBet :: require(gameList[_fixtureId].odd_drawTeam == _odd) true
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(1, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 3);
        }
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(1, 1, 1500);
        }
        vm.prank(bob);
        {
        target.placeBet.value(2 ether)(1, 2, 2000);
        }
    }

    // @cover-intent Test that placing a bet with odds that don't match the game's odds reverts. Covers Transactional Consistency invariant.
    function test_Bet_with_Invalid_Odds_1() public {
// assume: gameList[2].odd_homeTeam == 1500
// cover: placeBet :: require(gameList[_fixtureId].odd_homeTeam == _odd) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(2, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(2, 1, 9999);
        }
        // TODO assert: alice.balance == 100 ether
    }

    // @cover-intent Test that placing a bet with less than 0.001 ether reverts. Covers Resource & Execution Integrity invariant.
    function test_Bet_Below_Minimum_Stake_2() public {
// assume: gameList[3].open_status == 3
// cover: placeBet :: require(stake >= .001 ether) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(3, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(0.0005 ether)(3, 1, 1500);
        }
        // TODO assert: alice.balance == 100 ether
    }

    // @cover-intent Test that placing a bet when the game is not open (open_status != 3) reverts. Covers Protocol State Machine invariant.
    function test_Bet_on_Closed_Game_3() public {
// assume: gameList[4].open_status == 1
// cover: placeBet :: require(gameList[_fixtureId].open_status == 3) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(4, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 1);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(4, 1, 1500);
        }
        // TODO assert: alice.balance == 100 ether
    }

    // @cover-intent Test that placing a bet less than 10 minutes before game start reverts. Covers Resource & Execution Integrity invariant.
    function test_Bet_After_Game_Start_Time_4() public {
// assume: gameList[5].open_status == 3
// assume: now >= gameList[5].timestamp - 600
// cover: placeBet :: require(now < (gameList[_fixtureId].timestamp - 10 minutes)) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(2000000000)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.setGameInfo(5, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(5, 1, 1500);
        }
        // TODO assert: alice.balance == 100 ether
    }

    // @cover-intent Test that givePrizeMoney correctly distributes winnings to winning bettors. Covers Financial & Accounting invariant.
    function test_Prize_Distribution_for_Winning_Bets_5() public {
// assume: gameList[6].open_status == 3
// assume: gameList[6].isDone == false
// assume: betList[6][0].player != address(0)
// cover: givePrizeMoney :: require(gameList[_fixtureId].open_status == 3) true
// cover: givePrizeMoney :: require(gameList[_fixtureId].isDone == false) true
// cover: givePrizeMoney :: require(betList[_fixtureId][0].player != address(0)) true
// cover: givePrizeMoney :: selectedTeam == 1 && _homeDrawAway == 1 true
// cover: givePrizeMoney :: selectedTeam == 2 && _homeDrawAway == 2 false
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(6, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 3);
        }
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(6, 1, 1500);
        }
        vm.prank(bob);
        {
        target.placeBet.value(2 ether)(6, 2, 2000);
        }
        vm.prank(owner);
        {
        target.givePrizeMoney(6, 1, 1);
        }
        // TODO assert: bob.balance == 98 ether
    }

    // @cover-intent Test that givePrizeMoney reverts if the game has already been paid out. Covers Protocol State Machine invariant.
    function test_Prize_Distribution_Already_Paid_6() public {
// assume: gameList[7].isDone == true
// cover: givePrizeMoney :: require(gameList[_fixtureId].isDone == false) false
        vm.startPrank(alice);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(7, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 3);
        }
        vm.prank(alice);
        {
        target.placeBet.value(1 ether)(7, 1, 1500);
        }
        vm.startPrank(owner);
        {
        target.givePrizeMoney(7, 1, 1);
        }
        vm.expectRevert();
        {
        target.givePrizeMoney(7, 1, 1);
        }
        vm.stopPrank();
    }

    // @cover-intent Test that only the owner can change odds. Covers Authorization & Access Control invariant.
    function test_Non_Owner_Cannot_Change_Odds_7() public {
// cover: changeOdd :: require(msg.sender == owner) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(8, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 3);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeOdd(8, 1600, 2100, 1900, 1300, 1400, 1700, 1800, 2000);
        }
    }

    // @cover-intent Test that the owner can successfully change odds and the event is emitted. Covers Authorization & Access Control invariant.
    function test_Owner_Can_Change_Odds_8() public {
// cover: changeOdd :: require(msg.sender == owner) true
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(9, 2000000000, 1500, 2000, 1800, 1200, 1300, 1600, 1700, 1900, 3);
        }
        {
        target.changeOdd(9, 1600, 2100, 1900, 1300, 1400, 1700, 1800, 2000);
        }
        vm.stopPrank();
    }

    // @cover-intent Test that only the owner can change the owner address. Covers Authorization & Access Control invariant.
    function test_Non_Owner_Cannot_Change_Owner_9() public {
// cover: changeOwner :: require(msg.sender == owner) false
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.changeOwner(bob);
        }
    }

    // @cover-intent minimal test for betList
    function test_perfn_betList_10() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.betList(1, 1);
        }
    }

    // @cover-intent minimal test for bug_txorigin20
    function test_perfn_bug_txorigin20_11() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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

    // @cover-intent minimal test for bug_txorigin32
    function test_perfn_bug_txorigin32_12() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_txorigin32(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin36
    function test_perfn_bug_txorigin36_13() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_txorigin36(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin4
    function test_perfn_bug_txorigin4_14() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_txorigin4(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin40
    function test_perfn_bug_txorigin40_15() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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

    // @cover-intent minimal test for bug_txorigin8
    function test_perfn_bug_txorigin8_16() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.bug_txorigin8(alice);
        }
    }

    // @cover-intent minimal test for changeOdd
    function test_perfn_changeOdd_17() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.changeOdd(1, 1, 1, 1, 1, 1, 1, 1, 1);
        }
    }

    // @cover-intent minimal test for changeOwner
    function test_perfn_changeOwner_18() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.changeOwner(alice);
        }
    }

    // @cover-intent minimal test for deposit
    function test_perfn_deposit_19() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.deposit(1);
        }
    }

    // @cover-intent minimal test for gameList
    function test_perfn_gameList_20() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.gameList(1);
        }
    }

    // @cover-intent minimal test for getBalance
    function test_perfn_getBalance_21() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.getBalance();
        }
    }

    // @cover-intent minimal test for givePrizeMoney
    function test_perfn_givePrizeMoney_22() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.givePrizeMoney(1, 1, 1);
        }
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_23() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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

    // @cover-intent minimal test for placeBet
    function test_perfn_placeBet_24() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.placeBet(1, 1, 1);
        }
    }

    // @cover-intent minimal test for sendto_txorigin13
    function test_perfn_sendto_txorigin13_25() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.sendto_txorigin13(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin25
    function test_perfn_sendto_txorigin25_26() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.sendto_txorigin25(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin33
    function test_perfn_sendto_txorigin33_27() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.sendto_txorigin33(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin9
    function test_perfn_sendto_txorigin9_28() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.sendto_txorigin9(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for setGameInfo
    function test_perfn_setGameInfo_29() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.setGameInfo(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);
        }
    }

    // @cover-intent minimal test for setOpenStatus
    function test_perfn_setOpenStatus_30() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.setOpenStatus(1, 1);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin19
    function test_perfn_transferTo_txorigin19_31() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transferTo_txorigin19(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin23
    function test_perfn_transferTo_txorigin23_32() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transferTo_txorigin23(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin27
    function test_perfn_transferTo_txorigin27_33() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transferTo_txorigin27(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin31
    function test_perfn_transferTo_txorigin31_34() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transferTo_txorigin31(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin35
    function test_perfn_transferTo_txorigin35_35() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transferTo_txorigin35(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin39
    function test_perfn_transferTo_txorigin39_36() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transferTo_txorigin39(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin7
    function test_perfn_transferTo_txorigin7_37() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.transferTo_txorigin7(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for withdraw
    function test_perfn_withdraw_38() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.withdraw(100);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin14
    function test_perfn_withdrawAll_txorigin14_39() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.withdrawAll_txorigin14(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin26
    function test_perfn_withdrawAll_txorigin26_40() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.withdrawAll_txorigin26(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin30
    function test_perfn_withdrawAll_txorigin30_41() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.withdrawAll_txorigin30(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin38
    function test_perfn_withdrawAll_txorigin38_42() public {
        vm.startPrank(owner);
        WhiteBetting target = new WhiteBetting();
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
        target.withdrawAll_txorigin38(alice, alice);
        }
    }

}
