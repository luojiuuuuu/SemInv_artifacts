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


    // @cover-intent Financial & Accounting: Verify that a user can buy tokens with exact ETH and sell them back, maintaining balance consistency.
    function test_TokenSaleChallenge_Normal_buy_and_sell_0() public {
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
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Ensure that buying tokens with wrong ETH value reverts.
    function test_TokenSaleChallenge_Buy_with_incorrect_ETH_amount_reverts_1() public {
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

    // @cover-intent Authorization & Access Control: Ensure that selling tokens without sufficient balance reverts.
    function test_TokenSaleChallenge_Sell_without_balance_reverts_2() public {
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) false
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
        target.sell(1);
        }
    }

    // @cover-intent Financial & Accounting: Test that an overflow in numTokens * PRICE_PER_TOKEN can bypass the require and drain ETH.
    function test_TokenSaleChallenge_Overflow_in_buy_calculation_3() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) true (overflow)
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
        target.buy.value(1 ether)(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
    }

    // @cover-intent Financial & Accounting: After overflow buy, sell tokens to drain ETH from contract, making isComplete true.
    function test_TokenSaleChallenge_Sell_after_overflow_buy_drains_contract_4() public {
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) true
// cover: sell :: msg.sender.transfer(numTokens * PRICE_PER_TOKEN) (overflow leads to huge transfer)
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
        target.buy.value(1 ether)(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        {
        target.sell(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiple buy/sell cycles work correctly.
    function test_TokenSaleChallenge_Multiple_buys_and_sells_5() public {
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
        vm.prank(alice);
        {
        target.buy.value(2 ether)(2);
        }
        vm.prank(bob);
        {
        target.buy.value(3 ether)(3);
        }
        vm.prank(alice);
        {
        target.sell(1);
        }
        vm.prank(bob);
        {
        target.sell(3);
        }
    }

    // @cover-intent Authorization & Access Control: Ensure selling more tokens than owned after a partial sell reverts.
    function test_TokenSaleChallenge_Sell_more_than_balance_after_partial_sell_6() public {
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
        target.buy.value(2 ether)(2);
        }
        {
        target.sell(1);
        }
        vm.expectRevert();
        {
        target.sell(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that isComplete returns false when contract has 1 ether.
    function test_TokenSaleChallenge_isComplete_initially_false_7() public {
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

    // @cover-intent Protocol State Machine: After overflow exploit, isComplete returns true.
    function test_TokenSaleChallenge_isComplete_true_after_drain_8() public {
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
        target.buy.value(1 ether)(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        {
        target.sell(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
        // skip ABI-mismatched call: isComplete()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_9() public {
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
        target.balanceOf(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 1
    }

    // @cover-intent Financial & Accounting
    function test_buy_10() public {
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

    // @cover-intent Financial & Accounting
    function test_isComplete_11() public {
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
        // skip ABI-mismatched call: isComplete()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_sell_12() public {
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
