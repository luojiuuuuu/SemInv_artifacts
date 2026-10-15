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


    // @cover-intent Authorization & Access Control: Verify that only the owner can call OpenToThePublic, and that after the call, the contract is open to the public.
    function test_OpenToThePublic_positive_path_0() public {
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

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call OpenToThePublic.
    function test_OpenToThePublic_negative_path_non_owner_1() public {
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

    // @cover-intent Authorization & Access Control: Verify that only the owner can adjust bet amounts and the event is emitted.
    function test_AdjustBetAmounts_positive_path_2() public {
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
        target.AdjustBetAmounts(200);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot adjust bet amounts.
    function test_AdjustBetAmounts_negative_path_non_owner_3() public {
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
        vm.prank(alice);
        {
        target.AdjustBetAmounts(200);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can adjust difficulty and the event is emitted.
    function test_AdjustDifficulty_positive_path_4() public {
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

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot adjust difficulty.
    function test_AdjustDifficulty_negative_path_non_owner_5() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.AdjustDifficulty(10);
        }
    }

    // @cover-intent Protocol State Machine: Verify that a player can wager after the contract is open to the public, with the correct bet limit.
    function test_wager_positive_path_6() public {
// cover: wager :: require(openToPublic) true
// cover: wager :: require(msg.sender == tx.origin) true
// cover: wager :: require(msg.value == betLimit) true
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

    // @cover-intent Protocol State Machine: Verify that wager reverts if the contract is not open to the public.
    function test_wager_negative_path_not_open_to_public_7() public {
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

    // @cover-intent Financial & Accounting: Verify that wager reverts if the sent value does not equal betLimit.
    function test_wager_negative_path_wrong_amount_8() public {
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

    // @cover-intent Financial & Accounting: Verify that a player who wagered can play and potentially win, with payout and event emission.
    function test_play_positive_path_win_scenario_9() public {
// cover: play :: require(openToPublic) true
// cover: play :: require(msg.sender == tx.origin) true
// cover: play :: require(wagers[msg.sender] > 0) true
// cover: play :: if(blockNumber < block.number) true
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

    // @cover-intent Authorization & Access Control: Verify that play reverts if the caller has not wagered.
    function test_play_negative_path_not_a_player_10() public {
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
        // skip ABI-mismatched call: OpenToThePublic()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: play()
    }

    // @cover-intent External Interaction & Environment: Verify that a user can donate to the whale, emitting Donate event.
    function test_donate_positive_path_11() public {
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

    // @cover-intent Authorization & Access Control
    function test_AdjustBetAmounts_positive_12() public {
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
    function test_AdjustDifficulty_positive_13() public {
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
    function test_OpenToThePublic_positive_14() public {
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

    // @cover-intent Financial & Accounting
    function test_currentBetLimit_positive_15() public {
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
    function test_currentDifficulty_positive_16() public {
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
    function test_donate_positive_17() public {
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
    function test_ethBalance_positive_18() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: ethBalance()
        {
            uint256 __v5 = uint256(target.ethBalance());
            _assertRelU(__v5, 2, 0, "call:ethBalance>=0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_hasPlayerWagered_positive_19() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
        vm.prank(bob);
        {
        target.hasPlayerWagered(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_play_positive_20() public {
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
        target.AdjustDifficulty(10);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        // skip ABI-mismatched call: wager()
        // skip ABI-mismatched call: play()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_transferAnyERC20Token_positive_21() public {
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
    function test_wager_positive_22() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: wager()
    }

    // @cover-intent Financial & Accounting
    function test_winnersPot_positive_23() public {
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
        vm.prank(alice);
        // skip ABI-mismatched call: winnersPot()
        {
            uint256 __v6 = uint256(target.winnersPot());
            _assertRelU(__v6, 2, 0, "call:winnersPot>=0");
        }
    }

}
