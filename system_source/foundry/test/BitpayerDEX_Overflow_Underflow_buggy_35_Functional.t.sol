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


    // @cover-intent Financial & Accounting: Verify basic ETH deposit and withdraw functionality with correct balance updates.
    function test_Basic_deposit_and_withdraw_ETH_0() public {
// assume: alice has 100 ether initial balance
// cover: deposit :: tokens[0][msg.sender] += msg.value
// cover: withdraw :: require(!safeGuard) true
// cover: withdraw :: require(tokens[0][msg.sender] >= amount) true
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
        target.withdraw(5 ether);
        }
        {
        target.balanceOf(address(0), alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100 ether - 10 ether + 5 ether
        // TODO assert: BitpayerDEX.balance == 5 ether
    }

    // @cover-intent Financial & Accounting: Verify token deposit and withdraw with ERC20 transferFrom.
    function test_Deposit_and_withdraw_token_1() public {
// assume: tokenAddress is a valid ERC20 token contract
// assume: alice has 1000 tokens and approved 500 to BitpayerDEX
// cover: depositToken :: require(token!=address(0)) true
// cover: depositToken :: require(transferFrom succeeds) true
// cover: withdrawToken :: require(!safeGuard) true
// cover: withdrawToken :: require(tokens[token][msg.sender] >= amount) true
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
        // skip malformed call: depositToken(tokenAddress, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenAddress)
        // skip malformed call: balanceOf(tokenAddress, alice) (bad raw arg for balanceOf.arg0: type=address, raw=tokenAddress)
        // skip malformed call: withdrawToken(tokenAddress, 200) (bad raw arg for withdrawToken.arg0: type=address, raw=tokenAddress)
        // skip malformed call: balanceOf(tokenAddress, alice) (bad raw arg for balanceOf.arg0: type=address, raw=tokenAddress)
        vm.stopPrank();
        // TODO assert: alice.balance == 1000 - 500 + 200
        // TODO assert: BitpayerDEX.balance == 300
    }

    // @cover-intent Protocol State Machine: Verify order placement and cancellation with correct state updates.
    function test_Place_and_cancel_order_2() public {
// assume: v, r, s are valid signature components for alice's order
// assume: tokenGet and tokenGive are valid token addresses
// cover: order :: orders[msg.sender][hash] = true
// cover: cancelOrder :: require(!safeGuard) true
// cover: cancelOrder :: require(orders[msg.sender][hash] || ecrecover == msg.sender) true
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
        // skip malformed call: order(tokenGet, 100, tokenGive, 200, 99999999, 1) (bad raw arg for order.arg0: type=address, raw=tokenGet)
        // skip malformed call: amountFilled(tokenGet, 100, tokenGive, 200, 99999999, 1, alice) (bad raw arg for amountFilled.arg0: type=address, raw=tokenGet)
        // skip malformed call: cancelOrder(tokenGet, 100, tokenGive, 200, 99999999, 1, v, r, s) (bad raw arg for cancelOrder.arg0: type=address, raw=tokenGet)
        // skip malformed call: amountFilled(tokenGet, 100, tokenGive, 200, 99999999, 1, alice) (bad raw arg for amountFilled.arg0: type=address, raw=tokenGet)
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Execute a trade with valid signature and verify balance transfers and fee deduction.
    function test_Trade_with_valid_signature_3() public {
// assume: v, r, s are valid signature for bob's order
// assume: tokenGet and tokenGive are different ERC20 tokens
// assume: tradingFee is 50 (0.5%)
// cover: trade :: require(!safeGuard) true
// cover: trade :: require(orders[user][hash] || ecrecover == user) true
// cover: trade :: require(block.number <= expires) true
// cover: trade :: require(orderFills[user][hash].add(amount) <= amountGet) true
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
        // skip malformed call: depositToken(tokenGet, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenGet)
        vm.startPrank(bob);
        // skip malformed call: depositToken(tokenGive, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenGive)
        // skip malformed call: order(tokenGet, 100, tokenGive, 200, 99999999, 1) (bad raw arg for order.arg0: type=address, raw=tokenGet)
        vm.stopPrank();
        vm.startPrank(alice);
        // skip malformed call: trade(tokenGet, 100, tokenGive, 200, 99999999, 1, bob, v, r, s, 50) (bad raw arg for trade.arg0: type=address, raw=tokenGet)
        // skip malformed call: balanceOf(tokenGet, alice) (bad raw arg for balanceOf.arg0: type=address, raw=tokenGet)
        vm.stopPrank();
        vm.prank(bob);
        // skip malformed call: balanceOf(tokenGet, bob) (bad raw arg for balanceOf.arg0: type=address, raw=tokenGet)
        vm.prank(alice);
        // skip malformed call: balanceOf(tokenGive, alice) (bad raw arg for balanceOf.arg0: type=address, raw=tokenGive)
        vm.prank(bob);
        // skip malformed call: balanceOf(tokenGive, bob) (bad raw arg for balanceOf.arg0: type=address, raw=tokenGive)
    }

    // @cover-intent Transactional Consistency: Verify trade reverts when order has expired.
    function test_Trade_with_expired_order_4() public {
// assume: current block.number > 1 (expired)
// assume: v, r, s are valid signature for bob's order
// cover: trade :: require(block.number <= expires) false
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
        // skip malformed call: depositToken(tokenGet, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenGet)
        vm.startPrank(bob);
        // skip malformed call: depositToken(tokenGive, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenGive)
        // skip malformed call: order(tokenGet, 100, tokenGive, 200, 1, 1) (bad raw arg for order.arg0: type=address, raw=tokenGet)
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        // skip malformed call: trade(tokenGet, 100, tokenGive, 200, 1, 1, bob, v, r, s, 50) (bad raw arg for trade.arg0: type=address, raw=tokenGet)
    }

    // @cover-intent Transactional Consistency: Verify trade reverts when taker has insufficient balance.
    function test_Trade_with_insufficient_balance_5() public {
// assume: alice has no tokenGet balance
// assume: v, r, s are valid signature for bob's order
// cover: trade :: tradeBalances: tokens[tokenGet][msg.sender].sub(amount.add(tradingFeeXfer)) underflows
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
        vm.startPrank(bob);
        // skip malformed call: depositToken(tokenGive, 500) (bad raw arg for depositToken.arg0: type=address, raw=tokenGive)
        // skip malformed call: order(tokenGet, 100, tokenGive, 200, 99999999, 1) (bad raw arg for order.arg0: type=address, raw=tokenGet)
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        // skip malformed call: trade(tokenGet, 100, tokenGive, 200, 99999999, 1, bob, v, r, s, 50) (bad raw arg for trade.arg0: type=address, raw=tokenGet)
    }

    // @cover-intent Protocol State Machine: Verify safeGuard pauses critical functions.
    function test_SafeGuard_prevents_withdrawals_and_trades_6() public {
// assume: safeGuard is true after owner toggles it
// cover: withdraw :: require(!safeGuard) false
// cover: trade :: require(!safeGuard) false
// cover: cancelOrder :: require(!safeGuard) false
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
        vm.startPrank(alice);
        vm.expectRevert();
        {
        target.withdraw(1 ether);
        }
        vm.expectRevert();
        // skip malformed call: trade(tokenGet, 100, tokenGive, 200, 99999999, 1, bob, v, r, s, 50) (bad raw arg for trade.arg0: type=address, raw=tokenGet)
        vm.expectRevert();
        // skip malformed call: cancelOrder(tokenGet, 100, tokenGive, 200, 99999999, 1, v, r, s) (bad raw arg for cancelOrder.arg0: type=address, raw=tokenGet)
        vm.stopPrank();
    }

    // @cover-intent state transition test for changeSafeguardStatus
    function test_Owner_only_functions_reject_non_owner_7() public {
// assume: owner is a different address than alice
// cover: changeSafeguardStatus :: require(msg.sender == owner) false
// cover: changeFeeAccount :: require(msg.sender == owner) false
// cover: changetradingFee :: require(msg.sender == owner) false
// cover: onlyOwnerTransferOwnership :: require(msg.sender == owner) false
// cover: withdrawTradingFeeOwner :: require(msg.sender == owner) false
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
        vm.expectRevert();
        // skip ABI-mismatched call: changeSafeguardStatus()
        vm.expectRevert();
        {
        target.changeFeeAccount(alice);
        }
        vm.expectRevert();
        {
        target.changetradingFee(100);
        }
        vm.expectRevert();
        {
        target.onlyOwnerTransferOwnership(alice);
        }
        vm.expectRevert();
        // skip ABI-mismatched call: withdrawTradingFeeOwner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify two-step ownership transfer works correctly.
    function test_Ownership_transfer_flow_8() public {
// assume: owner is the initial owner
// cover: onlyOwnerTransferOwnership :: require(msg.sender == owner) true
// cover: acceptOwnership :: require(msg.sender == newOwner) true
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
        vm.startPrank(owner);
        {
        target.onlyOwnerTransferOwnership(alice);
        }
        // skip ABI-mismatched call: acceptOwnership()
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify owner can withdraw accumulated trading fees.
    function test_Trading_fee_withdrawal_by_owner_9() public {
// assume: feeAccount is initially set to owner
// assume: trading fees have been accumulated in tokens[0][feeAccount]
// cover: withdrawTradingFeeOwner :: require(msg.sender == owner) true
// cover: withdrawTradingFeeOwner :: require(amount > 0) true
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

    // @cover-intent minimal test for bug_intou11
    function test_perfn_bug_intou11_15() public {
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
        // skip ABI-mismatched call: bug_intou11()
    }

    // @cover-intent minimal test for bug_intou12
    function test_perfn_bug_intou12_16() public {
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
        target.bug_intou12(1);
        }
    }

    // @cover-intent minimal test for bug_intou15
    function test_perfn_bug_intou15_17() public {
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
        // skip ABI-mismatched call: bug_intou15()
    }

    // @cover-intent minimal test for bug_intou19
    function test_perfn_bug_intou19_18() public {
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
        // skip ABI-mismatched call: bug_intou19()
    }

    // @cover-intent minimal test for bug_intou20
    function test_perfn_bug_intou20_19() public {
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
        target.bug_intou20(1);
        }
    }

    // @cover-intent minimal test for bug_intou23
    function test_perfn_bug_intou23_20() public {
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
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent minimal test for bug_intou27
    function test_perfn_bug_intou27_21() public {
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
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent minimal test for bug_intou28
    function test_perfn_bug_intou28_22() public {
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
        target.bug_intou28(1);
        }
    }

    // @cover-intent minimal test for bug_intou3
    function test_perfn_bug_intou3_23() public {
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
        // skip ABI-mismatched call: bug_intou3()
    }

    // @cover-intent minimal test for bug_intou31
    function test_perfn_bug_intou31_24() public {
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
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent minimal test for bug_intou32
    function test_perfn_bug_intou32_25() public {
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
        target.bug_intou32(1);
        }
    }

    // @cover-intent minimal test for bug_intou35
    function test_perfn_bug_intou35_26() public {
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
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent minimal test for bug_intou36
    function test_perfn_bug_intou36_27() public {
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent minimal test for bug_intou39
    function test_perfn_bug_intou39_28() public {
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
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent minimal test for bug_intou4
    function test_perfn_bug_intou4_29() public {
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
        target.bug_intou4(1);
        }
    }

    // @cover-intent minimal test for bug_intou40
    function test_perfn_bug_intou40_30() public {
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent minimal test for bug_intou7
    function test_perfn_bug_intou7_31() public {
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
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent minimal test for bug_intou8
    function test_perfn_bug_intou8_32() public {
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent minimal test for cancelOrder
    function test_perfn_cancelOrder_33() public {
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
    function test_perfn_changeFeeAccount_34() public {
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
    function test_perfn_changeSafeguardStatus_35() public {
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
    function test_perfn_changetradingFee_36() public {
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

    // @cover-intent minimal test for deposit
    function test_perfn_deposit_37() public {
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
    function test_perfn_depositToken_38() public {
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
    function test_perfn_feeAccount_39() public {
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

    // @cover-intent minimal test for increaseLockTime_intou1
    function test_perfn_increaseLockTime_intou1_40() public {
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
        target.increaseLockTime_intou1(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou13
    function test_perfn_increaseLockTime_intou13_41() public {
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
        target.increaseLockTime_intou13(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou17
    function test_perfn_increaseLockTime_intou17_42() public {
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
        target.increaseLockTime_intou17(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou21
    function test_perfn_increaseLockTime_intou21_43() public {
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
        target.increaseLockTime_intou21(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou25
    function test_perfn_increaseLockTime_intou25_44() public {
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
        target.increaseLockTime_intou25(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou33
    function test_perfn_increaseLockTime_intou33_45() public {
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
        target.increaseLockTime_intou33(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou37
    function test_perfn_increaseLockTime_intou37_46() public {
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
        target.increaseLockTime_intou37(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou9
    function test_perfn_increaseLockTime_intou9_47() public {
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
        target.increaseLockTime_intou9(1);
        }
    }

    // @cover-intent minimal test for lockTime_intou1
    function test_perfn_lockTime_intou1_48() public {
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
        target.lockTime_intou1(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou13
    function test_perfn_lockTime_intou13_49() public {
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou17
    function test_perfn_lockTime_intou17_50() public {
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
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou21
    function test_perfn_lockTime_intou21_51() public {
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
        target.lockTime_intou21(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou25
    function test_perfn_lockTime_intou25_52() public {
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
        target.lockTime_intou25(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou33
    function test_perfn_lockTime_intou33_53() public {
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou37
    function test_perfn_lockTime_intou37_54() public {
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
        target.lockTime_intou37(alice);
        }
    }

    // @cover-intent minimal test for lockTime_intou9
    function test_perfn_lockTime_intou9_55() public {
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
        target.lockTime_intou9(alice);
        }
    }

    // @cover-intent minimal test for onlyOwnerTransferOwnership
    function test_perfn_onlyOwnerTransferOwnership_56() public {
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
    function test_perfn_order_57() public {
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
    function test_perfn_orderFills_58() public {
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
    function test_perfn_orders_59() public {
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
    function test_perfn_owner_60() public {
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
    function test_perfn_safeGuard_61() public {
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
    function test_perfn_testTrade_62() public {
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
    function test_perfn_tokens_63() public {
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
    function test_perfn_trade_64() public {
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
    function test_perfn_tradingFee_65() public {
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

    // @cover-intent minimal test for transfer_intou10
    function test_perfn_transfer_intou10_66() public {
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
        target.transfer_intou10(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou14
    function test_perfn_transfer_intou14_67() public {
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
        target.transfer_intou14(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou22
    function test_perfn_transfer_intou22_68() public {
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
        target.transfer_intou22(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou26
    function test_perfn_transfer_intou26_69() public {
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
        target.transfer_intou26(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou30
    function test_perfn_transfer_intou30_70() public {
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
        target.transfer_intou30(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou34
    function test_perfn_transfer_intou34_71() public {
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
        target.transfer_intou34(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_intou38
    function test_perfn_transfer_intou38_72() public {
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
        target.transfer_intou38(bob, 100);
        }
    }

    // @cover-intent minimal test for transfer_undrflow2
    function test_perfn_transfer_undrflow2_73() public {
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
        target.transfer_undrflow2(bob, 100);
        }
    }

    // @cover-intent minimal test for withdraw
    function test_perfn_withdraw_74() public {
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

    // @cover-intent minimal test for withdrawToken
    function test_perfn_withdrawToken_75() public {
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
    function test_perfn_withdrawTradingFeeOwner_76() public {
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

    // @cover-intent minimal test for withdraw_intou13
    function test_perfn_withdraw_intou13_77() public {
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
        // skip ABI-mismatched call: withdraw_intou13()
    }

    // @cover-intent minimal test for withdraw_intou17
    function test_perfn_withdraw_intou17_78() public {
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
        // skip ABI-mismatched call: withdraw_intou17()
    }

    // @cover-intent minimal test for withdraw_intou21
    function test_perfn_withdraw_intou21_79() public {
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
        // skip ABI-mismatched call: withdraw_intou21()
    }

    // @cover-intent minimal test for withdraw_intou25
    function test_perfn_withdraw_intou25_80() public {
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
        // skip ABI-mismatched call: withdraw_intou25()
    }

    // @cover-intent minimal test for withdraw_intou33
    function test_perfn_withdraw_intou33_81() public {
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
        // skip ABI-mismatched call: withdraw_intou33()
    }

    // @cover-intent minimal test for withdraw_intou37
    function test_perfn_withdraw_intou37_82() public {
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
        // skip ABI-mismatched call: withdraw_intou37()
    }

    // @cover-intent minimal test for withdraw_intou9
    function test_perfn_withdraw_intou9_83() public {
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
        // skip ABI-mismatched call: withdraw_intou9()
    }

    // @cover-intent minimal test for withdraw_ovrflow1
    function test_perfn_withdraw_ovrflow1_84() public {
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
        // skip ABI-mismatched call: withdraw_ovrflow1()
    }

}
