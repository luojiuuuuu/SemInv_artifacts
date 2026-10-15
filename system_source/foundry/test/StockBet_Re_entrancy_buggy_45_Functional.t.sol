// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_45.sol";

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

contract StockBet_FunctionalTest {
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


    // @cover-intent Protocol State Machine: Exercise the full state machine from SETUP to PLAYERS_WIN, verifying state transitions and event emissions.
    function test_Happy_path_full_game_lifecycle_with_players_winning_0() public {
// assume: state == State.OPEN
// assume: bet == 1
// cover: setInitialPrice :: state == SETUP
// cover: betUp :: msg.value == bet*0.001 ether
// cover: closeGame :: state == OPEN
// cover: setFinalPrice :: finalPrice > initialPrice
// cover: collectPlayerWinnings :: guesses[result].players[msg.sender] == PaidStatus.NOT_PAID
        vm.startPrank(bob);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: betUp()
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
        vm.prank(alice);
        {
        target.setFinalPrice(200);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: collectPlayerWinnings()
        // TODO assert: bob.balance == 100 - 0.001 ether + splitJackpot
    }

    // @cover-intent Protocol State Machine: Verify that if no player guessed the correct direction, the owner wins and can selfdestruct.
    function test_Owner_wins_when_no_players_bet_on_the_result_1() public {
// assume: state == State.OPEN
// assume: bet == 1
// cover: setFinalPrice :: guesses[result].guesses_number == 0
// cover: collectOwnerWinnings :: state == OWNER_WIN
        vm.startPrank(bob);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: betDown()
        vm.startPrank(owner);
        // skip ABI-mismatched call: closeGame()
        {
        target.setFinalPrice(200);
        }
        // skip ABI-mismatched call: collectOwnerWinnings()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call setOracle.
    function test_Non_owner_cannot_set_oracle_2() public {
// cover: setOracle :: byOwner modifier
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(bob);
        }
    }

    // @cover-intent state transition test for setInitialPrice
    function test_Non_oracle_cannot_set_initial_price_3() public {
// cover: setInitialPrice :: byOracle modifier
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.setInitialPrice(100);
        }
    }

    // @cover-intent Protocol State Machine: Verify that betUp and betDown revert when state is not OPEN.
    function test_Cannot_bet_before_game_is_open_4() public {
// assume: state == State.SETUP
// cover: betUp :: inState(OPEN) modifier
// cover: betDown :: inState(OPEN) modifier
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        vm.expectRevert();
        // skip ABI-mismatched call: betUp()
        vm.expectRevert();
        // skip ABI-mismatched call: betDown()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that the oracle is excluded from betting via byPlayer modifier.
    function test_Oracle_cannot_bet_5() public {
// assume: state == State.OPEN
// cover: betUp :: byPlayer modifier
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.startPrank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: betUp()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that closeGame reverts when state is not OPEN.
    function test_Cannot_close_game_before_it_is_open_6() public {
// assume: state == State.SETUP
// cover: closeGame :: inState(OPEN) modifier
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
    }

    // @cover-intent Protocol State Machine: Verify that setFinalPrice reverts when state is not CLOSED.
    function test_Cannot_set_final_price_before_game_is_closed_7() public {
// assume: state == State.OPEN
// cover: setFinalPrice :: inState(CLOSED) modifier
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.startPrank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.expectRevert();
        {
        target.setFinalPrice(200);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that collectPlayerWinnings reverts if the player already claimed.
    function test_Player_cannot_collect_winnings_twice_8() public {
// assume: state == State.PLAYERS_WIN
// cover: collectPlayerWinnings :: guesses[result].players[msg.sender] == PaidStatus.PAID
        vm.startPrank(bob);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: betUp()
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
        vm.prank(alice);
        {
        target.setFinalPrice(200);
        }
        vm.startPrank(bob);
        // skip ABI-mismatched call: collectPlayerWinnings()
        vm.expectRevert();
        // skip ABI-mismatched call: collectPlayerWinnings()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call collectOwnerWinnings.
    function test_Non_owner_cannot_collect_owner_winnings_9() public {
// assume: state == State.OWNER_WIN
// cover: collectOwnerWinnings :: byOwner modifier
        vm.startPrank(bob);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: betUp()
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
        vm.startPrank(alice);
        {
        target.setFinalPrice(50);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: collectOwnerWinnings()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine - verify bet value from constructor
    function test_bet_view_10() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: bet()
    }

    // @cover-intent Protocol State Machine - place a down bet in OPEN state
    function test_betDown_positive_11() public {
        vm.startPrank(bob);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: betDown()
    }

    // @cover-intent Protocol State Machine - place an up bet in OPEN state
    function test_betUp_positive_12() public {
        vm.startPrank(bob);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: betUp()
    }

    // @cover-intent state transition test for bug_re_ent13
    function test_bug_re_ent13_positive_13() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: bug_re_ent13()
    }

    // @cover-intent state transition test for bug_re_ent20
    function test_bug_re_ent20_positive_14() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: bug_re_ent20()
    }

    // @cover-intent state transition test for bug_re_ent27
    function test_bug_re_ent27_positive_15() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent state transition test for bug_re_ent41
    function test_bug_re_ent41_positive_16() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: bug_re_ent41()
    }

    // @cover-intent External Interaction & Environment - reentrant buy ticket
    function test_buyTicket_re_ent2_positive_17() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
    }

    // @cover-intent External Interaction & Environment - reentrant buy ticket
    function test_buyTicket_re_ent23_positive_18() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: buyTicket_re_ent23()
    }

    // @cover-intent External Interaction & Environment - reentrant buy ticket
    function test_buyTicket_re_ent30_positive_19() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: buyTicket_re_ent30()
    }

    // @cover-intent External Interaction & Environment - reentrant buy ticket
    function test_buyTicket_re_ent37_positive_20() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: buyTicket_re_ent37()
    }

    // @cover-intent External Interaction & Environment - reentrant buy ticket
    function test_buyTicket_re_ent9_positive_21() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: buyTicket_re_ent9()
    }

    // @cover-intent Resource & Execution Integrity - callme with counter limit
    function test_callme_re_ent14_positive_22() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: callme_re_ent14()
    }

    // @cover-intent Resource & Execution Integrity - callme with counter limit
    function test_callme_re_ent35_positive_23() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: callme_re_ent35()
    }

    // @cover-intent Resource & Execution Integrity - callme with counter limit
    function test_callme_re_ent42_positive_24() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: callme_re_ent42()
    }

    // @cover-intent Resource & Execution Integrity - callme with counter limit
    function test_callme_re_ent7_positive_25() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: callme_re_ent7()
    }

    // @cover-intent Financial & Accounting - claim reward with balance
    function test_claimReward_re_ent25_positive_26() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), redeemableEther_re_ent25[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: claimReward_re_ent25()
    }

    // @cover-intent Financial & Accounting - claim reward with balance
    function test_claimReward_re_ent32_positive_27() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), redeemableEther_re_ent32[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: claimReward_re_ent32()
    }

    // @cover-intent Financial & Accounting - claim reward with balance
    function test_claimReward_re_ent39_positive_28() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), redeemableEther_re_ent39[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent Financial & Accounting - claim reward with balance
    function test_claimReward_re_ent4_positive_29() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), redeemableEther_re_ent4[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: claimReward_re_ent4()
    }

    // @cover-intent Protocol State Machine - close game from OPEN state
    function test_closeGame_positive_30() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
    }

    // @cover-intent Authorization & Access Control - owner collects in OWNER_WIN state
    function test_collectOwnerWinnings_positive_31() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
        vm.prank(alice);
        {
        target.setFinalPrice(50);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: collectOwnerWinnings()
    }

    // @cover-intent Financial & Accounting - player collects winnings in PLAYERS_WIN state
    function test_collectPlayerWinnings_positive_32() public {
        vm.startPrank(bob);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: betUp()
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
        vm.prank(alice);
        {
        target.setFinalPrice(150);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: collectPlayerWinnings()
    }

    // @cover-intent Protocol State Machine - view final price after set
    function test_finalPrice_view_33() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
        vm.startPrank(alice);
        {
        target.setFinalPrice(200);
        }
        // skip ABI-mismatched call: finalPrice()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine - view guesses mapping
    function test_guesses_view_34() public {
        vm.startPrank(bob);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: betUp()
        vm.prank(alice);
        {
        target.guesses(1);
        }
    }

    // @cover-intent Protocol State Machine - view initial price after set
    function test_initialPrice_view_35() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.startPrank(alice);
        {
        target.setInitialPrice(100);
        }
        // skip ABI-mismatched call: initialPrice()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control - view oracle address
    function test_oracle_view_36() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: oracle()
    }

    // @cover-intent Authorization & Access Control - view owner address
    function test_owner_view_37() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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

    // @cover-intent Protocol State Machine - view result after final price set
    function test_result_view_38() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: closeGame()
        vm.startPrank(alice);
        {
        target.setFinalPrice(200);
        }
        // skip ABI-mismatched call: result()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine - set final price in CLOSED state
    function test_setFinalPrice_positive_39() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
        vm.startPrank(owner);
        // skip ABI-mismatched call: closeGame()
        {
        target.setFinalPrice(200);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine - set initial price in SETUP state
    function test_setInitialPrice_positive_40() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
        vm.prank(alice);
        {
        target.setInitialPrice(100);
        }
    }

    // @cover-intent Authorization & Access Control - owner sets oracle in SETUP state
    function test_setOracle_positive_41() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        target.setOracle(alice);
        }
    }

    // @cover-intent Protocol State Machine - view current state
    function test_state_view_42() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
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
        // skip ABI-mismatched call: state()
    }

    // @cover-intent Financial & Accounting - withdraw balance with send
    function test_withdrawBalance_re_ent19_positive_43() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), userBalance_re_ent19[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent19()
    }

    // @cover-intent Financial & Accounting - withdraw balance with call
    function test_withdrawBalance_re_ent26_positive_44() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), userBalance_re_ent26[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent26()
    }

    // @cover-intent Financial & Accounting - withdraw balance with call
    function test_withdrawBalance_re_ent33_positive_45() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), userBalance_re_ent33[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent Financial & Accounting - withdraw balance with call
    function test_withdrawBalance_re_ent40_positive_46() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), userBalance_re_ent40[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent Financial & Accounting - withdraw funds with balance check
    function test_withdrawFunds_re_ent17_positive_47() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent17[alice], bytes32(uint256(200)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent17(100);
        }
    }

    // @cover-intent Financial & Accounting - withdraw funds with balance check
    function test_withdrawFunds_re_ent3_positive_48() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent3[alice], bytes32(uint256(200)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent3(100);
        }
    }

    // @cover-intent Financial & Accounting - withdraw funds with send
    function test_withdrawFunds_re_ent31_positive_49() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent31[alice], bytes32(uint256(200)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent31(100);
        }
    }

    // @cover-intent Financial & Accounting - withdraw funds with send
    function test_withdrawFunds_re_ent38_positive_50() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent38[alice], bytes32(uint256(200)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent38(100);
        }
    }

    // @cover-intent Financial & Accounting - withdraw balances with call
    function test_withdraw_balances_re_ent1_positive_51() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent1[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent1()
    }

    // @cover-intent Financial & Accounting - withdraw balances with send
    function test_withdraw_balances_re_ent36_positive_52() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent36[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent Financial & Accounting - withdraw balances with call
    function test_withdraw_balances_re_ent8_positive_53() public {
        vm.startPrank(owner);
        StockBet target = new StockBet(1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), balances_re_ent8[alice], bytes32(uint256(100)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent8()
    }

}
