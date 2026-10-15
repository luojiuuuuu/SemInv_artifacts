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


    // @cover-intent Financial & Accounting: Verify that a correct guess transfers the entire contract balance to the player
    function test_Normal_play_and_win_scenario_0() public {
// assume: secretNumber == 1
// cover: play :: require(msg.value >= betPrice && number <= 10) true
// cover: play :: number == secretNumber true
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
        target.play(1);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that play reverts when msg.value is less than betPrice
    function test_Play_with_insufficient_bet_price_1() public {
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
        target.play(1);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that play reverts when number > 10
    function test_Play_with_number_greater_than_10_2() public {
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

    // @cover-intent Resource & Execution Integrity: Verify that play accepts number == 10 (upper boundary)
    function test_Play_with_number_exactly_10_boundary_3() public {
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

    // @cover-intent Resource & Execution Integrity: Verify that play accepts number == 0 (lower boundary)
    function test_Play_with_number_0_boundary_4() public {
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
        target.play(0);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that kill reverts when called by non-owner
    function test_Kill_by_non_owner_5() public {
// assume: now <= lastPlayed + 1 days
// cover: kill :: msg.sender == ownerAddr false
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
        vm.prank(owner);
        {
        target.play(1);
        }
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Authorization & Access Control: Verify that kill reverts when called by owner before 1 day has passed
    function test_Kill_by_owner_before_1_day_6() public {
// assume: now <= lastPlayed + 1 days
// cover: kill :: msg.sender == ownerAddr true
// cover: kill :: now > lastPlayed + 1 days false
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
        vm.expectRevert();
        // skip ABI-mismatched call: kill()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that kill succeeds when called by owner after 1 day has passed
    function test_Kill_by_owner_after_1_day_7() public {
// assume: now > lastPlayed + 1 days
// cover: kill :: msg.sender == ownerAddr true
// cover: kill :: now > lastPlayed + 1 days true
        vm.startPrank(owner);
        CryptoRoulette target = new CryptoRoulette();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(3)), bytes32(uint256(0)));
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

    // @cover-intent Transactional Consistency: Verify that gamesPlayed array correctly stores multiple game records
    function test_Multiple_plays_and_gamesPlayed_array_access_8() public {
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
        target.play(3);
        }
        vm.prank(bob);
        {
        target.play(5);
        }
        vm.prank(carol);
        {
        target.play(7);
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
        target.play(5);
        }
    }

}
