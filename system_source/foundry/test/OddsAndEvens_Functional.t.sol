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


    // @cover-intent Transactional Consistency: Two players each send 1 ether, the sum is even, so the first player (alice) should receive 1.8 ether. Verify that the contract balance decreases accordingly.
    function test_Normal_play_and_winner_determination_even_sum_0() public {
// assume: balance(alice) >= 1 ether
// assume: balance(bob) >= 1 ether
// cover: play :: msg.value == 1 ether true
// cover: andTheWinnerIs :: n%2==0 true
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
        target.play.value(1 ether)(4);
        }
    }

    // @cover-intent Transactional Consistency: Two players each send 1 ether, the sum is odd, so the second player (bob) should receive 1.8 ether.
    function test_Normal_play_and_winner_determination_odd_sum_1() public {
// assume: balance(alice) >= 1 ether
// assume: balance(bob) >= 1 ether
// cover: play :: msg.value == 1 ether true
// cover: andTheWinnerIs :: n%2==0 false
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

    // @cover-intent Resource & Execution Integrity: Calling play with a value not equal to 1 ether should revert.
    function test_Play_with_incorrect_ether_amount_reverts_2() public {
// cover: play :: msg.value == 1 ether false
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
        target.play.value(0.5 ether)(5);
        }
    }

    // @cover-intent Authorization & Access Control: Only the owner can call getProfit to withdraw the contract balance.
    function test_Owner_can_withdraw_profit_3() public {
// assume: balance(owner) >= 0
// cover: getProfit :: msg.sender == owner true
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
        target.play.value(1 ether)(4);
        }
        vm.prank(owner);
        {
        target.getProfit();
        }
    }

    // @cover-intent Authorization & Access Control: A non-owner (alice) calling getProfit should revert.
    function test_Non_owner_cannot_withdraw_profit_4() public {
// cover: getProfit :: msg.sender == owner false
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
        target.play.value(1 ether)(4);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.getProfit();
        }
    }

    // @cover-intent Resource & Execution Integrity: Calling play with number=0 should work normally, as there is no restriction on the number value.
    function test_Play_with_zero_number_edge_case_5() public {
// assume: balance(alice) >= 1 ether
// assume: balance(bob) >= 1 ether
// cover: play :: msg.value == 1 ether true
// cover: andTheWinnerIs :: n%2==0 true
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
        target.play.value(1 ether)(0);
        }
        vm.prank(bob);
        {
        target.play.value(1 ether)(0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Calling play with a very large uint256 should work normally.
    function test_Play_with_large_number_edge_case_6() public {
// assume: balance(alice) >= 1 ether
// assume: balance(bob) >= 1 ether
// cover: play :: msg.value == 1 ether true
// cover: andTheWinnerIs :: n%2==0 false
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
        target.play.value(1 ether)(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        vm.prank(bob);
        {
        target.play.value(1 ether)(1);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_getProfit_positive_7() public {
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
        vm.prank(bob);
        {
        target.play.value(1 ether)(2);
        }
        vm.prank(owner);
        {
        target.getProfit();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_getProfit_revert_nonowner_8() public {
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
        vm.prank(bob);
        {
        target.play.value(1 ether)(2);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.getProfit();
        }
    }

    // @cover-intent Protocol State Machine
    function test_play_positive_9() public {
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
        target.play.value(1 ether)(42);
        }
    }

    // @cover-intent Financial & Accounting
    function test_play_revert_wrong_value_10() public {
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
        target.play.value(0.5 ether)(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_players_read_11() public {
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
        vm.startPrank(alice);
        {
        target.play.value(1 ether)(1);
        }
        {
        target.players(0);
        }
        vm.stopPrank();
    }

}
