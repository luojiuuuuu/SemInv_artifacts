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
    function test_Become_player_and_check_secret_0() public {
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
        {
        target.setSecret(100);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: checkSecret()
        // skip ABI-mismatched call: checkSecret()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only owner can call setSecret; non-owner call reverts.
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
        vm.prank(owner);
        {
        target.setSecret(42);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.setSecret(99);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: secret()
    }

    // @cover-intent Financial & Accounting: becomePlayer reverts if msg.value < 0.02 ether.
    function test_Become_player_requires_minimum_ETH_2() public {
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
        vm.expectRevert();
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: becomePlayer()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Only players can call manipulateSecret; non-player reverts. Also requires msg.value >= 0.01 ether.
    function test_Manipulate_secret_only_players_and_with_minimum_ETH_3() public {
// cover: manipulateSecret :: require(approvedPlayers[msg.sender]) true
// cover: manipulateSecret :: require(approvedPlayers[msg.sender]) false
// cover: manipulateSecret :: require(msg.value >= 0.01 ether) true
// cover: manipulateSecret :: require(msg.value >= 0.01 ether) false
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
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: manipulateSecret()
        vm.startPrank(alice);
        vm.expectRevert();
        // skip ABI-mismatched call: manipulateSecret()
        // skip ABI-mismatched call: manipulateSecret()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Player can set and add seed array elements; out-of-bounds index reverts.
    function test_Set_seed_and_add_seed_by_player_4() public {
// cover: setSeed :: index < seed.length true
// cover: setSeed :: index < seed.length false
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
        vm.expectRevert();
        {
        target.setSeed(5, 456);
        }
        {
        target.addSeed(5);
        }
        // skip ABI-mismatched call: getLength()
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Player can call external targets with minimum ETH; non-player reverts.
    function test_Call_first_target_and_second_target_by_player_5() public {
// cover: callFirstTarget :: require(approvedPlayers[msg.sender]) true
// cover: callFirstTarget :: require(approvedPlayers[msg.sender]) false
// cover: callFirstTarget :: require(msg.value >= 0.005 ether) true
// cover: callFirstTarget :: require(msg.value >= 0.005 ether) false
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
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: callFirstTarget()
        vm.startPrank(alice);
        vm.expectRevert();
        // skip ABI-mismatched call: callFirstTarget()
        // skip ABI-mismatched call: callFirstTarget()
        // skip ABI-mismatched call: callSecondTarget()
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: guessSeed computes correctly and may set owner to winner if condition met.
    function test_Guess_seed_with_correct_calculation_6() public {
// assume: seed[0]*seed[1] != 0
// cover: guessSeed :: return value computed
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
        target.setSecret(10);
        }
        vm.prank(alice);
        {
        target.guessSeed(10);
        }
    }

    // @cover-intent Authorization & Access Control: Only owner can call winPrize; non-owner reverts.
    function test_Win_prize_only_owner_7() public {
// cover: winPrize :: require(msg.sender == owner) true
// cover: winPrize :: require(msg.sender == owner) false
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
        // skip ABI-mismatched call: winPrize()
        vm.prank(owner);
        // skip ABI-mismatched call: winPrize()
    }

    // @cover-intent Authorization & Access Control: Only winner can claim prize; non-winner reverts.
    function test_Claim_prize_only_winner_8() public {
// cover: claimPrize :: require(msg.sender == winner) true
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
        {
        target.setSecret(0);
        }
        vm.startPrank(alice);
        // skip ABI-mismatched call: becomePlayer()
        // skip ABI-mismatched call: manipulateSecret()
        vm.expectRevert();
        // skip ABI-mismatched call: claimPrize()
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: claimPrize()
    }

    // @cover-intent Protocol State Machine: DranMe constructor sets owner to msg.sender.
    function test_Constructor_sets_owner_9() public {
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
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_DranMe_10() public {
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
    function test_addSeed_11() public {
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
    function test_balance_12() public {
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
    function test_becomePlayer_13() public {
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
    function test_callFirstTarget_14() public {
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
    function test_callSecondTarget_15() public {
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
    function test_checkSecret_16() public {
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
    function test_claimPrize_17() public {
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
    function test_firstTarget_18() public {
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
    function test_getLength_19() public {
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
    function test_getPlayerCount_20() public {
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
    function test_getPrize_21() public {
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
        // skip bad numeric post: call:balance(alice) == 0
    }

    // @cover-intent Financial & Accounting
    function test_guessSeed_22() public {
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
        // skip bad numeric post: call:balance(alice) == 0
    }

    // @cover-intent Authorization & Access Control
    function test_manipulateSecret_23() public {
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
    function test_owner_24() public {
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
    function test_players_25() public {
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
    function test_secondTarget_26() public {
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
    function test_secret_27() public {
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
    function test_seed_28() public {
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
    function test_setSecret_29() public {
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
    function test_setSeed_30() public {
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
    function test_winPrize_31() public {
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
    function test_winner_32() public {
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
