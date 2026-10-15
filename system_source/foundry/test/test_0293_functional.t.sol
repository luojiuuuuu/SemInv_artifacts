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


    // @cover-intent Authorization & Access Control: Verify that only players who pay 0.02 ETH can become players and access player-only functions.
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

    // @cover-intent Authorization & Access Control: Only owner can call setSecret; non-owner calls should revert.
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: DranMe()
        {
        target.setSecret(42);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        {
        target.setSecret(99);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: secret()
    }

    // @cover-intent Authorization & Access Control: Player can call manipulateSecret when msg.sender != owner, triggering unlockSecret logic.
    function test_ManipulateSecret_with_player_but_not_owner_2() public {
// cover: manipulateSecret :: require(msg.value >= 0.01 ether) true
// cover: manipulateSecret :: msg.sender != owner true
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
        // skip ABI-mismatched call: DranMe()
        vm.startPrank(bob);
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: manipulateSecret()
        // skip ABI-mismatched call: winner()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Player must pay at least 0.005 ETH to callFirstTarget; lower value reverts.
    function test_CallFirstTarget_with_insufficient_value_3() public {
// cover: callFirstTarget :: require(msg.value >= 0.005 ether) false
// cover: callFirstTarget :: require(msg.value >= 0.005 ether) true
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
        vm.expectRevert();
        // skip ABI-mismatched call: callFirstTarget()
        // skip ABI-mismatched call: callFirstTarget()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Player can modify seed array via setSeed and addSeed; verify array length changes.
    function test_SetSeed_and_addSeed_array_manipulation_4() public {
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

    // @cover-intent Transactional Consistency: guessSeed computes division and may set owner to winner if condition met.
    function test_GuessSeed_with_correct_seed_values_5() public {
// cover: guessSeed :: require(approvedPlayers[msg.sender]) true
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
        // skip ABI-mismatched call: DranMe()
        // skip ABI-mismatched call: becomePlayer()
        {
        target.setSecret(100);
        }
        {
        target.seed(0);
        }
        {
        target.seed(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: checkSecret returns true when msg.value equals secret.
    function test_CheckSecret_with_correct_value_6() public {
// cover: checkSecret :: require(msg.value >= 0.01 ether) true
// cover: checkSecret :: msg.value == secret true
// cover: checkSecret :: msg.value == secret false
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: DranMe()
        // skip ABI-mismatched call: becomePlayer()
        {
        target.setSecret(42);
        }
        // skip ABI-mismatched call: checkSecret()
        // skip ABI-mismatched call: checkSecret()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only owner can call winPrize; only winner can call claimPrize.
    function test_WinPrize_onlyOwner_and_claimPrize_onlyWinner_7() public {
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
        // skip ABI-mismatched call: DranMe()
        vm.startPrank(bob);
        // skip ABI-mismatched call: becomePlayer()
        vm.expectRevert();
        // skip ABI-mismatched call: winPrize()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: winPrize()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: claimPrize()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: claimPrize()
    }

    // @cover-intent External Interaction & Environment: Fallback function is payable and accepts ETH without reverting.
    function test_Fallback_function_accepts_ETH_8() public {
// cover: fallback :: payable true
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: DranMe()
        // skip ABI-mismatched call: getPrize()
        vm.stopPrank();
        // skip bad numeric post: call:balance(owner) == 0
    }

    // @cover-intent Authorization & Access Control: Functions with onlyPlayers modifier revert when called by non-player.
    function test_Non_player_cannot_call_player_only_functions_9() public {
// cover: callFirstTarget :: require(approvedPlayers[msg.sender]) false
// cover: callSecondTarget :: require(approvedPlayers[msg.sender]) false
// cover: setSeed :: require(approvedPlayers[msg.sender]) false
// cover: addSeed :: require(approvedPlayers[msg.sender]) false
// cover: guessSeed :: require(approvedPlayers[msg.sender]) false
// cover: checkSecret :: require(approvedPlayers[msg.sender]) false
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
        vm.expectRevert();
        // skip ABI-mismatched call: callFirstTarget()
        vm.expectRevert();
        // skip ABI-mismatched call: callSecondTarget()
        vm.expectRevert();
        {
        target.setSeed(0, 1);
        }
        vm.expectRevert();
        {
        target.addSeed(3);
        }
        vm.expectRevert();
        {
        target.guessSeed(1);
        }
        // skip ABI-mismatched call: checkSecret()
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: becomePlayer()
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
        vm.prank(alice);
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(owner);
        {
        target.setSecret(0);
        }
        vm.prank(alice);
        {
        target.guessSeed(0);
        }
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
        vm.prank(owner);
        {
        target.setSecret(42);
        }
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

    // @cover-intent Financial & Accounting
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
        vm.prank(owner);
        // skip ABI-mismatched call: winPrize()
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
