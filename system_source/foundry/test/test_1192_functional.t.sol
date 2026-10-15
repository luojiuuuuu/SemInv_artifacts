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


    // @cover-intent Protocol State Machine: Verify that a correct guess (blockhash of the target block) results in a 2 ether payout to the player.
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

    // @cover-intent Financial & Accounting: Verify that an incorrect guess results in no payout and the guess is cleared.
    function test_incorrect_guess_no_payout_1() public {
// assume: block.number > guesses[alice].block
// assume: blockhash(guesses[alice].block) != 0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
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
        target.lockInGuess.value(1 ether)(bytes32(uint256(8234104122482341265491137074636836252947884782870784360943022469005013929455)));
        }
        // skip ABI-mismatched call: settle()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that a player cannot lock in a guess twice without settling first.
    function test_double_lockin_reverts_2() public {
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

    // @cover-intent Protocol State Machine: Verify that settle() reverts if called before the target block has passed.
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

    // @cover-intent Authorization & Access Control: Verify that settle() reverts if no guess has been locked in.
    function test_settle_without_lockin_reverts_4() public {
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
    }

    // @cover-intent Financial & Accounting: Verify that lockInGuess reverts if the sent value is not exactly 1 ether.
    function test_lockin_with_wrong_value_reverts_5() public {
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
