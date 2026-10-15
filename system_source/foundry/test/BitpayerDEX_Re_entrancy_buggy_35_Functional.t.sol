// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_35.sol";

// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

contract BitpayerDEX_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() external payable { }


    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }


    // @cover-intent Financial & Accounting: Verify that depositing ETH increases the user's balance and withdrawing decreases it, with supply conserved.
    function test_Basic_deposit_and_withdraw_ETH_0() public {
// cover: deposit :: tokens[0][msg.sender] += msg.value
// cover: withdraw :: require(!safeGuard)
// cover: withdraw :: require(tokens[0][msg.sender] >= amount)
        vm.startPrank(alice);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: deposit()
        {
        target.balanceOf(address(0), alice);
        }
        {
        target.withdraw(50 ether);
        }
        {
        target.balanceOf(address(0), alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 50 ether
    }

    // @cover-intent Financial & Accounting: Verify token deposit and withdrawal work correctly with a mock ERC20 token.
    function test_Deposit_and_withdraw_token_1() public {
// assume: tokenAddr != address(0)
// assume: alice has approved target for 500 tokens
// cover: depositToken :: require(token!=address(0))
// cover: depositToken :: ERC20Essential(token).transferFrom(msg.sender, this, amount)
// cover: withdrawToken :: require(!safeGuard)
// cover: withdrawToken :: require(tokens[token][msg.sender] >= amount)
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip malformed call: depositToken(tokenAddr, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenAddr)
        // skip malformed call: balanceOf(tokenAddr, alice) (bad raw arg for balanceOf.arg0: type=address, raw=tokenAddr)
        // skip malformed call: withdrawToken(tokenAddr, 200) (bad raw arg for withdrawToken.arg0: type=address, raw=tokenAddr)
        // skip malformed call: balanceOf(tokenAddr, alice) (bad raw arg for balanceOf.arg0: type=address, raw=tokenAddr)
        vm.stopPrank();
        // TODO assert: alice.balance == 300
    }

    // @cover-intent Authorization & Access Control: Only owner can change the trading fee; non-owner is rejected.
    function test_Owner_changes_trading_fee_2() public {
// cover: changetradingFee :: onlyOwner modifier
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.changetradingFee(100);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changetradingFee(200);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: tradingFee()
        {
            uint256 __v1 = uint256(target.tradingFee());
            _assertRelU(__v1, 0, 100, "call:tradingFee==100");
        }
    }

    // @cover-intent Authorization & Access Control: Only owner can change the fee account address.
    function test_Owner_changes_fee_account_3() public {
// cover: changeFeeAccount :: onlyOwner modifier
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.changeFeeAccount(bob);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.changeFeeAccount(carol);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: feeAccount()
    }

    // @cover-intent Protocol State Machine: Only owner can toggle safeGuard; when active, withdraw and trade are blocked.
    function test_Owner_toggles_safeGuard_4() public {
// cover: changeSafeguardStatus :: if (safeGuard == false) -> true
// cover: changeSafeguardStatus :: else -> safeGuard = false
// cover: withdraw :: require(!safeGuard) -> revert
// cover: withdraw :: require(!safeGuard) -> ok
        vm.startPrank(alice);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: deposit()
        vm.prank(owner);
        // skip ABI-mismatched call: changeSafeguardStatus()
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw(1 ether);
        }
        vm.startPrank(owner);
        // skip ABI-mismatched call: changeSafeguardStatus()
        {
        target.withdraw(1 ether);
        }
        vm.stopPrank();
    }

    // @cover-intent Transactional Consistency: User can place an order and then cancel it, preventing further fills.
    function test_Place_and_cancel_an_order_5() public {
// assume: tokenAddr != address(0)
// assume: tokenAddr2 != address(0)
// assume: tokenAddr != tokenAddr2
// cover: order :: orders[msg.sender][hash] = true
// cover: cancelOrder :: require(!safeGuard)
// cover: cancelOrder :: require((orders[msg.sender][hash] || ecrecover(...) == msg.sender))
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip malformed call: order(tokenAddr, 100, tokenAddr2, 200, 99999999, 1) (bad raw arg for order.arg0: type=address, raw=tokenAddr)
        // skip malformed call: cancelOrder(tokenAddr, 100, tokenAddr2, 200, 99999999, 1, 27, 0x00, 0x00) (bad raw arg for cancelOrder.arg0: type=address, raw=tokenAddr)
        // skip malformed call: amountFilled(tokenAddr, 100, tokenAddr2, 200, 99999999, 1, alice) (bad raw arg for amountFilled.arg0: type=address, raw=tokenAddr)
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.amountFilled(tokenAddr, 100, tokenAddr2, 200, 99999999, 1, alice));
            _assertRelU(__v2, 0, 100, "call:amountFilled==100");
        }
    }

    // @cover-intent Financial & Accounting: Trade fails when taker does not have enough tokens to cover the amount plus fee.
    function test_Trade_with_insufficient_balance_6() public {
// assume: tokenAddr != address(0)
// assume: tokenAddr2 != address(0)
// assume: bob's balance of tokenAddr is 0
// cover: trade :: require(!safeGuard)
// cover: tradeBalances :: tokens[tokenGet][msg.sender].sub(amount.add(tradingFeeXfer))
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip malformed call: depositToken(tokenAddr, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenAddr)
        vm.prank(bob);
        // skip malformed call: depositToken(tokenAddr2, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenAddr2)
        vm.prank(alice);
        // skip malformed call: order(tokenAddr, 100, tokenAddr2, 200, 99999999, 1) (bad raw arg for order.arg0: type=address, raw=tokenAddr)
        vm.expectRevert();
        vm.prank(bob);
        // skip malformed call: trade(tokenAddr, 100, tokenAddr2, 200, 99999999, 1, alice, 27, 0x00, 0x00, 1000) (bad raw arg for trade.arg0: type=address, raw=tokenAddr)
    }

    // @cover-intent Authorization & Access Control: Owner can propose a new owner, who must accept to complete the transfer.
    function test_Owner_transfers_ownership_7() public {
// cover: onlyOwnerTransferOwnership :: onlyOwner modifier
// cover: acceptOwnership :: require(msg.sender == newOwner)
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.onlyOwnerTransferOwnership(bob);
        }
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: acceptOwnership()
        vm.startPrank(owner);
        // skip ABI-mismatched call: acceptOwnership()
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Owner can withdraw accumulated trading fees (ETH) from the fee account.
    function test_Withdraw_trading_fee_by_owner_8() public {
// cover: withdrawTradingFeeOwner :: onlyOwner modifier
// cover: withdrawTradingFeeOwner :: require(amount > 0)
        vm.startPrank(alice);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: deposit()
        vm.startPrank(owner);
        // skip ABI-mismatched call: availableTradingFeeOwner()
        // skip ABI-mismatched call: withdrawTradingFeeOwner()
        // skip ABI-mismatched call: availableTradingFeeOwner()
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.availableTradingFeeOwner());
            _assertRelU(__v3, 0, 0, "call:availableTradingFeeOwner==0");
        }
    }

    // @cover-intent External Interaction & Environment: The testTrade view function correctly validates whether a trade is possible.
    function test_Test_trade_view_function_9() public {
// assume: tokenAddr != address(0)
// assume: tokenAddr2 != address(0)
// assume: bob has 0 tokenAddr balance
// cover: testTrade :: tokens[tokenGet][sender] >= amount
// cover: testTrade :: availableVolume(...) >= amount
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip malformed call: depositToken(tokenAddr, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenAddr)
        vm.prank(bob);
        // skip malformed call: depositToken(tokenAddr2, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenAddr2)
        vm.prank(alice);
        // skip malformed call: order(tokenAddr, 100, tokenAddr2, 200, 99999999, 1) (bad raw arg for order.arg0: type=address, raw=tokenAddr)
        vm.startPrank(bob);
        // skip malformed call: testTrade(tokenAddr, 100, tokenAddr2, 200, 99999999, 1, alice, 27, 0x00, 0x00, 50, bob) (bad raw arg for testTrade.arg0: type=address, raw=tokenAddr)
        // skip malformed call: testTrade(tokenAddr, 100, tokenAddr2, 200, 99999999, 1, alice, 27, 0x00, 0x00, 200, bob) (bad raw arg for testTrade.arg0: type=address, raw=tokenAddr)
        vm.stopPrank();
    }

    // @cover-intent minimal test for acceptOwnership
    function test_perfn_acceptOwnership_10() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: acceptOwnership()
    }

    // @cover-intent minimal test for amountFilled
    function test_perfn_amountFilled_11() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.amountFilled(bob, 100, bob, 100, 1, 1, alice);
        }
    }

    // @cover-intent minimal test for availableTradingFeeOwner
    function test_perfn_availableTradingFeeOwner_12() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: availableTradingFeeOwner()
    }

    // @cover-intent minimal test for availableVolume
    function test_perfn_availableVolume_13() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.availableVolume(bob, 100, bob, 100, 1, 1, alice, 1, bytes32(uint256(1)), bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for balanceOf
    function test_perfn_balanceOf_14() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.balanceOf(bob, alice);
        }
    }

    // @cover-intent minimal test for bug_re_ent13
    function test_perfn_bug_re_ent13_15() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: bug_re_ent13()
    }

    // @cover-intent minimal test for bug_re_ent20
    function test_perfn_bug_re_ent20_16() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: bug_re_ent20()
    }

    // @cover-intent minimal test for bug_re_ent27
    function test_perfn_bug_re_ent27_17() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: bug_re_ent27()
    }

    // @cover-intent minimal test for bug_re_ent34
    function test_perfn_bug_re_ent34_18() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: bug_re_ent34()
    }

    // @cover-intent minimal test for bug_re_ent41
    function test_perfn_bug_re_ent41_19() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: bug_re_ent41()
    }

    // @cover-intent minimal test for buyTicket_re_ent2
    function test_perfn_buyTicket_re_ent2_20() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: buyTicket_re_ent2()
    }

    // @cover-intent minimal test for buyTicket_re_ent23
    function test_perfn_buyTicket_re_ent23_21() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: buyTicket_re_ent23()
    }

    // @cover-intent minimal test for buyTicket_re_ent30
    function test_perfn_buyTicket_re_ent30_22() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: buyTicket_re_ent30()
    }

    // @cover-intent minimal test for buyTicket_re_ent37
    function test_perfn_buyTicket_re_ent37_23() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: buyTicket_re_ent37()
    }

    // @cover-intent minimal test for buyTicket_re_ent9
    function test_perfn_buyTicket_re_ent9_24() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: buyTicket_re_ent9()
    }

    // @cover-intent minimal test for callme_re_ent14
    function test_perfn_callme_re_ent14_25() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: callme_re_ent14()
    }

    // @cover-intent minimal test for callme_re_ent21
    function test_perfn_callme_re_ent21_26() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: callme_re_ent21()
    }

    // @cover-intent minimal test for callme_re_ent35
    function test_perfn_callme_re_ent35_27() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: callme_re_ent35()
    }

    // @cover-intent minimal test for callme_re_ent42
    function test_perfn_callme_re_ent42_28() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: callme_re_ent42()
    }

    // @cover-intent minimal test for callme_re_ent7
    function test_perfn_callme_re_ent7_29() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: callme_re_ent7()
    }

    // @cover-intent minimal test for cancelOrder
    function test_perfn_cancelOrder_30() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.cancelOrder(bob, 100, bob, 100, 1, 1, 1, bytes32(uint256(1)), bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for changeFeeAccount
    function test_perfn_changeFeeAccount_31() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.changeFeeAccount(alice);
        }
    }

    // @cover-intent minimal test for changeSafeguardStatus
    function test_perfn_changeSafeguardStatus_32() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: changeSafeguardStatus()
    }

    // @cover-intent minimal test for changetradingFee
    function test_perfn_changetradingFee_33() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.changetradingFee(1);
        }
    }

    // @cover-intent minimal test for claimReward_re_ent11
    function test_perfn_claimReward_re_ent11_34() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: claimReward_re_ent11()
    }

    // @cover-intent minimal test for claimReward_re_ent25
    function test_perfn_claimReward_re_ent25_35() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: claimReward_re_ent25()
    }

    // @cover-intent minimal test for claimReward_re_ent32
    function test_perfn_claimReward_re_ent32_36() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: claimReward_re_ent32()
    }

    // @cover-intent minimal test for claimReward_re_ent39
    function test_perfn_claimReward_re_ent39_37() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: claimReward_re_ent39()
    }

    // @cover-intent minimal test for claimReward_re_ent4
    function test_perfn_claimReward_re_ent4_38() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: claimReward_re_ent4()
    }

    // @cover-intent minimal test for deposit
    function test_perfn_deposit_39() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: deposit()
    }

    // @cover-intent minimal test for depositToken
    function test_perfn_depositToken_40() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.depositToken(bob, 100);
        }
    }

    // @cover-intent minimal test for feeAccount
    function test_perfn_feeAccount_41() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: feeAccount()
    }

    // @cover-intent minimal test for onlyOwnerTransferOwnership
    function test_perfn_onlyOwnerTransferOwnership_42() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.onlyOwnerTransferOwnership(alice);
        }
    }

    // @cover-intent minimal test for order
    function test_perfn_order_43() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.order(bob, 100, bob, 100, 1, 1);
        }
    }

    // @cover-intent minimal test for orderFills
    function test_perfn_orderFills_44() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.orderFills(alice, bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for orders
    function test_perfn_orders_45() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.orders(alice, bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for owner
    function test_perfn_owner_46() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent minimal test for safeGuard
    function test_perfn_safeGuard_47() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: safeGuard()
    }

    // @cover-intent minimal test for testTrade
    function test_perfn_testTrade_48() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.testTrade(bob, 100, bob, 100, 1, 1, alice, 1, bytes32(uint256(1)), bytes32(uint256(1)), 100, alice);
        }
    }

    // @cover-intent minimal test for tokens
    function test_perfn_tokens_49() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.tokens(alice, alice);
        }
    }

    // @cover-intent minimal test for trade
    function test_perfn_trade_50() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.trade(bob, 100, bob, 100, 1, 1, alice, 1, bytes32(uint256(1)), bytes32(uint256(1)), 100);
        }
    }

    // @cover-intent minimal test for tradingFee
    function test_perfn_tradingFee_51() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: tradingFee()
    }

    // @cover-intent minimal test for withdraw
    function test_perfn_withdraw_52() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.withdraw(100);
        }
    }

    // @cover-intent minimal test for withdrawBalance_re_ent12
    function test_perfn_withdrawBalance_re_ent12_53() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent12()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent19
    function test_perfn_withdrawBalance_re_ent19_54() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent19()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent26
    function test_perfn_withdrawBalance_re_ent26_55() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent26()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent33
    function test_perfn_withdrawBalance_re_ent33_56() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent33()
    }

    // @cover-intent minimal test for withdrawBalance_re_ent40
    function test_perfn_withdrawBalance_re_ent40_57() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdrawBalance_re_ent40()
    }

    // @cover-intent minimal test for withdrawFunds_re_ent10
    function test_perfn_withdrawFunds_re_ent10_58() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.withdrawFunds_re_ent10(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent17
    function test_perfn_withdrawFunds_re_ent17_59() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.withdrawFunds_re_ent17(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent3
    function test_perfn_withdrawFunds_re_ent3_60() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.withdrawFunds_re_ent3(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent31
    function test_perfn_withdrawFunds_re_ent31_61() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.withdrawFunds_re_ent31(1);
        }
    }

    // @cover-intent minimal test for withdrawFunds_re_ent38
    function test_perfn_withdrawFunds_re_ent38_62() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.withdrawFunds_re_ent38(1);
        }
    }

    // @cover-intent minimal test for withdrawToken
    function test_perfn_withdrawToken_63() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        target.withdrawToken(bob, 100);
        }
    }

    // @cover-intent minimal test for withdrawTradingFeeOwner
    function test_perfn_withdrawTradingFeeOwner_64() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdrawTradingFeeOwner()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent1
    function test_perfn_withdraw_balances_re_ent1_65() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent1()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent21
    function test_perfn_withdraw_balances_re_ent21_66() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent21()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent36
    function test_perfn_withdraw_balances_re_ent36_67() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent36()
    }

    // @cover-intent minimal test for withdraw_balances_re_ent8
    function test_perfn_withdraw_balances_re_ent8_68() public {
        vm.startPrank(owner);
        BitpayerDEX target = new BitpayerDEX();
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
        // skip ABI-mismatched call: withdraw_balances_re_ent8()
    }

}
