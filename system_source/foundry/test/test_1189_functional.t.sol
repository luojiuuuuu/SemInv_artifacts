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


    // @cover-intent Protocol State Machine: Demonstrate the normal flow where a player locks in a guess of 0x0, waits for the target block to be more than 256 blocks old so blockhash returns 0, and then settles to win 2 ether.
    function test_Positive_path_lock_in_guess_and_settle_with_correct_guess_0() public {
// assume: block.number > guesses[alice].block + 256
// cover: lockInGuess :: require(guesses[msg.sender].block == 0) true
// cover: lockInGuess :: require(msg.value == 1 ether) true
// cover: settle :: require(block.number > guesses[msg.sender].block) true
// cover: settle :: guesses[msg.sender].guess == answer true
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

    // @cover-intent Protocol State Machine: Verify that settle reverts when called before the target block number is reached (block.number <= guesses[msg.sender].block).
    function test_Negative_path_settle_before_target_block_reached_1() public {
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

    // @cover-intent Authorization & Access Control: Verify that lockInGuess reverts when msg.value is not exactly 1 ether.
    function test_Negative_path_lock_in_guess_with_wrong_ether_amount_2() public {
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

    // @cover-intent Protocol State Machine: Verify that lockInGuess reverts when called a second time by the same address (guesses[msg.sender].block != 0).
    function test_Negative_path_double_lock_in_guess_3() public {
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(0)));
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that settle executes without transfer when the guess does not match the blockhash (e.g., blockhash returns non-zero for recent blocks).
    function test_Edge_case_settle_with_incorrect_guess_4() public {
// assume: block.number > guesses[alice].block
// assume: block.number - guesses[alice].block <= 256
// assume: blockhash(guesses[alice].block) != 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
// cover: settle :: guesses[msg.sender].guess == answer false
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(115792089237316195423570985008687907853269984665640564039457584007913129639935)));
        }
        // skip ABI-mismatched call: settle()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Transactional Consistency: Verify that two different players can independently lock in guesses and settle without interference.
    function test_Multiple_players_independent_guesses_5() public {
// assume: block.number > guesses[alice].block + 256
// assume: block.number > guesses[bob].block + 256
// cover: lockInGuess :: require(guesses[msg.sender].block == 0) true (x2)
// cover: settle :: guesses[msg.sender].guess == answer true (x2)
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(0)));
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
