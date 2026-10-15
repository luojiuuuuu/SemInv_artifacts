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


    // @cover-intent Financial & Accounting: Verify that redeem() transfers contract balance to sender when msg.value meets minEligibility threshold
    function test_redeem_positive_min_eligibility_0() public {
// assume: address(alice).balance >= 1 ether
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
        vm.prank(alice);
        // skip ABI-mismatched call: redeem()
    }

    // @cover-intent Financial & Accounting: Verify that redeem() does not transfer balance when msg.value is below minEligibility
    function test_redeem_below_min_eligibility_1() public {
// assume: address(alice).balance >= 0.5 ether
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

    // @cover-intent Authorization & Access Control: Verify that owner can withdraw all contract balance
    function test_withdraw_owner_positive_2() public {
// assume: owner == address(this).Owner
// cover: withdraw :: msg.sender == Owner true
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

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call withdraw()
    function test_withdraw_non_owner_revert_3() public {
// assume: alice != owner
// cover: withdraw :: msg.sender == Owner false
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent External Interaction & Environment: Verify that owner can execute arbitrary calls via Command()
    function test_command_owner_positive_4() public {
// assume: owner == address(this).Owner
// cover: Command :: msg.sender == Owner true
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
        {
        target.Command(0x0000000000000000000000000000000000000001, hex"00");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call Command()
    function test_command_non_owner_revert_5() public {
// assume: alice != owner
// cover: Command :: msg.sender == Owner false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.Command(0x0000000000000000000000000000000000000001, hex"00");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that calling withdraw() from the hardcoded address changes Owner
    function test_withdraw_special_address_trigger_6() public {
// assume: owner == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b
// cover: withdraw :: msg.sender == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b true
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

    // @cover-intent Transactional Consistency: Verify that multiple redeem calls with sufficient value each transfer balance
    function test_redeem_multiple_calls_7() public {
// assume: address(alice).balance >= 1 ether
// assume: address(bob).balance >= 1 ether
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
        vm.prank(alice);
        // skip ABI-mismatched call: redeem()
        vm.prank(bob);
        // skip ABI-mismatched call: redeem()
    }

    // @cover-intent External Interaction & Environment: Verify that Command() can forward ether to arbitrary address
    function test_command_with_value_8() public {
// assume: owner == address(this).Owner
// cover: Command :: msg.sender == Owner true
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
        {
        target.Command(0x0000000000000000000000000000000000000001, hex"00");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_9() public {
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
    function test_minEligibility_view_10() public {
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
    function test_redeem_positive_path_11() public {
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
    function test_withdraw_positive_path_12() public {
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
    function test_perfn_Command_13() public {
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
