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


    // @cover-intent Protocol State Machine: Verify full game lifecycle where players win (finalPrice > initialPrice) and collect winnings
    function test_happy_path_full_game_players_win_0() public {
// assume: state() == 0
// assume: bet() > 0
// cover: setFinalPrice :: finalPrice > initialPrice true
// cover: setFinalPrice :: guesses[result].guesses_number > 0 true
// cover: collectPlayerWinnings :: guesses[result].players[msg.sender] == PaidStatus.NOT_PAID true
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
        {
        target.betUp.value(0.001 ether)();
        }
        vm.prank(owner);
        {
        target.closeGame();
        }
        vm.prank(alice);
        {
        target.setFinalPrice(200);
        }
        vm.prank(bob);
        {
        target.collectPlayerWinnings();
        }
    }

    // @cover-intent Protocol State Machine: Verify owner wins when no players bet on the winning side
    function test_owner_wins_no_bets_1() public {
// assume: state() == 3
// assume: result() == 1
// cover: setFinalPrice :: finalPrice > initialPrice true
// cover: setFinalPrice :: guesses[result].guesses_number > 0 false
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
        {
        target.betDown.value(0.001 ether)();
        }
        vm.startPrank(owner);
        {
        target.closeGame();
        }
        {
        target.setFinalPrice(200);
        }
        {
        target.collectOwnerWinnings();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify betting reverts when game is not in OPEN state
    function test_revert_bet_before_open_2() public {
// assume: state() == 0
// cover: betUp :: state == expected false
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
        target.betUp.value(0.001 ether)();
        }
    }

    // @cover-intent state transition test for setFinalPrice
    function test_revert_non_oracle_set_final_price_3() public {
// assume: state() == 3
// cover: setFinalPrice :: msg.sender == oracle false
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
        {
        target.closeGame();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.setFinalPrice(200);
        }
    }

    // @cover-intent Transactional Consistency: Verify player cannot collect winnings twice
    function test_revert_double_collect_player_winnings_4() public {
// assume: state() == 4
// cover: collectPlayerWinnings :: guesses[result].players[msg.sender] == PaidStatus.NOT_PAID false
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
        {
        target.betUp.value(0.001 ether)();
        }
        vm.prank(owner);
        {
        target.closeGame();
        }
        vm.prank(alice);
        {
        target.setFinalPrice(200);
        }
        vm.startPrank(bob);
        {
        target.collectPlayerWinnings();
        }
        vm.expectRevert();
        {
        target.collectPlayerWinnings();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for closeGame
    function test_revert_non_owner_close_game_5() public {
// assume: state() == 2
// cover: closeGame :: msg.sender == owner false
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.closeGame();
        }
    }

    // @cover-intent Financial & Accounting: Verify betting reverts with incorrect ETH amount
    function test_revert_bet_wrong_value_6() public {
// assume: state() == 2
// assume: bet() == 1
// cover: betUp :: msg.value == (bet*0.001 ether) false
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.betUp.value(0.002 ether)();
        }
    }

    // @cover-intent Authorization & Access Control: Verify oracle cannot place bets
    function test_revert_oracle_bets_7() public {
// assume: state() == 2
// assume: oracle() == alice
// cover: betUp :: msg.sender != oracle false
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
        target.betUp.value(0.001 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify owner cannot collect winnings when state is not OWNER_WIN
    function test_revert_collect_owner_winnings_wrong_state_8() public {
// assume: state() == 2
// cover: collectOwnerWinnings :: state == expected false
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
        vm.expectRevert();
        vm.prank(owner);
        {
        target.collectOwnerWinnings();
        }
    }

    // @cover-intent state transition test for setInitialPrice
    function test_revert_set_initial_price_non_oracle_9() public {
// assume: state() == 0
// cover: setInitialPrice :: msg.sender == oracle false
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

    // @cover-intent Protocol State Machine
    function test_bet_10() public {
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
        {
        target.bet();
        }
        {
            uint256 __v1 = uint256(target.bet());
            _assertRelU(__v1, 2, 0, "call:bet>=0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_betDown_11() public {
        vm.startPrank(alice);
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.betDown.value(0.001 ether)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_betUp_12() public {
        vm.startPrank(alice);
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.betUp.value(0.001 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp13_13() public {
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
        {
        target.bug_tmstmp13();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp20_14() public {
        vm.startPrank(alice);
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
        {
        target.bug_tmstmp20.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp25_15() public {
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
        {
        target.bug_tmstmp25();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp32_16() public {
        vm.startPrank(alice);
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
        {
        target.bug_tmstmp32.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp33_17() public {
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
        {
        target.bug_tmstmp33();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp36_18() public {
        vm.startPrank(alice);
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
        {
        target.bug_tmstmp36.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp37_19() public {
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
        {
        target.bug_tmstmp37();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp4_20() public {
        vm.startPrank(alice);
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
        {
        target.bug_tmstmp4.value(10 ether)();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp40_21() public {
        vm.startPrank(alice);
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
        {
        target.bug_tmstmp40.value(10 ether)();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_tmstmp8_22() public {
        vm.startPrank(alice);
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
        {
        target.bug_tmstmp8.value(10 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp9_23() public {
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
        {
        target.bug_tmstmp9();
        }
    }

    // @cover-intent Protocol State Machine
    function test_closeGame_24() public {
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        {
        target.closeGame();
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.state());
            _assertRelU(__v2, 0, 2, "call:state==2");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_collectOwnerWinnings_25() public {
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        {
        target.closeGame();
        }
        {
        target.setFinalPrice(50);
        }
        {
        target.collectOwnerWinnings();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_collectPlayerWinnings_26() public {
        vm.startPrank(alice);
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.betUp.value(0.001 ether)();
        }
        vm.startPrank(owner);
        {
        target.closeGame();
        }
        {
        target.setFinalPrice(150);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.collectPlayerWinnings();
        }
        // TODO assert: alice.balance >= 0
    }

    // @cover-intent Protocol State Machine
    function test_finalPrice_27() public {
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        {
        target.closeGame();
        }
        {
        target.setFinalPrice(150);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.finalPrice();
        }
        {
            uint256 __v3 = uint256(target.finalPrice());
            _assertRelU(__v3, 0, 150, "call:finalPrice==150");
        }
    }

    // @cover-intent Protocol State Machine
    function test_guesses_28() public {
        vm.startPrank(alice);
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.betUp.value(0.001 ether)();
        }
        {
        target.guesses(1);
        }
        vm.stopPrank();
        {
            uint256 __v4 = uint256(target.guesses(1));
            _assertRelU(__v4, 2, 1, "call:guesses>=1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_initialPrice_29() public {
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.initialPrice();
        }
        {
            uint256 __v5 = uint256(target.initialPrice());
            _assertRelU(__v5, 0, 100, "call:initialPrice==100");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_oracle_30() public {
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
        target.setOracle(owner);
        }
        vm.prank(alice);
        {
        target.oracle();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_31() public {
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
        {
        target.owner();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp14_32() public {
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
        {
        target.play_tmstmp14(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp19_33() public {
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
        {
        target.play_tmstmp19(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp23_34() public {
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
        {
        target.play_tmstmp23(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp26_35() public {
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
        {
        target.play_tmstmp26(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp27_36() public {
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
        {
        target.play_tmstmp27(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp3_37() public {
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
        {
        target.play_tmstmp3(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp30_38() public {
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
        {
        target.play_tmstmp30(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp31_39() public {
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
        {
        target.play_tmstmp31(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp35_40() public {
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
        {
        target.play_tmstmp35(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp38_41() public {
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
        {
        target.play_tmstmp38(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp39_42() public {
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
        {
        target.play_tmstmp39(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp7_43() public {
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
        {
        target.play_tmstmp7(0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_result_44() public {
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        {
        target.closeGame();
        }
        {
        target.setFinalPrice(150);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.result();
        }
        {
            uint256 __v6 = uint256(target.result());
            _assertRelU(__v6, 0, 1, "call:result==1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_setFinalPrice_45() public {
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        {
        target.closeGame();
        }
        {
        target.setFinalPrice(150);
        }
        vm.stopPrank();
        {
            uint256 __v7 = uint256(target.finalPrice());
            _assertRelU(__v7, 0, 150, "call:finalPrice==150");
        }
        {
            uint256 __v8 = uint256(target.state());
            _assertRelU(__v8, 0, 4, "call:state==4");
        }
    }

    // @cover-intent Protocol State Machine
    function test_setInitialPrice_46() public {
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
        vm.startPrank(owner);
        {
        target.setOracle(owner);
        }
        {
        target.setInitialPrice(100);
        }
        vm.stopPrank();
        {
            uint256 __v9 = uint256(target.initialPrice());
            _assertRelU(__v9, 0, 100, "call:initialPrice==100");
        }
        {
            uint256 __v10 = uint256(target.state());
            _assertRelU(__v10, 0, 1, "call:state==1");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setOracle_47() public {
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
        target.setOracle(owner);
        }
    }

    // @cover-intent Protocol State Machine
    function test_state_48() public {
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
        {
        target.state();
        }
        {
            uint256 __v11 = uint256(target.state());
            _assertRelU(__v11, 0, 0, "call:state==0");
        }
    }

}
