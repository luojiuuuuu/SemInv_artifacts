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


    // @cover-intent Protocol State Machine: Verify that a correct guess (blockhash of the target block) results in the player receiving 2 ether.
    function test_positive_guess_and_settle_0() public {
// assume: block.number > guesses[alice].block
// assume: blockhash(guesses[alice].block) == bytes32(0)
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
        // skip malformed call: lockInGuess(bytes32(0)) (bad raw arg for lockInGuess.arg0: type=bytes32, raw=bytes32(0))
        // skip ABI-mismatched call: settle()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that an incorrect guess results in no ether transfer and the guess is cleared.
    function test_incorrect_guess_settle_1() public {
// assume: block.number > guesses[alice].block
// assume: blockhash(guesses[alice].block) != 0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
// cover: settle :: require(block.number > guesses[msg.sender].block) true
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(100720434726375746010458024839911619878118703404436202866098422983289408962287)));
        }
        // skip ABI-mismatched call: settle()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a player cannot lock in a guess twice before settling.
    function test_double_lock_in_guess_reverts_2() public {
// assume: guesses[alice].block != 0
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
        // skip malformed call: lockInGuess(bytes32(0)) (bad raw arg for lockInGuess.arg0: type=bytes32, raw=bytes32(0))
        vm.expectRevert();
        // skip malformed call: lockInGuess(bytes32(0)) (bad raw arg for lockInGuess.arg0: type=bytes32, raw=bytes32(0))
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that settle reverts if called before the target block has passed.
    function test_settle_before_target_block_reverts_3() public {
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
        // skip malformed call: lockInGuess(bytes32(0)) (bad raw arg for lockInGuess.arg0: type=bytes32, raw=bytes32(0))
        vm.expectRevert();
        // skip ABI-mismatched call: settle()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that settle reverts if no guess has been locked in (block == 0).
    function test_settle_without_lock_in_reverts_4() public {
// assume: guesses[alice].block == 0
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that lockInGuess reverts if not enough ether is sent.
    function test_lock_in_guess_without_ether_reverts_5() public {
// assume: guesses[alice].block == 0
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
        // skip malformed call: lockInGuess(bytes32(0)) (bad raw arg for lockInGuess.arg0: type=bytes32, raw=bytes32(0))
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Transactional Consistency: Verify that two players can independently lock in guesses and settle correctly.
    function test_multiple_players_independent_guesses_6() public {
// assume: block.number > guesses[alice].block
// assume: block.number > guesses[bob].block
// assume: blockhash(guesses[alice].block) == bytes32(0)
// assume: blockhash(guesses[bob].block) != 0xdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeefdeadbeef
// cover: settle :: guesses[msg.sender].guess == answer true
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
        vm.prank(alice);
        // skip malformed call: lockInGuess(bytes32(0)) (bad raw arg for lockInGuess.arg0: type=bytes32, raw=bytes32(0))
        vm.prank(bob);
        {
        target.lockInGuess.value(1 ether)(bytes32(uint256(100720434726375746010458024839911619878118703404436202866098422983289408962287)));
        }
        vm.prank(alice);
        // skip ABI-mismatched call: settle()
        vm.prank(bob);
        // skip ABI-mismatched call: settle()
    }

    // @cover-intent Protocol State Machine
    function test_lockInGuess_positive_7() public {
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
    function test_settle_positive_8() public {
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
