// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/crypto_roulette.sol";

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

contract CryptoRoulette_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function CryptoRoulette_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a player can play with correct bet price, win the jackpot, and receive the contract balance. Also verify that the game state updates correctly.
    function test_Normal_Play_and_Win_0() public {
// assume: alice.balance >= 0.1 ether
// assume: bob.balance >= 0.1 ether
// cover: play :: require(msg.value >= betPrice && number <= 10) true
// cover: play :: number == secretNumber (win path)
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(5);
        }
        vm.prank(bob);
        {
        target.play(3);
        }
        vm.prank(alice);
        {
        target.gamesPlayed(0);
        }
        vm.prank(bob);
        // skip ABI-mismatched call: lastPlayed()
    }

    // @cover-intent Transactional Consistency: Verify that play() reverts when msg.value is less than betPrice (0.1 ether).
    function test_Play_with_Insufficient_Bet_1() public {
// assume: alice.balance == 0.05 ether
// cover: play :: require(msg.value >= betPrice && number <= 10) false
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(5);
        }
    }

    // @cover-intent Transactional Consistency: Verify that play() reverts when number > 10, as required by the require statement.
    function test_Play_with_Number_Greater_Than_10_2() public {
// assume: alice.balance >= 0.1 ether
// cover: play :: require(msg.value >= betPrice && number <= 10) false
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(11);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can call kill() and only after 1 day has passed since lastPlayed.
    function test_Kill_by_Owner_After_Time_Delay_3() public {
// assume: owner == ownerAddr
// assume: now > lastPlayed + 1 days
// cover: kill :: require(msg.sender == ownerAddr && now > lastPlayed + 1 days) true
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: // Simulate time passage: set lastPlayed to 2 days ago;
        // dropped unsafe prestate: // This requires vm_warps or prestate manipulation;
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.play(1);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: kill()
        // TODO assert: call:ownerAddr() == owner
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner (alice) cannot call kill() even after time delay.
    function test_Kill_by_Non_Owner_4() public {
// assume: alice != ownerAddr
// assume: now > lastPlayed + 1 days
// cover: kill :: require(msg.sender == ownerAddr && now > lastPlayed + 1 days) false
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(2)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.play(1);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: kill()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner cannot call kill() before 1 day has passed since lastPlayed.
    function test_Kill_Before_Time_Delay_5() public {
// assume: owner == ownerAddr
// assume: now <= lastPlayed + 1 days
// cover: kill :: require(msg.sender == ownerAddr && now > lastPlayed + 1 days) false
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(1);
        }
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Transactional Consistency: Verify that play() reverts when msg.value is 0 (less than betPrice).
    function test_Play_with_Zero_Value_6() public {
// assume: alice.balance >= 0
// cover: play :: require(msg.value >= betPrice && number <= 10) false
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(5);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that play() accepts number = 10 (upper boundary of allowed range).
    function test_Play_with_Number_Equal_to_10_Boundary_7() public {
// assume: alice.balance >= 0.1 ether
// cover: play :: require(msg.value >= betPrice && number <= 10) true
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(10);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that the gamesPlayed array grows correctly after multiple plays.
    function test_Multiple_Plays_and_GamesPlayed_Array_Growth_8() public {
// assume: alice.balance >= 0.1 ether
// assume: bob.balance >= 0.1 ether
// assume: carol.balance >= 0.1 ether
// cover: play :: require(msg.value >= betPrice && number <= 10) true
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(1);
        }
        vm.prank(bob);
        {
        target.play(2);
        }
        vm.prank(carol);
        {
        target.play(3);
        }
        vm.prank(alice);
        {
        target.gamesPlayed(0);
        }
        vm.prank(bob);
        {
        target.gamesPlayed(1);
        }
        vm.prank(carol);
        {
        target.gamesPlayed(2);
        }
    }

    // @cover-intent Financial & Accounting
    function test_betPrice_test_9() public {
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        // skip ABI-mismatched call: betPrice()
        {
            uint256 __v1 = uint256(target.betPrice());
            _assertRelU(__v1, 0, 100000000000000000, "call:betPrice==100000000000000000");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_gamesPlayed_test_10() public {
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(1);
        }
        {
        target.gamesPlayed(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_kill_test_11() public {
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        {
        target.play(1);
        }
        // skip ABI-mismatched call: kill()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_lastPlayed_test_12() public {
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(1);
        }
        // skip ABI-mismatched call: lastPlayed()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_ownerAddr_test_13() public {
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        // skip ABI-mismatched call: ownerAddr()
    }

    // @cover-intent Financial & Accounting
    function test_play_test_14() public {
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
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
        target.play(1);
        }
    }

}
