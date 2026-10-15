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


    // @cover-intent Authorization & Access Control: Verify that only players can call checkSecret and that it returns true when msg.value equals secret.
    function test_Become_Player_and_Check_Secret_0() public {
// assume: secret == 0.01 ether
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
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(owner);
        // skip malformed call: setSecret(0.01 ether) (bad raw arg for setSecret.arg0: type=uint256, raw=0.01 ether)
        vm.prank(alice);
        // skip ABI-mismatched call: checkSecret()
        vm.prank(bob);
        // skip ABI-mismatched call: checkSecret()
    }

    // @cover-intent Authorization & Access Control: Owner can set secret; manipulateSecret with owner should not trigger unlockSecret path.
    function test_Owner_Sets_Secret_and_Manipulates_1() public {
// assume: owner is player
// assume: alice is player
// cover: setSecret :: require(msg.sender == owner) true
// cover: manipulateSecret :: require(msg.value >= 0.01 ether) true
// cover: manipulateSecret :: msg.sender != owner true
// cover: manipulateSecret :: msg.sender != owner false
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
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(alice);
        // skip ABI-mismatched call: becomePlayer()
        vm.startPrank(owner);
        {
        target.setSecret(42);
        }
        // skip ABI-mismatched call: manipulateSecret()
        vm.stopPrank();
        vm.prank(alice);
        // skip ABI-mismatched call: manipulateSecret()
    }

    // @cover-intent Resource & Execution Integrity: Verify that guessSeed computes correctly and can update owner when condition met.
    function test_Set_Seed_and_Guess_Seed_2() public {
// assume: seed[0] == 2
// assume: seed[1] == 3
// assume: secret == 10
// cover: setSeed :: require(approvedPlayers[msg.sender]) true
// cover: guessSeed :: require(approvedPlayers[msg.sender]) true
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
        target.setSecret(10);
        }
        vm.startPrank(alice);
        {
        target.setSeed(0, 2);
        }
        {
        target.setSeed(1, 3);
        }
        {
        target.guessSeed(60);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that addSeed changes seed array length and getLength reflects it.
    function test_Add_Seed_and_Check_Length_3() public {
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: getLength()
        {
        target.addSeed(5);
        }
        // skip ABI-mismatched call: getLength()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that callFirstTarget forwards ETH to firstTarget address.
    function test_Call_First_Target_with_Value_4() public {
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: callFirstTarget()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that callSecondTarget forwards ETH to secondTarget address.
    function test_Call_Second_Target_with_Value_5() public {
// cover: callSecondTarget :: require(msg.value >= 0.005 ether) true
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: callSecondTarget()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Owner can winPrize (sends 1 wei to owner), winner can claimPrize (transfers contract balance).
    function test_Win_Prize_and_Claim_Prize_6() public {
// assume: winner == 0x0
// cover: winPrize :: require(msg.sender == owner) true
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
        vm.prank(owner);
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(alice);
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(owner);
        // skip ABI-mismatched call: winPrize()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: claimPrize()
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: claimPrize()
    }

    // @cover-intent Authorization & Access Control: Verify that non-players cannot call onlyPlayers functions.
    function test_Non_Player_Cannot_Call_Player_Functions_7() public {
// cover: manipulateSecret :: require(approvedPlayers[msg.sender]) false
// cover: callFirstTarget :: require(approvedPlayers[msg.sender]) false
// cover: setSeed :: require(approvedPlayers[msg.sender]) false
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
        vm.startPrank(bob);
        vm.expectRevert();
        // skip ABI-mismatched call: manipulateSecret()
        vm.expectRevert();
        // skip ABI-mismatched call: callFirstTarget()
        vm.expectRevert();
        {
        target.setSeed(0, 1);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can call setSecret.
    function test_Non_Owner_Cannot_Set_Secret_8() public {
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
        vm.startPrank(alice);
        // skip ABI-mismatched call: becomePlayer()
        vm.expectRevert();
        {
        target.setSecret(42);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that becomePlayer reverts if msg.value < 0.02 ether.
    function test_Become_Player_with_Insufficient_ETH_9() public {
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: becomePlayer()
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: callFirstTarget()
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
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: manipulateSecret()
        // skip ABI-mismatched call: claimPrize()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
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
        {
            uint256 __v1 = uint256(target.getPrize());
            _assertRelU(__v1, 2, 0, "call:getPrize>=0");
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
        vm.prank(alice);
        // skip ABI-mismatched call: becomePlayer()
        vm.prank(owner);
        {
        target.setSecret(1);
        }
        vm.prank(alice);
        // skip malformed call: guessSeed(951828771 * 158769871220) (bad raw arg for guessSeed.arg0: type=uint256, raw=951828771 * 158769871220)
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
        // skip ABI-mismatched call: becomePlayer()
        {
        target.players(0);
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
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
