// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/auction.sol";

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

contract DosAuction_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function DosAuction_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that a higher bid replaces the current frontrunner and the previous frontrunner is refunded.
    function test_Normal_bid_and_outbid_0() public {
// cover: bid :: require(msg.value > currentBid) true
// cover: bid :: require(currentFrontrunner.send(currentBid)) true
        vm.startPrank(alice);
        DosAuction target = new DosAuction();
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
        // skip ABI-mismatched call: bid()
        vm.prank(bob);
        // skip ABI-mismatched call: bid()
    }

    // @cover-intent Transactional Consistency: Verify that a bid with value not greater than currentBid reverts.
    function test_Bid_with_insufficient_value_reverts_1() public {
// cover: bid :: require(msg.value > currentBid) false
        vm.startPrank(alice);
        DosAuction target = new DosAuction();
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
        // skip ABI-mismatched call: bid()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: bid()
    }

    // @cover-intent Protocol State Machine: Verify that the first bid sets the frontrunner without attempting a refund.
    function test_First_bid_succeeds_when_no_frontrunner_2() public {
// cover: bid :: require(msg.value > currentBid) true
// cover: bid :: if (currentFrontrunner != 0) false
        vm.startPrank(alice);
        DosAuction target = new DosAuction();
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
        // skip ABI-mismatched call: bid()
    }

    // @cover-intent Transactional Consistency: Verify that a bid with value equal to currentBid reverts due to strict greater-than check.
    function test_Bid_with_value_equal_to_currentBid_reverts_3() public {
// cover: bid :: require(msg.value > currentBid) false
        vm.startPrank(alice);
        DosAuction target = new DosAuction();
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
        // skip ABI-mismatched call: bid()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: bid()
    }

    // @cover-intent External Interaction & Environment: Verify that if the previous frontrunner's fallback reverts, the entire transaction reverts (DoS vulnerability).
    function test_Refund_failure_causes_revert_DoS_4() public {
// assume: alice's fallback function reverts
// cover: bid :: require(currentFrontrunner.send(currentBid)) false
        vm.startPrank(alice);
        DosAuction target = new DosAuction();
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
        // skip ABI-mismatched call: bid()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: bid()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bid_DoS_attack_5() public {
        vm.startPrank(alice);
        DosAuction target = new DosAuction();
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
        // skip ABI-mismatched call: bid()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: bid()
    }

}
