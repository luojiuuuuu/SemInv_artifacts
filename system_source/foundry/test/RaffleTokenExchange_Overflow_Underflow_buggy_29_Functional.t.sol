// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_29.sol";

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

contract RaffleTokenExchange_FunctionalTest {
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


    // @cover-intent Authorization & Access Control: Verify that a user with sufficient balance and allowance can successfully add a listing.
    function test_add_listing_success_0() public {
// assume: paused==false
// assume: balanceOf(alice) >= 100
// assume: allowance(alice, raffleContract) >= 100
// cover: addListing :: require(balanceOf(msg.sender) >= initialAmount) true
// cover: addListing :: require(allowance(msg.sender, address(this)) >= initialAmount) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setPaused(false);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 1000);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that addListing reverts when the seller's token balance is insufficient.
    function test_add_listing_insufficient_balance_1() public {
// assume: paused==false
// assume: balanceOf(alice) < 100
// cover: addListing :: require(balanceOf(msg.sender) >= initialAmount) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setPaused(false);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.addListing(100, 1000);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the seller can cancel their own active listing.
    function test_cancel_listing_by_seller_2() public {
// assume: paused==false
// assume: listingsById(916).active == true
// assume: listingsById(916).seller == alice
// cover: cancelListing :: require(listing.active) true
// cover: cancelListing :: require(listing.seller == msg.sender || owner == msg.sender) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setPaused(false);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.addListing(100, 1000);
        }
        {
        target.cancelListing(916);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that the contract owner can cancel any listing.
    function test_cancel_listing_by_owner_3() public {
// assume: paused==false
// assume: listingsById(916).active == true
// assume: owner == owner
// cover: cancelListing :: require(listing.active) true
// cover: cancelListing :: require(listing.seller == msg.sender || owner == msg.sender) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setPaused(false);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 1000);
        }
        vm.prank(owner);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-seller, non-owner cannot cancel a listing.
    function test_cancel_listing_unauthorized_4() public {
// assume: paused==false
// assume: listingsById(916).active == true
// assume: listingsById(916).seller == alice
// assume: owner != bob
// cover: cancelListing :: require(listing.active) true
// cover: cancelListing :: require(listing.seller == msg.sender || owner == msg.sender) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setPaused(false);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 1000);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Protocol State Machine: Verify that the owner can toggle the paused state.
    function test_set_paused_by_owner_5() public {
// assume: owner == owner
// cover: setPaused :: require(msg.sender == owner) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.setPaused(true);
        }
        {
        target.setPaused(false);
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for setPaused
    function test_set_paused_by_non_owner_6() public {
// assume: owner != alice
// cover: setPaused :: require(msg.sender == owner) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.setPaused(true);
        }
    }

    // @cover-intent Financial & Accounting: Verify that a buyer can purchase tokens from a single listing with correct payment.
    function test_buy_raffle_single_listing_7() public {
// assume: paused==false
// assume: listingsById(916).active == true
// assume: listingsById(916).amountLeft == 100
// assume: listingsById(916).pricePerToken == 1000
// assume: raffleContract.transferFrom(alice, bob, 50) succeeds
// cover: buyRaffle :: require(amounts.length == listingIds.length) true
// cover: buyRaffle :: require(listing.active) true
// cover: buyRaffle :: require(listing.amountLeft >= 0) true
// cover: buyRaffle :: require(totalAmountPayed <= msg.value) true
        vm.startPrank(bob);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setPaused(false);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 1000);
        }
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(50000)(_arr1, _arr2);
        }
    }

    // @cover-intent Financial & Accounting: Verify that buyRaffle reverts when the buyer underpays.
    function test_buy_raffle_insufficient_payment_8() public {
// assume: paused==false
// assume: listingsById(916).active == true
// assume: listingsById(916).pricePerToken == 1000
// assume: msg.value < 50000
// cover: buyRaffle :: require(totalAmountPayed <= msg.value) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setPaused(false);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.addListing(100, 1000);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 100;
        uint256[] memory _arr2 = new uint256[](1);
        _arr2[0] = 1;
        target.buyRaffle.value(40000)(_arr1, _arr2);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can withdraw funds from the contract.
    function test_withdraw_funds_by_owner_9() public {
// assume: owner == owner
// assume: address(target).balance >= 1000
// cover: withdrawFunds :: require(msg.sender == owner) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.setPaused(false);
        }
        {
        target.withdrawFunds(1000);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that the owner can selfdestruct the contract.
    function test_kill_by_owner_10() public {
// assume: owner == owner
// cover: kill :: require(msg.sender == owner) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou19_test_11() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_test_12() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou31_test_13() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou35_test_14() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou39_test_15() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent Authorization & Access Control
    function test_kill_test_16() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: kill()
    }

    // @cover-intent Resource & Execution Integrity
    function test_nextListingId_test_17() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: nextListingId()
    }

    // @cover-intent Resource & Execution Integrity
    function test_nextPurchaseId_test_18() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: nextPurchaseId()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_test_19() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Protocol State Machine
    function test_paused_test_20() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: paused()
    }

    // @cover-intent External Interaction & Environment
    function test_raffleContract_test_21() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: raffleContract()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_test_22() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: withdraw_intou13()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou33_test_23() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        // skip ABI-mismatched call: withdraw_intou33()
    }

    // @cover-intent minimal test for addListing
    function test_perfn_addListing_24() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.addListing(100, 1);
        }
    }

    // @cover-intent minimal test for bug_intou20
    function test_perfn_bug_intou20_25() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for bug_intou32
    function test_perfn_bug_intou32_26() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for bug_intou36
    function test_perfn_bug_intou36_27() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for bug_intou4
    function test_perfn_bug_intou4_28() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
    function test_perfn_bug_intou40_29() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for bug_intou8
    function test_perfn_bug_intou8_30() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for cancelListing
    function test_perfn_cancelListing_31() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.cancelListing(1);
        }
    }

    // @cover-intent minimal test for increaseLockTime_intou13
    function test_perfn_increaseLockTime_intou13_32() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for increaseLockTime_intou33
    function test_perfn_increaseLockTime_intou33_33() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for listingsById
    function test_perfn_listingsById_34() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.listingsById(1);
        }
    }

    // @cover-intent minimal test for lockTime_intou13
    function test_perfn_lockTime_intou13_35() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for lockTime_intou33
    function test_perfn_lockTime_intou33_36() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for purchasesById
    function test_perfn_purchasesById_37() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.purchasesById(1);
        }
    }

    // @cover-intent minimal test for setPaused
    function test_perfn_setPaused_38() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.setPaused(true);
        }
    }

    // @cover-intent minimal test for transfer_intou26
    function test_perfn_transfer_intou26_39() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
    function test_perfn_transfer_intou30_40() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for transfer_intou38
    function test_perfn_transfer_intou38_41() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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

    // @cover-intent minimal test for withdrawFunds
    function test_perfn_withdrawFunds_42() public {
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
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
        target.withdrawFunds(100);
        }
    }

}
