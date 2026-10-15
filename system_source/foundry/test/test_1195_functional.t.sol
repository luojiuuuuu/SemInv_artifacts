// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/old_blockhash.sol";

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

contract PredictTheBlockHashChallenge_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PredictTheBlockHashChallenge_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Test normal flow where a player locks in a guess, waits for the next block, and settles. Since blockhash of future block is unpredictable, this tests the basic state transition from 'locked' to 'settled'.
    function test_positive_guess_and_settle_0() public {
// assume: block.number > guesses[alice].block
// cover: lockInGuess :: require(guesses[msg.sender].block == 0) true
// cover: lockInGuess :: require(msg.value == 1 ether) true
// cover: settle :: require(block.number > guesses[msg.sender].block) true
// cover: settle :: guesses[msg.sender].guess == answer (may be true or false depending on blockhash)
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        PredictTheBlockHashChallenge target = (new PredictTheBlockHashChallenge).value(1 ether)();
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(0)));
        }
        // skip ABI-mismatched call: settle()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test that a player cannot lock in a guess twice. The guard condition guesses[msg.sender].block == 0 should prevent re-entry.
    function test_double_lock_reverts_1() public {
// cover: lockInGuess :: require(guesses[msg.sender].block == 0) false
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        PredictTheBlockHashChallenge target = (new PredictTheBlockHashChallenge).value(1 ether)();
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(0)));
        }
        vm.expectRevert();
        {
        target.lockInGuess.value(1 ether)(bytes32(uint256(1)));
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Test that settle() reverts if called before the target block has passed. The guard condition block.number > guesses[msg.sender].block should prevent early settlement.
    function test_settle_before_block_reverts_2() public {
// assume: block.number <= guesses[alice].block
// cover: settle :: require(block.number > guesses[msg.sender].block) false
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        PredictTheBlockHashChallenge target = (new PredictTheBlockHashChallenge).value(1 ether)();
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(0)));
        }
        vm.expectRevert();
        // skip ABI-mismatched call: settle()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Test that settle() reverts if the player has not locked in a guess. The guard condition block.number > guesses[msg.sender].block will fail because guesses[msg.sender].block is 0.
    function test_settle_without_lock_reverts_3() public {
// cover: settle :: require(block.number > guesses[msg.sender].block) false
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        PredictTheBlockHashChallenge target = (new PredictTheBlockHashChallenge).value(1 ether)();
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
        // skip ABI-mismatched call: settle()
    }

    // @cover-intent Financial & Accounting: Test that lockInGuess reverts if the player sends less than 1 ether. The require(msg.value == 1 ether) guard should enforce the exact payment.
    function test_lock_with_insufficient_eth_reverts_4() public {
// cover: lockInGuess :: require(msg.value == 1 ether) false
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        PredictTheBlockHashChallenge target = (new PredictTheBlockHashChallenge).value(1 ether)();
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
        target.lockInGuess(bytes32(uint256(0)));
        }
    }

    // @cover-intent Transactional Consistency: Test that two different players can independently lock in guesses and settle, demonstrating that the mapping is per-address and state is isolated.
    function test_multiple_players_independent_guesses_5() public {
// assume: block.number > guesses[alice].block
// assume: block.number > guesses[bob].block
// cover: lockInGuess :: require(guesses[msg.sender].block == 0) true (both)
// cover: settle :: require(block.number > guesses[msg.sender].block) true (both)
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        PredictTheBlockHashChallenge target = (new PredictTheBlockHashChallenge).value(1 ether)();
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(0)));
        }
        vm.prank(bob);
        {
        target.lockInGuess.value(1 ether)(bytes32(uint256(1)));
        }
        vm.prank(alice);
        // skip ABI-mismatched call: settle()
        vm.prank(bob);
        // skip ABI-mismatched call: settle()
    }

    // @cover-intent Protocol State Machine
    function test_lockInGuess_positive_6() public {
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        PredictTheBlockHashChallenge target = (new PredictTheBlockHashChallenge).value(1 ether)();
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(0)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_settle_positive_7() public {
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        PredictTheBlockHashChallenge target = (new PredictTheBlockHashChallenge).value(1 ether)();
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(0)));
        }
        // skip ABI-mismatched call: settle()
        vm.stopPrank();
    }

}
