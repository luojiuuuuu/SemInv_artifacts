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


    // @cover-intent Authorization & Access Control: Verify that a user with sufficient token balance and allowance can successfully add a listing.
    function test_addListing_success_0() public {
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
    }

    // @cover-intent Authorization & Access Control: Verify that addListing reverts when the seller does not have enough tokens.
    function test_addListing_insufficient_balance_1() public {
// assume: paused==false
// assume: balanceOf(alice) == 50
// assume: allowance(alice, target) >= 100
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

    // @cover-intent Authorization & Access Control: Verify that addListing reverts when the allowance is too small.
    function test_addListing_insufficient_allowance_2() public {
// assume: paused==false
// assume: balanceOf(alice) >= 100
// assume: allowance(alice, target) == 50
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

    // @cover-intent Authorization & Access Control: Verify that the seller can cancel their own listing.
    function test_cancelListing_by_seller_3() public {
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

    // @cover-intent Authorization & Access Control: Verify that the contract owner can cancel any listing.
    function test_cancelListing_by_owner_4() public {
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
        vm.prank(alice);
        {
        target.addListing(100, 10);
        }
        vm.prank(owner);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that an unauthorized user cannot cancel a listing.
    function test_cancelListing_unauthorized_5() public {
// assume: paused==false
// assume: listingsById(916).active == true
// assume: listingsById(916).seller == alice
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
        target.addListing(100, 10);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent Protocol State Machine: Verify that the owner can toggle the paused state.
    function test_setPaused_by_owner_6() public {
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
    function test_setPaused_by_non_owner_7() public {
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

    // @cover-intent Financial & Accounting: Verify that the owner can withdraw funds from the contract.
    function test_withdrawFunds_by_owner_8() public {
// assume: address(target).balance >= 50
// cover: withdrawFunds :: require(msg.sender == owner) true
        vm.startPrank(owner);
        RaffleTokenExchange target = new RaffleTokenExchange();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.withdrawFunds(50);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot withdraw funds.
    function test_withdrawFunds_by_non_owner_9() public {
// cover: withdrawFunds :: require(msg.sender == owner) false
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
        target.withdrawFunds(50);
        }
    }

    // @cover-intent Protocol State Machine: Verify that the owner can destroy the contract.
    function test_kill_by_owner_10() public {
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
        {
        target.kill();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_addListing_11() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.addListing(100, 10);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_cancelListing_12() public {
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.cancelListing(916);
        }
    }

    // @cover-intent state transition test for claimReward_TOD20
    function test_claimReward_TOD20_13() public {
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
        target.setReward_TOD20.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD20(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD26
    function test_claimReward_TOD26_14() public {
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
        target.setReward_TOD26.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD26(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD30
    function test_claimReward_TOD30_15() public {
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
        target.setReward_TOD30.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD30(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD32
    function test_claimReward_TOD32_16() public {
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
        target.setReward_TOD32.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD32(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD36
    function test_claimReward_TOD36_17() public {
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
        target.setReward_TOD36.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD36(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD38
    function test_claimReward_TOD38_18() public {
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
        target.setReward_TOD38.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD38(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD4
    function test_claimReward_TOD4_19() public {
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
        target.setReward_TOD4.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD4(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD40
    function test_claimReward_TOD40_20() public {
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
        target.setReward_TOD40.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD40(5);
        }
    }

    // @cover-intent state transition test for claimReward_TOD8
    function test_claimReward_TOD8_21() public {
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
        target.setReward_TOD8.value(100)();
        }
        vm.prank(alice);
        {
        target.claimReward_TOD8(5);
        }
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD13_22() public {
        vm.startPrank(alice);
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
        vm.startPrank(alice);
        {
        target.play_TOD13(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD13.value(100)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD19_23() public {
        vm.startPrank(alice);
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
        vm.startPrank(alice);
        {
        target.play_TOD19(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD19.value(100)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD27_24() public {
        vm.startPrank(alice);
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
        vm.startPrank(alice);
        {
        target.play_TOD27(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD27.value(100)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD31_25() public {
        vm.startPrank(alice);
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
        vm.startPrank(alice);
        {
        target.play_TOD31(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD31.value(100)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD33_26() public {
        vm.startPrank(alice);
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
        vm.startPrank(alice);
        {
        target.play_TOD33(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD33.value(100)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD35_27() public {
        vm.startPrank(alice);
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
        vm.startPrank(alice);
        {
        target.play_TOD35(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD35.value(100)();
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getReward_TOD39_28() public {
        vm.startPrank(alice);
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
        vm.startPrank(alice);
        {
        target.play_TOD39(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
        {
        target.getReward_TOD39.value(100)();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_kill_29() public {
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
        target.kill();
        }
    }

    // @cover-intent Protocol State Machine
    function test_listingsById_30() public {
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

    // @cover-intent Protocol State Machine
    function test_nextListingId_31() public {
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
        target.nextListingId();
        }
    }

    // @cover-intent Protocol State Machine
    function test_nextPurchaseId_32() public {
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
        target.nextPurchaseId();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_33() public {
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
        target.owner();
        }
    }

    // @cover-intent Protocol State Machine
    function test_paused_34() public {
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
        target.paused();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD13_35() public {
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
        target.play_TOD13(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD19_36() public {
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
        target.play_TOD19(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD27_37() public {
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
        target.play_TOD27(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD31_38() public {
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
        target.play_TOD31(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD33_39() public {
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
        target.play_TOD33(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD35_40() public {
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
        target.play_TOD35(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_TOD39_41() public {
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
        target.play_TOD39(bytes32(uint256(47219736118171679016481614208494153725245902603978864281390662590579859259392)));
        }
    }

    // @cover-intent Protocol State Machine
    function test_purchasesById_42() public {
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

    // @cover-intent External Interaction & Environment
    function test_raffleContract_43() public {
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
        target.raffleContract();
        }
    }

    // @cover-intent state transition test for setPaused
    function test_setPaused_44() public {
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
    function test_setReward_TOD20_45() public {
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
        target.setReward_TOD20.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD26_46() public {
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
        target.setReward_TOD26.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD30_47() public {
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
        target.setReward_TOD30.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD32_48() public {
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
        target.setReward_TOD32.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD36_49() public {
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
        target.setReward_TOD36.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD38_50() public {
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
        target.setReward_TOD38.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD4_51() public {
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
        target.setReward_TOD4.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD40_52() public {
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
        target.setReward_TOD40.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_setReward_TOD8_53() public {
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
        target.setReward_TOD8.value(100)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdrawFunds_54() public {
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
        target.withdrawFunds(0);
        }
    }

}
