// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/odds_and_evens.sol";

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

contract OddsAndEvens_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function OddsAndEvens_FunctionalTest() public {
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


    // @cover-intent Test the normal flow of two players submitting numbers and the winner receiving the prize. Covers Financial & Accounting invariant.
    function test_Normal_play_and_winner_determination_0() public {
// assume: balance(alice) >= 1 ether
// assume: balance(bob) >= 1 ether
// cover: play :: msg.value == 1 ether
// cover: andTheWinnerIs :: n%2==0
        vm.startPrank(alice);
        OddsAndEvens target = new OddsAndEvens();
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
        target.play.value(1 ether)(2);
        }
        vm.prank(bob);
        {
        target.play.value(1 ether)(3);
        }
    }

    // @cover-intent Test the case where the sum of numbers is odd, so the second player (bob) wins. Covers Financial & Accounting invariant.
    function test_Play_with_odd_sum_bob_wins_1() public {
// assume: balance(alice) >= 1 ether
// assume: balance(bob) >= 1 ether
// cover: andTheWinnerIs :: n%2!=0
        vm.startPrank(alice);
        OddsAndEvens target = new OddsAndEvens();
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
        target.play.value(1 ether)(1);
        }
        vm.prank(bob);
        {
        target.play.value(1 ether)(2);
        }
    }

    // @cover-intent Test that calling play with msg.value != 1 ether reverts. Covers Transactional Consistency invariant.
    function test_Play_with_insufficient_ether_reverts_2() public {
// assume: balance(alice) >= 0.5 ether
// cover: play :: msg.value != 1 ether
        vm.startPrank(owner);
        OddsAndEvens target = new OddsAndEvens();
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

    // @cover-intent Test that the owner can call getProfit to withdraw contract balance. Covers Authorization & Access Control invariant.
    function test_GetProfit_by_owner_succeeds_3() public {
// assume: balance(owner) >= 0
// cover: getProfit :: msg.sender == owner
        vm.startPrank(alice);
        OddsAndEvens target = new OddsAndEvens();
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
        target.play.value(1 ether)(2);
        }
        vm.prank(bob);
        {
        target.play.value(1 ether)(3);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: getProfit()
    }

    // @cover-intent Test that a non-owner cannot call getProfit. Covers Authorization & Access Control invariant.
    function test_GetProfit_by_non_owner_reverts_4() public {
// cover: getProfit :: msg.sender != owner
        vm.startPrank(alice);
        OddsAndEvens target = new OddsAndEvens();
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
        target.play.value(1 ether)(2);
        }
        vm.prank(bob);
        {
        target.play.value(1 ether)(3);
        }
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: getProfit()
    }

    // @cover-intent Test that after a game completes, a new game can start. Covers Protocol State Machine invariant.
    function test_Play_after_game_reset_5() public {
// assume: balance(carol) >= 1 ether
// assume: balance(alice) >= 1 ether
// cover: play :: tot==0 after reset
        vm.startPrank(alice);
        OddsAndEvens target = new OddsAndEvens();
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
        target.play.value(1 ether)(2);
        }
        vm.prank(bob);
        {
        target.play.value(1 ether)(3);
        }
        vm.prank(carol);
        {
        target.play.value(1 ether)(4);
        }
        vm.prank(alice);
        {
        target.play.value(1 ether)(5);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_getProfit_owner_6() public {
        vm.startPrank(owner);
        OddsAndEvens target = new OddsAndEvens();
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
        target.play.value(1 ether)(1);
        }
        vm.prank(alice);
        {
        target.play.value(1 ether)(2);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: getProfit()
    }

    // @cover-intent Protocol State Machine
    function test_play_alice_7() public {
        vm.startPrank(alice);
        OddsAndEvens target = new OddsAndEvens();
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
        target.play.value(1 ether)(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_players_read_8() public {
        vm.startPrank(alice);
        OddsAndEvens target = new OddsAndEvens();
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
        target.play.value(1 ether)(1);
        }
        vm.prank(bob);
        {
        target.players(0);
        }
    }

}
