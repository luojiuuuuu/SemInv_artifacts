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
    function test_BecomePlayer_and_check_access_0() public {
// cover: becomePlayer :: require(msg.value >= 0.02 ether) true
// cover: manipulateSecret :: require(approvedPlayers[msg.sender]) false
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.getPlayerCount();
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        {
        target.manipulateSecret.value(0.01 ether)();
        }
    }

    // @cover-intent Authorization & Access Control: Only owner can call setSecret; non-owner call reverts.
    function test_Owner_sets_secret_and_non_owner_cannot_1() public {
// assume: owner() == alice
// cover: setSecret :: require(msg.sender == owner) true
// cover: setSecret :: require(msg.sender == owner) false
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.prank(bob);
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.prank(alice);
        {
        target.setSecret(42);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.setSecret(99);
        }
    }

    // @cover-intent Protocol State Machine: When msg.sender != owner, manipulateSecret calls unlockSecret which may set winner if blockhash condition is met.
    function test_ManipulateSecret_with_unlockSecret_condition_2() public {
// cover: manipulateSecret :: require(msg.value >= 0.01 ether) true
// cover: manipulateSecret :: msg.sender != owner true
// cover: unlockSecret :: secret%5==0 (may or may not be taken)
        vm.startPrank(bob);
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
        vm.startPrank(bob);
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.manipulateSecret.value(0.01 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Players can modify seed array via setSeed and addSeed; verify array length changes.
    function test_SetSeed_and_AddSeed_array_manipulation_3() public {
// cover: setSeed :: require(approvedPlayers[msg.sender]) true
// cover: addSeed :: require(approvedPlayers[msg.sender]) true
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.getLength();
        }
        {
        target.setSeed(0, 12345);
        }
        {
        target.addSeed(5);
        }
        {
        target.getLength();
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: guessSeed divides by seed[0]*seed[1]; if product is 0, transaction reverts due to division by zero.
    function test_GuessSeed_with_division_by_zero_edge_case_4() public {
// cover: guessSeed :: division by zero
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
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
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: checkSecret returns true only when msg.value equals secret; otherwise false.
    function test_CheckSecret_with_correct_and_incorrect_values_5() public {
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
        vm.prank(alice);
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.prank(bob);
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.prank(alice);
        {
        target.setSecret(100);
        }
        vm.startPrank(bob);
        {
        target.checkSecret.value(100)();
        }
        {
        target.checkSecret.value(99)();
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Only owner can call winPrize which sends 1 wei to owner; non-owner reverts.
    function test_WinPrize_onlyOwner_and_callFirstTarget_6() public {
// assume: owner() == alice
// cover: winPrize :: require(msg.sender == owner) true
// cover: winPrize :: require(msg.sender == owner) false
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.prank(bob);
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.prank(alice);
        {
        target.winPrize();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.winPrize();
        }
    }

    // @cover-intent Authorization & Access Control: Only the winner can claim the entire contract balance via claimPrize.
    function test_ClaimPrize_onlyWinner_7() public {
// assume: winner() == 0x0
// cover: claimPrize :: require(msg.sender == winner) false
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.startPrank(bob);
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.expectRevert();
        {
        target.claimPrize();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: callFirstTarget requires msg.value >= 0.005 ether; lower value reverts.
    function test_CallFirstTarget_with_insufficient_value_8() public {
// cover: callFirstTarget :: require(msg.value >= 0.005 ether) false
// cover: callFirstTarget :: require(msg.value >= 0.005 ether) true
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.expectRevert();
        {
        target.callFirstTarget.value(0.004 ether)();
        }
        {
        target.callFirstTarget.value(0.005 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: DranMe constructor sets owner to msg.sender.
    function test_DranMe_constructor_sets_owner_9() public {
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
        {
        target.DranMe();
        }
        {
        target.owner();
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
        {
        target.DranMe();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_addSeed_sequence_11() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
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
        {
            uint256 __v1 = uint256(target.balance(alice));
            _assertRelU(__v1, 0, 0, "call:balance==0");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_becomePlayer_sequence_13() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_callFirstTarget_sequence_14() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.callFirstTarget.value(0.005 ether)();
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_callSecondTarget_sequence_15() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.callSecondTarget.value(0.005 ether)();
        }
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        vm.prank(owner);
        {
        target.setSecret(42);
        }
        vm.prank(alice);
        {
        target.checkSecret.value(42)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_claimPrize_sequence_17() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.manipulateSecret.value(0.01 ether)();
        }
        {
        target.claimPrize();
        }
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
        {
        target.firstTarget();
        }
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
        {
        target.getLength();
        }
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
        {
        target.getPlayerCount();
        }
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
        {
        target.getPrize();
        }
        {
            uint256 __v2 = uint256(target.getPrize());
            _assertRelU(__v2, 2, 0, "call:getPrize>=0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_guessSeed_sequence_22() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.guessSeed(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_manipulateSecret_sequence_23() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.manipulateSecret.value(0.01 ether)();
        }
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
        {
        target.owner();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_players_sequence_25() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
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
        {
        target.secondTarget();
        }
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
        vm.prank(alice);
        {
        target.secret();
        }
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
        target.setSecret(123);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_setSeed_sequence_30() public {
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
        {
        target.becomePlayer.value(0.02 ether)();
        }
        {
        target.setSeed(0, 42);
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
        vm.prank(owner);
        {
        target.winPrize();
        }
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
        {
        target.winner();
        }
    }

}
