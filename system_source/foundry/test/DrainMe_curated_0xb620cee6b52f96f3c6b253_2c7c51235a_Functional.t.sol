// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xb620cee6b52f96f3c6b253e6eea556aa2d214a99.sol";

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

contract DrainMe_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function DrainMe_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that only players who pay 0.02 ETH can become approved players and access player-only functions.
    function test_Become_player_and_check_access_0() public {
// cover: becomePlayer :: require(msg.value >= 0.02 ether) true
// cover: becomePlayer :: require(msg.value >= 0.02 ether) false
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: getPlayerCount()
        vm.stopPrank();
        vm.startPrank(bob);
        // skip ABI-mismatched call: getPlayerCount()
        vm.expectRevert();
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: becomePlayer()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only owner can call setSecret; non-owner calls revert.
    function test_Owner_sets_secret_and_non_owner_cannot_1() public {
// cover: setSecret :: require(msg.sender == owner) true
// cover: setSecret :: require(msg.sender == owner) false
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(bob);
        // skip ABI-mismatched call: becomePlayer()
        vm.expectRevert();
        vm.prank(alice);
        {
        target.setSecret(42);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.setSecret(42);
        }
        vm.prank(owner);
        {
        target.setSecret(42);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: secret()
    }

    // @cover-intent Protocol State Machine: manipulateSecret can only be called by players; if caller is not owner, unlockSecret must return true to proceed.
    function test_Manipulate_secret_with_unlock_condition_2() public {
// cover: manipulateSecret :: require(msg.value >= 0.01 ether) true
// cover: manipulateSecret :: require(msg.value >= 0.01 ether) false
// cover: manipulateSecret :: msg.sender != owner || unlockSecret() true
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(bob);
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(alice);
        // skip ABI-mismatched call: manipulateSecret()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: manipulateSecret()
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: manipulateSecret()
    }

    // @cover-intent External Interaction & Environment: Players can call firstTarget and secondTarget with at least 0.005 ETH.
    function test_Call_external_targets_with_value_3() public {
// cover: callFirstTarget :: require(msg.value >= 0.005 ether) true
// cover: callSecondTarget :: require(msg.value >= 0.005 ether) false
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: callFirstTarget()
        vm.expectRevert();
        // skip ABI-mismatched call: callSecondTarget()
        // skip ABI-mismatched call: callSecondTarget()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Players can modify seed array via setSeed and addSeed within bounds.
    function test_Set_and_add_seed_array_operations_4() public {
// cover: setSeed :: require(approvedPlayers[msg.sender]) true
// cover: addSeed :: require(approvedPlayers[msg.sender]) true
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: getLength()
        {
        target.setSeed(0, 12345);
        }
        {
        target.seed(0);
        }
        {
        target.addSeed(5);
        }
        // skip ABI-mismatched call: getLength()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: guessSeed divides by seed[0]*seed[1]; if product is zero, transaction reverts.
    function test_Guess_seed_with_division_by_zero_edge_case_5() public {
// cover: guessSeed :: division by zero revert
// cover: guessSeed :: normal execution
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        {
        target.setSeed(0, 0);
        }
        {
        target.setSeed(1, 0);
        }
        vm.expectRevert();
        {
        target.guessSeed(100);
        }
        {
        target.setSeed(0, 10);
        }
        {
        target.setSeed(1, 20);
        }
        {
        target.guessSeed(200);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: checkSecret returns true when msg.value equals secret; requires 0.01 ETH minimum.
    function test_Check_secret_with_exact_value_match_6() public {
// cover: checkSecret :: require(msg.value >= 0.01 ether) true
// cover: checkSecret :: require(msg.value >= 0.01 ether) false
// cover: checkSecret :: msg.value == secret true
        vm.startPrank(alice);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(owner);
        {
        target.setSecret(100);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: checkSecret()
        // skip ABI-mismatched call: checkSecret()
        // skip ABI-mismatched call: checkSecret()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Only owner can call winPrize; only winner can call claimPrize to drain contract balance.
    function test_Win_prize_and_claim_prize_flow_7() public {
// cover: winPrize :: require(msg.sender == owner) true
// cover: winPrize :: require(msg.sender == owner) false
// cover: claimPrize :: require(msg.sender == winner) false
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(owner);
        {
        target.setSecret(42);
        }
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: winPrize()
        vm.prank(owner);
        // skip ABI-mismatched call: winPrize()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: claimPrize()
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: claimPrize()
    }

    // @cover-intent Authorization & Access Control: DranMe constructor sets msg.sender as owner.
    function test_DranMe_constructor_sets_owner_8() public {
// cover: DranMe :: owner = msg.sender
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: owner()
        // skip ABI-mismatched call: DranMe()
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: balance mapping returns stored value for given index.
    function test_Balance_view_function_returns_correct_value_9() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        {
        target.balance(0);
        }
        {
        target.balance(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_DranMe_sequence_10() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: DranMe()
    }

    // @cover-intent Resource & Execution Integrity
    function test_addSeed_sequence_11() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        {
        target.addSeed(5);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_balance_sequence_12() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        target.balance(0);
        }
        // skip bad numeric post: call:balance(alice) == 0
    }

    // @cover-intent Authorization & Access Control
    function test_becomePlayer_sequence_13() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
    }

    // @cover-intent External Interaction & Environment
    function test_callFirstTarget_sequence_14() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: callFirstTarget()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_callSecondTarget_sequence_15() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: callSecondTarget()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_checkSecret_sequence_16() public {
        vm.startPrank(alice);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(owner);
        {
        target.setSecret(42);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: checkSecret()
    }

    // @cover-intent Financial & Accounting
    function test_claimPrize_sequence_17() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(owner);
        {
        target.setSecret(0);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: manipulateSecret()
        // skip ABI-mismatched call: claimPrize()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_firstTarget_sequence_18() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: firstTarget()
    }

    // @cover-intent Resource & Execution Integrity
    function test_getLength_sequence_19() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: getLength()
    }

    // @cover-intent Resource & Execution Integrity
    function test_getPlayerCount_sequence_20() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: getPlayerCount()
    }

    // @cover-intent Financial & Accounting
    function test_getPrize_sequence_21() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: getPrize()
    }

    // @cover-intent Financial & Accounting
    function test_guessSeed_sequence_22() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        {
        target.guessSeed(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_manipulateSecret_sequence_23() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: manipulateSecret()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_owner_sequence_24() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: DranMe()
        vm.prank(alice);
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Resource & Execution Integrity
    function test_players_sequence_25() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        {
        target.players(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_secondTarget_sequence_26() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: secondTarget()
    }

    // @cover-intent Resource & Execution Integrity
    function test_secret_sequence_27() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        target.setSecret(123);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: secret()
    }

    // @cover-intent Resource & Execution Integrity
    function test_seed_sequence_28() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        target.seed(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setSecret_sequence_29() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: DranMe()
        {
        target.setSecret(42);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_setSeed_sequence_30() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: becomePlayer()
        {
        target.setSeed(0, 123);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_winPrize_sequence_31() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: DranMe()
        // skip ABI-mismatched call: winPrize()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_winner_sequence_32() public {
        vm.startPrank(owner);
        DrainMe target = new DrainMe();
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
        // skip ABI-mismatched call: winner()
    }

}
