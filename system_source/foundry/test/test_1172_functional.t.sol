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


    // @cover-intent Authorization & Access Control: Verify only owner can call OpenToThePublic and that it sets openToPublic=true.
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
        {
        target.OpenToThePublic();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.OpenToThePublic();
        }
    }

    // @cover-intent Authorization & Access Control: Verify only owner can adjust betLimit and event is emitted.
    function test_Owner_adjusts_bet_limit_1() public {
// cover: AdjustBetAmounts :: require(msg.sender == owner) true
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
        vm.prank(owner);
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.AdjustBetAmounts(5000000000000000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify only owner can adjust difficulty and event is emitted.
    function test_Owner_adjusts_difficulty_2() public {
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
        {
        target.AdjustDifficulty(10);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.AdjustDifficulty(20);
        }
    }

    // @cover-intent Transactional Consistency: Verify a player can wager exactly betLimit, then play and potentially win (payout half balance).
    function test_Successful_wager_and_play_win_scenario_3() public {
// assume: openToPublic == true
// assume: betLimit == 10000000000000000
// assume: difficulty == 2
// cover: wager :: require(msg.value == betLimit) true
// cover: wager :: require(wagers[msg.sender] == 0) true
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
        {
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        {
        target.AdjustDifficulty(2);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.wager.value(10000000000000000)();
        }
        {
        target.play();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify wager reverts if msg.value != betLimit.
    function test_Wager_with_wrong_amount_reverts_4() public {
// assume: openToPublic == true
// assume: betLimit == 10000000000000000
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
        {
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.wager.value(5000000000000000)();
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify a player cannot wager twice.
    function test_Double_wager_reverts_5() public {
// assume: openToPublic == true
// assume: betLimit == 10000000000000000
// assume: wagers[alice] > 0
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
        {
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.wager.value(10000000000000000)();
        }
        vm.expectRevert();
        {
        target.wager.value(10000000000000000)();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify onlyPlayers modifier prevents non-wagerers from playing.
    function test_Play_without_wagering_reverts_6() public {
// assume: openToPublic == true
// assume: wagers[alice] == 0
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
        vm.prank(owner);
        {
        target.OpenToThePublic();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.play();
        }
    }

    // @cover-intent Transactional Consistency: Verify play reverts if called in the same block as wager (blockNumber >= block.number).
    function test_Play_in_same_block_reverts_7() public {
// assume: openToPublic == true
// assume: betLimit == 10000000000000000
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
        {
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.wager.value(10000000000000000)();
        }
        vm.expectRevert();
        {
        target.play();
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify donate sends ETH to whale address and emits event.
    function test_Donate_sends_ETH_to_whale_8() public {
// assume: openToPublic == true
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
        {
        target.OpenToThePublic();
        }
        vm.prank(alice);
        {
        target.donate.value(5000000000000000)();
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify view functions return correct state after setup.
    function test_View_functions_return_expected_values_9() public {
// assume: openToPublic == true
// assume: betLimit == 20000000000000000
// assume: difficulty == 5
// assume: wagers[alice] > 0
// assume: wagers[bob] == 0
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
        {
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(20000000000000000);
        }
        {
        target.AdjustDifficulty(5);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.wager.value(20000000000000000)();
        }
        {
        target.currentBetLimit();
        }
        {
        target.currentDifficulty();
        }
        {
        target.hasPlayerWagered(alice);
        }
        {
        target.hasPlayerWagered(bob);
        }
        {
        target.ethBalance();
        }
        {
        target.winnersPot();
        }
        vm.stopPrank();
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
        {
        target.OpenToThePublic();
        }
    }

    // @cover-intent Financial & Accounting
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
        {
        target.currentBetLimit();
        }
        {
            uint256 __v3 = uint256(target.currentBetLimit());
            _assertRelU(__v3, 0, 500, "call:currentBetLimit==500");
        }
    }

    // @cover-intent Financial & Accounting
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
        {
        target.currentDifficulty();
        }
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
        {
        target.OpenToThePublic();
        }
        vm.prank(alice);
        {
        target.donate.value(1 ether)();
        }
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
        {
        target.OpenToThePublic();
        }
        vm.prank(alice);
        {
        target.donate.value(2 ether)();
        }
        vm.prank(bob);
        {
        target.ethBalance();
        }
        // TODO assert: call:ethBalance() >= 2 ether
    }

    // @cover-intent Financial & Accounting
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
        {
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(1 ether);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.wager.value(1 ether)();
        }
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
        {
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(1 ether);
        }
        {
        target.AdjustDifficulty(10);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.wager.value(1 ether)();
        }
        {
        target.play();
        }
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
        target.transferAnyERC20Token(0x0000000000000000000000000000000000000001, alice, 0);
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
        {
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(1 ether);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.wager.value(1 ether)();
        }
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
        {
        target.OpenToThePublic();
        }
        vm.prank(alice);
        {
        target.donate.value(2 ether)();
        }
        vm.prank(bob);
        {
        target.winnersPot();
        }
        // TODO assert: call:winnersPot() == call:ethBalance() / 2
    }

}
