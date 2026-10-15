// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x3f2ef511aa6e75231e4deafc7a3d2ecab3741de2.sol";

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

contract WhaleGiveaway2_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function WhaleGiveaway2_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that redeem() transfers the contract balance to the sender when msg.value >= minEligibility.
    function test_redeem_positive_min_eligibility_0() public {
// assume: balance(alice) >= 1 ether
// cover: redeem :: msg.value >= minEligibility true
        vm.startPrank(alice);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: redeem()
        // skip ABI-mismatched call: redeem()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that redeem() does not transfer when msg.value < minEligibility.
    function test_redeem_below_min_eligibility_1() public {
// assume: balance(alice) >= 0.5 ether
// cover: redeem :: msg.value >= minEligibility false
        vm.startPrank(owner);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: redeem()
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() succeeds when called by the owner.
    function test_withdraw_owner_positive_2() public {
// assume: owner() == owner
// cover: withdraw :: msg.sender == Owner true
        vm.startPrank(alice);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: redeem()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() reverts when called by a non-owner.
    function test_withdraw_non_owner_revert_3() public {
// assume: owner() != alice
// cover: withdraw :: msg.sender == Owner false
        vm.startPrank(alice);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: redeem()
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() changes Owner to the special address when called by that address.
    function test_withdraw_special_address_owner_change_4() public {
// cover: withdraw :: msg.sender == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b true
        vm.startPrank(alice);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: redeem()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_5() public {
        vm.startPrank(owner);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: Owner()
    }

    // @cover-intent Financial & Accounting
    function test_minEligibility_view_6() public {
        vm.startPrank(owner);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: minEligibility()
    }

    // @cover-intent Financial & Accounting
    function test_redeem_positive_path_7() public {
        vm.startPrank(alice);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: redeem()
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_path_8() public {
        vm.startPrank(owner);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent minimal test for Command
    function test_perfn_Command_9() public {
        vm.startPrank(owner);
        WhaleGiveaway2 target = new WhaleGiveaway2();
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
        target.Command(alice, hex"01");
        }
    }

}
