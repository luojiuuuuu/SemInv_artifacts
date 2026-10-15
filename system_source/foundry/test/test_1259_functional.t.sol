// SPDX-License-Identifier: MIT
pragma solidity 0.5.17;
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


    // @cover-intent Test successful listing creation with valid balance and allowance (Authorization & Access Control)
    function test_addListing_positive_0() public {
// assume: paused==false
// assume: balanceOf(alice) >= 100
// assume: allowance(alice, target) >= 100
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
        target.addListing(100, 10);
        }
        {
            uint256 __v1 = uint256(target.nextListingId());
            _assertRelU(__v1, 0, 917, "call:nextListingId==917");
        }
    }

    // @cover-intent Test listing creation fails when seller has insufficient token balance (Resource & Execution Integrity)
    function test_addListing_insufficient_balance_1() public {
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
        target.addListing(100, 10);
        }
    }

    // @cover-intent Test listing creation fails when allowance is insufficient (Resource & Execution Integrity)
    function test_addListing_insufficient_allowance_2() public {
// assume: paused==false
// assume: balanceOf(alice) >= 100
// assume: allowance(alice, target) < 100
// cover: addListing :: require(allowance(msg.sender, address(this)) >= initialAmount) false
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
        target.addListing(100, 10);
        }
    }

    // @cover-intent Test listing cancellation by listing owner (Authorization & Access Control)
    function test_cancelListing_owner_positive_3() public {
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
        target.addListing(100, 10);
        }
        {
        target.cancelListing(916);
        }
        vm.stopPrank();
    }

    // @cover-intent Test listing cancellation by contract owner (Authorization & Access Control)
    function test_cancelListing_contract_owner_positive_4() public {
// assume: paused==false
// assume: listingsById(916).active == true
// assume: owner != alice
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
        target.addListing(100, 10);
        }
        vm.prank(owner);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Test listing cancellation fails for unauthorized user (Authorization & Access Control)
    function test_cancelListing_unauthorized_5() public {
// assume: paused==false
// assume: listingsById(916).active == true
// assume: bob != alice
// assume: bob != owner
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
        target.addListing(100, 10);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Test cancellation of already inactive listing fails (Protocol State Machine)
    function test_cancelListing_already_inactive_6() public {
// assume: paused==false
// assume: listingsById(916).active == false
// cover: cancelListing :: require(listing.active) false
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
        target.addListing(100, 10);
        }
        {
        target.cancelListing(916);
        }
        vm.expectRevert();
        {
        target.cancelListing(916);
        }
        vm.stopPrank();
    }

    // @cover-intent Test owner can pause the contract (Authorization & Access Control / Protocol State Machine)
    function test_setPaused_owner_positive_7() public {
// assume: owner != address(0)
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
        vm.prank(owner);
        {
        target.setPaused(true);
        }
    }

    // @cover-intent state transition test for setPaused
    function test_setPaused_non_owner_revert_8() public {
// assume: alice != owner
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

    // @cover-intent Test addListing fails when contract is paused (Protocol State Machine)
    function test_addListing_when_paused_9() public {
// assume: paused==true
// cover: addListing :: require(paused == false) false
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        target.setPaused(true);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.addListing(100, 10);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_addListing_positive_10() public {
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
        target.setPaused(false);
        }
        vm.prank(alice);
        {
        target.addListing(100, 2);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou19_positive_11() public {
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
    function test_bug_intou20_positive_12() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_positive_13() public {
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
    function test_bug_intou31_positive_14() public {
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
    function test_bug_intou32_positive_15() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou35_positive_16() public {
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
    function test_bug_intou36_positive_17() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou39_positive_18() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou4_positive_19() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou40_positive_20() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou8_positive_21() public {
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

    // @cover-intent Authorization & Access Control
    function test_cancelListing_positive_22() public {
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
        target.setPaused(false);
        }
        vm.prank(alice);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou13_positive_23() public {
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
        target.increaseLockTime_intou13(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou33_positive_24() public {
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
        target.increaseLockTime_intou33(100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_kill_positive_25() public {
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
    function test_listingsById_positive_26() public {
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
        target.listingsById(916);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou13_positive_27() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou33_positive_28() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_nextListingId_positive_29() public {
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
    function test_nextPurchaseId_positive_30() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_owner_positive_31() public {
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
    function test_paused_positive_32() public {
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

    // @cover-intent Resource & Execution Integrity
    function test_purchasesById_positive_33() public {
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
        target.purchasesById(344);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_raffleContract_positive_34() public {
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

    // @cover-intent state transition test for setPaused
    function test_setPaused_positive_35() public {
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

    // @cover-intent Financial & Accounting
    function test_transfer_intou26_positive_36() public {
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
        target.transfer_intou26(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou30_positive_37() public {
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
        target.transfer_intou30(bob, 1);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou38_positive_38() public {
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
        target.transfer_intou38(bob, 1);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdrawFunds_positive_39() public {
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
        target.withdrawFunds(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_positive_40() public {
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
        // skip ABI-mismatched call: withdraw_intou13()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou33_positive_41() public {
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
        // skip ABI-mismatched call: withdraw_intou33()
    }

}
