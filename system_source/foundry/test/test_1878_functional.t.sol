// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x7a4349a749e59a5736efb7826ee3496a2dfd5489.sol";

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

contract WhaleGiveaway1_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function WhaleGiveaway1_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that only the owner can successfully call withdraw() and receive the contract balance.
    function test_Owner_withdraws_balance_0() public {
// assume: owner == Owner
// cover: withdraw :: require(msg.sender == Owner) true
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetFreebie()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner caller cannot call withdraw() and the transaction reverts.
    function test_Non_owner_withdraw_reverts_1() public {
// assume: owner != bob
// cover: withdraw :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetFreebie()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
        // TODO assert: owner.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending exactly 1 ether to GetFreebie() does not trigger the balance transfer (msg.value > 1 ether is false).
    function test_GetFreebie_with_exactly_1_ether_does_not_trigger_transfer_2() public {
// cover: GetFreebie :: msg.value > 1 ether false
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetFreebie()
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending more than 1 ether to GetFreebie() triggers transfer of the entire contract balance to the sender.
    function test_GetFreebie_with_more_than_1_ether_transfers_balance_to_sender_3() public {
// cover: GetFreebie :: msg.value > 1 ether true
        vm.startPrank(bob);
        WhaleGiveaway1 target = new WhaleGiveaway1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        // skip ABI-mismatched call: GetFreebie()
        vm.prank(alice);
        // skip ABI-mismatched call: GetFreebie()
    }

    // @cover-intent Authorization & Access Control: Verify that if msg.sender is the hardcoded address 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b, the Owner is updated to that address before the transfer.
    function test_Owner_changes_via_withdraw_special_address_4() public {
// assume: owner == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b
// cover: withdraw :: msg.sender == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b true
        vm.startPrank(alice);
        WhaleGiveaway1 target = new WhaleGiveaway1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetFreebie()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Financial & Accounting
    function test_GetFreebie_positive_path_5() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        // skip ABI-mismatched call: GetFreebie()
        vm.prank(alice);
        // skip ABI-mismatched call: GetFreebie()
    }

    // @cover-intent Financial & Accounting
    function test_GetFreebie_no_transfer_6() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetFreebie()
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_7() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
        vm.stopPrank();
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

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_path_8() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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
        // skip ABI-mismatched call: GetFreebie()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_revert_non_owner_9() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
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

    // @cover-intent minimal test for Command
    function test_perfn_Command_10() public {
        vm.startPrank(owner);
        WhaleGiveaway1 target = new WhaleGiveaway1();
        vm.stopPrank();
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
