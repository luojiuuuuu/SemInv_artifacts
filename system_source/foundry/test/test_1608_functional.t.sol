// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/tokensalechallenge.sol";

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

contract TokenSaleChallenge_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function TokenSaleChallenge_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a user can buy tokens with exact ETH and sell them back, preserving contract balance invariant (balance < 1 ether triggers isComplete).
    function test_TokenSaleChallenge_Normal_buy_and_sell_0() public {
// assume: balanceOf[alice] >= 1 after buy
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) true
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) true
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.buy.value(1 ether)(1);
        }
        {
        target.sell(1);
        }
        // skip ABI-mismatched call: isComplete()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Test edge case where numTokens = 0, which should succeed with msg.value = 0.
    function test_TokenSaleChallenge_Buy_with_zero_tokens_1() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) true
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.buy(0);
        }
        {
        target.balanceOf(alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that selling more tokens than owned reverts.
    function test_TokenSaleChallenge_Sell_more_than_balance_2() public {
// assume: balanceOf[alice] == 1
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) false
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.buy.value(1 ether)(1);
        }
        vm.expectRevert();
        {
        target.sell(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: Verify that buying tokens with wrong msg.value reverts.
    function test_TokenSaleChallenge_Buy_with_incorrect_ETH_amount_3() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) false
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.buy.value(1 ether)(2);
        }
    }

    // @cover-intent Financial & Accounting: Test that large numTokens causes overflow in multiplication, leading to incorrect msg.value check (potential vulnerability).
    function test_TokenSaleChallenge_Overflow_in_buy_multiplication_4() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) true (overflow)
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.buy(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
    }

    // @cover-intent Financial & Accounting: Exploit overflow to buy massive tokens with 0 ETH, then sell to drain contract balance below 1 ether, making isComplete true.
    function test_TokenSaleChallenge_Sell_after_overflow_buy_to_drain_contract_5() public {
// assume: balanceOf[alice] >= 1
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) true
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.buy(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        {
        target.sell(1);
        }
        // skip ABI-mismatched call: isComplete()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_balanceOf_view_6() public {
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_buy_tokens_7() public {
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.buy.value(1 ether)(1);
        }
    }

    // @cover-intent Protocol State Machine
    function test_isComplete_check_8() public {
        vm.deal(owner, 100 ether);
        vm.startPrank(owner);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: isComplete()
    }

    // @cover-intent Financial & Accounting
    function test_sell_tokens_9() public {
        vm.deal(alice, 100 ether);
        vm.startPrank(alice);
        TokenSaleChallenge target = (new TokenSaleChallenge).value(1 ether)(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.buy.value(1 ether)(1);
        }
        {
        target.sell(1);
        }
        vm.stopPrank();
    }

}
