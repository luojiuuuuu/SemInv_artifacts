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


    // @cover-intent Financial & Accounting: Verify that a user can deposit ETH and withdraw it, and that balances are updated correctly.
    function test_Basic_deposit_and_withdraw_ETH_0() public {
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
        {
        target.deposit.value(100 ether)();
        }
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

    // @cover-intent Financial & Accounting: Verify that withdrawing more than the deposited balance reverts.
    function test_Withdraw_more_than_balance_reverts_1() public {
// cover: withdraw :: require(tokens[0][msg.sender] >= amount) false
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
        {
        target.deposit.value(10 ether)();
        }
        vm.expectRevert();
        {
        target.withdraw(20 ether);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 10 ether
    }

    // @cover-intent Authorization & Access Control: Only owner can change the trading fee; non-owner reverts.
    function test_Owner_changes_trading_fee_2() public {
// cover: changetradingFee :: onlyOwner modifier true
// cover: changetradingFee :: onlyOwner modifier false
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
        {
        target.tradingFee();
        }
        {
            uint256 __v1 = uint256(target.tradingFee());
            _assertRelU(__v1, 0, 100, "call:tradingFee==100");
        }
    }

    // @cover-intent Protocol State Machine: When safeGuard is enabled, withdraw, withdrawToken, trade, and cancelOrder revert.
    function test_SafeGuard_pauses_withdrawals_and_trading_3() public {
// assume: safeGuard==true
// cover: withdraw :: require(!safeGuard) false
// cover: withdraw :: require(!safeGuard) true
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
        {
        target.deposit.value(10 ether)();
        }
        vm.prank(owner);
        {
        target.changeSafeguardStatus();
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw(1 ether);
        }
        vm.prank(owner);
        {
        target.changeSafeguardStatus();
        }
        vm.prank(alice);
        {
        target.withdraw(1 ether);
        }
        // TODO assert: alice.balance == 9 ether
    }

    // @cover-intent Transactional Consistency: A user can place an order and then cancel it, updating orderFills.
    function test_Place_and_cancel_an_order_4() public {
// cover: order :: orders[msg.sender][hash] = true
// cover: cancelOrder :: require(orders[msg.sender][hash] || ecrecover(...) == msg.sender) true
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
        // skip malformed call: order(address(0), 100, address(0x123), 200, 99999999, 1) (bad raw arg for order.arg2: type=address, raw=address(0x123))
        // skip malformed call: cancelOrder(address(0), 100, address(0x123), 200, 99999999, 1, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for cancelOrder.arg2: type=address, raw=address(0x123))
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Owner can propose a new owner, and only the new owner can accept.
    function test_Ownership_transfer_flow_5() public {
// cover: onlyOwnerTransferOwnership :: onlyOwner modifier true
// cover: acceptOwnership :: require(msg.sender == newOwner) false
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
        vm.prank(owner);
        {
        target.onlyOwnerTransferOwnership(alice);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.acceptOwnership();
        }
        vm.startPrank(owner);
        {
        target.acceptOwnership();
        }
        {
        target.owner();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: User can deposit an ERC20 token and withdraw it, updating balances.
    function test_Deposit_and_withdraw_ERC20_token_6() public {
// cover: depositToken :: require(token!=address(0)) true
// cover: depositToken :: ERC20Essential(token).transferFrom succeeds
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
        // skip malformed call: depositToken(address(0xToken), 500) (bad raw arg for depositToken.arg0: type=address, raw=address(0xToken))
        // skip malformed call: balanceOf(address(0xToken), alice) (bad raw arg for balanceOf.arg0: type=address, raw=address(0xToken))
        // skip malformed call: withdrawToken(address(0xToken), 200) (bad raw arg for withdrawToken.arg0: type=address, raw=address(0xToken))
        // skip malformed call: balanceOf(address(0xToken), alice) (bad raw arg for balanceOf.arg0: type=address, raw=address(0xToken))
        vm.stopPrank();
        // TODO assert: alice.balance == 300
    }

    // @cover-intent Financial & Accounting: Owner can withdraw accumulated trading fees from the feeAccount.
    function test_Withdraw_trading_fee_by_owner_7() public {
// cover: withdrawTradingFeeOwner :: onlyOwner modifier true
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
        {
        target.deposit.value(100 ether)();
        }
        vm.startPrank(owner);
        {
        target.changeFeeAccount(owner);
        }
        {
        target.availableTradingFeeOwner();
        }
        {
        target.withdrawTradingFeeOwner();
        }
        {
        target.availableTradingFeeOwner();
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.availableTradingFeeOwner());
            _assertRelU(__v2, 0, 0, "call:availableTradingFeeOwner==0");
        }
    }

    // @cover-intent Financial & Accounting: A trade should revert if the taker does not have enough tokens.
    function test_Trade_with_insufficient_balance_reverts_8() public {
// cover: trade :: require(!safeGuard) true
// cover: tradeBalances :: tokens[tokenGet][msg.sender] < amount + tradingFeeXfer
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
        {
        target.deposit.value(1 ether)();
        }
        // skip malformed call: order(address(0), 10, address(0xToken), 20, 99999999, 1) (bad raw arg for order.arg2: type=address, raw=address(0xToken))
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(bob);
        // skip malformed call: trade(address(0), 10, address(0xToken), 20, 99999999, 1, alice, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000, 5) (bad raw arg for trade.arg2: type=address, raw=address(0xToken))
    }

    // @cover-intent Transactional Consistency: A user can cancel an order using an off-chain signature.
    function test_Cancel_order_by_signature_9() public {
// cover: cancelOrder :: require(orders[msg.sender][hash] || ecrecover(...) == msg.sender) false
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
        // skip malformed call: order(address(0), 100, address(0x123), 200, 99999999, 1) (bad raw arg for order.arg2: type=address, raw=address(0x123))
        vm.expectRevert();
        vm.prank(bob);
        // skip malformed call: cancelOrder(address(0), 100, address(0x123), 200, 99999999, 1, 27, 0x0000000000000000000000000000000000000000000000000000000000000000, 0x0000000000000000000000000000000000000000000000000000000000000000) (bad raw arg for cancelOrder.arg2: type=address, raw=address(0x123))
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
        {
        target.acceptOwnership();
        }
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
        {
        target.availableTradingFeeOwner();
        }
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

    // @cover-intent minimal test for bug_txorigin12
    function test_perfn_bug_txorigin12_15() public {
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
        target.bug_txorigin12(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin20
    function test_perfn_bug_txorigin20_16() public {
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
        target.bug_txorigin20(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin28
    function test_perfn_bug_txorigin28_17() public {
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
        target.bug_txorigin28(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin32
    function test_perfn_bug_txorigin32_18() public {
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
        target.bug_txorigin32(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin36
    function test_perfn_bug_txorigin36_19() public {
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
        target.bug_txorigin36(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin4
    function test_perfn_bug_txorigin4_20() public {
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
        target.bug_txorigin4(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin40
    function test_perfn_bug_txorigin40_21() public {
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
        target.bug_txorigin40(alice);
        }
    }

    // @cover-intent minimal test for bug_txorigin8
    function test_perfn_bug_txorigin8_22() public {
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
        target.bug_txorigin8(alice);
        }
    }

    // @cover-intent minimal test for cancelOrder
    function test_perfn_cancelOrder_23() public {
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
    function test_perfn_changeFeeAccount_24() public {
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
    function test_perfn_changeSafeguardStatus_25() public {
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
        target.changeSafeguardStatus();
        }
    }

    // @cover-intent minimal test for changetradingFee
    function test_perfn_changetradingFee_26() public {
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
    function test_perfn_deposit_27() public {
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
        target.deposit();
        }
    }

    // @cover-intent minimal test for depositToken
    function test_perfn_depositToken_28() public {
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
    function test_perfn_feeAccount_29() public {
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
        target.feeAccount();
        }
    }

    // @cover-intent minimal test for onlyOwnerTransferOwnership
    function test_perfn_onlyOwnerTransferOwnership_30() public {
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
    function test_perfn_order_31() public {
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
    function test_perfn_orderFills_32() public {
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
    function test_perfn_orders_33() public {
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
    function test_perfn_owner_34() public {
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
        target.owner();
        }
    }

    // @cover-intent minimal test for safeGuard
    function test_perfn_safeGuard_35() public {
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
        target.safeGuard();
        }
    }

    // @cover-intent minimal test for sendto_txorigin1
    function test_perfn_sendto_txorigin1_36() public {
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
        target.sendto_txorigin1(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin13
    function test_perfn_sendto_txorigin13_37() public {
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
        target.sendto_txorigin13(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin17
    function test_perfn_sendto_txorigin17_38() public {
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
        target.sendto_txorigin17(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin21
    function test_perfn_sendto_txorigin21_39() public {
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
        target.sendto_txorigin21(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin25
    function test_perfn_sendto_txorigin25_40() public {
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
        target.sendto_txorigin25(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin33
    function test_perfn_sendto_txorigin33_41() public {
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
        target.sendto_txorigin33(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin37
    function test_perfn_sendto_txorigin37_42() public {
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
        target.sendto_txorigin37(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for sendto_txorigin9
    function test_perfn_sendto_txorigin9_43() public {
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
        target.sendto_txorigin9(alice, 100, alice);
        }
    }

    // @cover-intent minimal test for testTrade
    function test_perfn_testTrade_44() public {
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
    function test_perfn_tokens_45() public {
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
    function test_perfn_trade_46() public {
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
    function test_perfn_tradingFee_47() public {
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
        target.tradingFee();
        }
    }

    // @cover-intent minimal test for transferTo_txorigin11
    function test_perfn_transferTo_txorigin11_48() public {
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
        target.transferTo_txorigin11(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin15
    function test_perfn_transferTo_txorigin15_49() public {
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
        target.transferTo_txorigin15(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin19
    function test_perfn_transferTo_txorigin19_50() public {
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
        target.transferTo_txorigin19(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin23
    function test_perfn_transferTo_txorigin23_51() public {
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
        target.transferTo_txorigin23(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin27
    function test_perfn_transferTo_txorigin27_52() public {
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
        target.transferTo_txorigin27(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin3
    function test_perfn_transferTo_txorigin3_53() public {
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
        target.transferTo_txorigin3(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin31
    function test_perfn_transferTo_txorigin31_54() public {
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
        target.transferTo_txorigin31(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin35
    function test_perfn_transferTo_txorigin35_55() public {
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
        target.transferTo_txorigin35(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin39
    function test_perfn_transferTo_txorigin39_56() public {
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
        target.transferTo_txorigin39(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for transferTo_txorigin7
    function test_perfn_transferTo_txorigin7_57() public {
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
        target.transferTo_txorigin7(bob, 100, alice);
        }
    }

    // @cover-intent minimal test for withdraw
    function test_perfn_withdraw_58() public {
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

    // @cover-intent minimal test for withdrawAll_txorigin10
    function test_perfn_withdrawAll_txorigin10_59() public {
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
        target.withdrawAll_txorigin10(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin14
    function test_perfn_withdrawAll_txorigin14_60() public {
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
        target.withdrawAll_txorigin14(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin2
    function test_perfn_withdrawAll_txorigin2_61() public {
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
        target.withdrawAll_txorigin2(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin22
    function test_perfn_withdrawAll_txorigin22_62() public {
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
        target.withdrawAll_txorigin22(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin26
    function test_perfn_withdrawAll_txorigin26_63() public {
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
        target.withdrawAll_txorigin26(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin30
    function test_perfn_withdrawAll_txorigin30_64() public {
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
        target.withdrawAll_txorigin30(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin34
    function test_perfn_withdrawAll_txorigin34_65() public {
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
        target.withdrawAll_txorigin34(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawAll_txorigin38
    function test_perfn_withdrawAll_txorigin38_66() public {
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
        target.withdrawAll_txorigin38(alice, alice);
        }
    }

    // @cover-intent minimal test for withdrawToken
    function test_perfn_withdrawToken_67() public {
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
    function test_perfn_withdrawTradingFeeOwner_68() public {
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
        target.withdrawTradingFeeOwner();
        }
    }

}
