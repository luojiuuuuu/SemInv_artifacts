// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/guess_the_random_number.sol";

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

contract GuessTheRandomNumberChallenge_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function GuessTheRandomNumberChallenge_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that guessing the correct answer transfers 2 ether to the caller and reduces contract balance to 0, completing the challenge.
    function test_Guess_correct_answer_and_win_0() public {
// assume: answer is known (0) from prestate
// cover: guess :: require(msg.value == 1 ether) true
// cover: guess :: n == answer true
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        GuessTheRandomNumberChallenge target = (new GuessTheRandomNumberChallenge).value(1 ether)();
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
        target.guess.value(1 ether)(0);
        }
        {
        target.isComplete();
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that guessing an incorrect answer does not trigger a transfer and the contract retains the ether.
    function test_Guess_incorrect_answer_and_lose_1() public {
// assume: answer is 0, so guess 1 is incorrect
// cover: guess :: require(msg.value == 1 ether) true
// cover: guess :: n == answer false
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        GuessTheRandomNumberChallenge target = (new GuessTheRandomNumberChallenge).value(1 ether)();
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
        target.guess.value(1 ether)(1);
        }
        {
        target.isComplete();
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 1 ether
    }

    // @cover-intent Resource & Execution Integrity: Verify that calling guess with value less than 1 ether reverts.
    function test_Guess_with_insufficient_ether_reverts_2() public {
// cover: guess :: require(msg.value == 1 ether) false
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        GuessTheRandomNumberChallenge target = (new GuessTheRandomNumberChallenge).value(1 ether)();
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
        target.guess.value(0.5 ether)(0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that calling guess with value 0 reverts.
    function test_Guess_with_zero_ether_reverts_3() public {
// cover: guess :: require(msg.value == 1 ether) false
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        GuessTheRandomNumberChallenge target = (new GuessTheRandomNumberChallenge).value(1 ether)();
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
        target.guess(0);
        }
    }

    // @cover-intent Protocol State Machine: Verify that after the contract balance is 0 (challenge complete), further guesses still require 1 ether but cannot trigger transfer (balance insufficient).
    function test_Multiple_guesses_after_correct_answer_4() public {
// assume: answer is 0
// cover: guess :: require(msg.value == 1 ether) true
// cover: guess :: n == answer true
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        GuessTheRandomNumberChallenge target = (new GuessTheRandomNumberChallenge).value(1 ether)();
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
        target.guess.value(1 ether)(0);
        }
        {
        target.guess.value(1 ether)(0);
        }
        {
        target.isComplete();
        }
        vm.stopPrank();
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_isComplete_sequence_5() public {
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        GuessTheRandomNumberChallenge target = (new GuessTheRandomNumberChallenge).value(1 ether)();
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
        target.isComplete();
        }
    }

    // @cover-intent minimal test for guess
    function test_perfn_guess_6() public {
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        GuessTheRandomNumberChallenge target = (new GuessTheRandomNumberChallenge).value(1 ether)();
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
        target.guess(1);
        }
    }

}
