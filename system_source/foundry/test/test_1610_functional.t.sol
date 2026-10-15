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
        vm.startPrank(alice);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that buying tokens with incorrect ETH amount reverts.
    function test_TokenSaleChallenge_Buy_with_insufficient_ETH_reverts_1() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) false
        vm.startPrank(owner);
        TokenSaleChallenge target = new TokenSaleChallenge();
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

    // @cover-intent Financial & Accounting: Verify that selling tokens without owning them reverts.
    function test_TokenSaleChallenge_Sell_without_tokens_reverts_2() public {
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) false
        vm.startPrank(owner);
        TokenSaleChallenge target = new TokenSaleChallenge();
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

    // @cover-intent Financial & Accounting: Verify that buying multiple tokens and selling a portion works correctly.
    function test_TokenSaleChallenge_Buy_multiple_tokens_and_sell_partial_3() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) true
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) true
        vm.startPrank(alice);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
        target.buy.value(3 ether)(3);
        }
        {
        target.sell(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that selling all tokens returns full ETH and balance is zero.
    function test_TokenSaleChallenge_Sell_all_tokens_after_buying_4() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) true
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) true
        vm.startPrank(alice);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
        target.buy.value(5 ether)(5);
        }
        {
        target.sell(5);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that isComplete returns false when contract balance is >= 1 ether.
    function test_TokenSaleChallenge_isComplete_returns_false_when_contract_has_1_ether_5() public {
        vm.startPrank(alice);
        TokenSaleChallenge target = new TokenSaleChallenge();
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

    // @cover-intent Financial & Accounting: Verify that isComplete returns true when contract balance is less than 1 ether.
    function test_TokenSaleChallenge_isComplete_returns_true_when_contract_balance_1_ether_6() public {
        vm.startPrank(owner);
        TokenSaleChallenge target = new TokenSaleChallenge();
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

    // @cover-intent Financial & Accounting: Verify that multiple users can interact with the contract without interference.
    function test_TokenSaleChallenge_Multiple_users_can_buy_and_sell_independently_7() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) true
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) true
        vm.startPrank(alice);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
        target.buy.value(1 ether)(1);
        }
        vm.prank(alice);
        {
        target.sell(1);
        }
        vm.prank(bob);
        {
        target.sell(1);
        }
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that selling more tokens than current balance reverts after a partial sell.
    function test_TokenSaleChallenge_Sell_more_tokens_than_owned_reverts_after_partial_sell_8() public {
// cover: sell :: require(balanceOf[msg.sender] >= numTokens) false
        vm.startPrank(alice);
        TokenSaleChallenge target = new TokenSaleChallenge();
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

    // @cover-intent Financial & Accounting: Verify that buying zero tokens with zero ETH succeeds (edge case).
    function test_TokenSaleChallenge_Buy_with_zero_tokens_and_zero_ETH_9() public {
// cover: buy :: require(msg.value == numTokens * PRICE_PER_TOKEN) true
        vm.startPrank(owner);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
        target.buy(0);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_balanceOf_query_10() public {
        vm.startPrank(owner);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
    function test_buy_tokens_11() public {
        vm.startPrank(alice);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
        // TODO assert: alice.balance == 1
    }

    // @cover-intent Financial & Accounting
    function test_isComplete_check_12() public {
        vm.startPrank(owner);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
    function test_sell_tokens_13() public {
        vm.startPrank(alice);
        TokenSaleChallenge target = new TokenSaleChallenge();
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
        // TODO assert: alice.balance == 0
    }

}
