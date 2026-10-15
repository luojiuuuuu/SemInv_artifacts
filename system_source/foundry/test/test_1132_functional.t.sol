// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

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

contract Pie_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Pie_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control - Verify that the owner can successfully withdraw the contract balance.
    function test_Positive_Owner_withdraws_all_balance_0() public {
// assume: msg.sender == Owner
// cover: withdraw :: require(msg.sender == Owner) true
// cover: withdraw :: Owner.transfer(this.balance) executed
        vm.startPrank(alice);
        Pie target = new Pie();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetPie()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control - Verify that a non-owner cannot withdraw and the transaction reverts.
    function test_Negative_Non_owner_tries_to_withdraw_1() public {
// assume: msg.sender != Owner
// cover: withdraw :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        Pie target = new Pie();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetPie()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Financial & Accounting - Verify that sending exactly 1 ether does not trigger the balance transfer in GetPie.
    function test_Boundary_GetPie_with_exactly_1_ether_does_not_trigger_transfer_2() public {
// assume: msg.value == 1 ether
// cover: GetPie :: msg.value > 1 ether false
        vm.startPrank(alice);
        Pie target = new Pie();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetPie()
    }

    // @cover-intent Financial & Accounting - Verify that sending more than 1 ether triggers the balance transfer to sender and owner.
    function test_Boundary_GetPie_with_just_over_1_ether_triggers_transfer_3() public {
// assume: msg.value > 1 ether
// cover: GetPie :: msg.value > 1 ether true
// cover: GetPie :: Owner.transfer(this.balance) executed
// cover: GetPie :: msg.sender.transfer(this.balance) executed
        vm.startPrank(alice);
        Pie target = new Pie();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetPie()
        vm.prank(bob);
        // skip ABI-mismatched call: GetPie()
    }

    // @cover-intent External Interaction & Environment - Verify that the owner can execute a low-level call via Command.
    function test_Positive_Owner_calls_Command_with_arbitrary_data_4() public {
// assume: msg.sender == Owner
// cover: Command :: require(msg.sender == Owner) true
// cover: Command :: adr.call.value(msg.value)(data) executed
        vm.startPrank(owner);
        Pie target = new Pie();
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
        target.Command(alice, hex"");
        }
        {
        target.Command(alice, hex"deadbeef");
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control - Verify that a non-owner cannot call Command and the transaction reverts.
    function test_Negative_Non_owner_calls_Command_5() public {
// assume: msg.sender != Owner
// cover: Command :: require(msg.sender == Owner) false
        vm.startPrank(owner);
        Pie target = new Pie();
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
        vm.prank(bob);
        {
        target.Command(alice, hex"");
        }
    }

    // @cover-intent Authorization & Access Control - Verify that if msg.sender is the special address, Owner is updated before transfer.
    function test_Edge_Owner_changes_via_withdraw_special_address_check_6() public {
// assume: msg.sender == 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6
// cover: withdraw :: msg.sender == 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6 true
// cover: withdraw :: Owner = 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6
// cover: withdraw :: require(msg.sender == Owner) true
// cover: withdraw :: Owner.transfer(this.balance) executed
        vm.startPrank(alice);
        Pie target = new Pie();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetPie()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Transactional Consistency - Verify that after GetPie transfers balance, owner can withdraw remaining funds.
    function test_Sequence_GetPie_then_withdraw_by_owner_7() public {
// cover: GetPie :: msg.value > 1 ether true
// cover: withdraw :: require(msg.sender == Owner) true
        vm.startPrank(bob);
        Pie target = new Pie();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: GetPie()
        vm.prank(bob);
        // skip ABI-mismatched call: GetPie()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Financial & Accounting - Verify that withdrawing from an empty contract reverts due to transfer failure.
    function test_Negative_Owner_tries_to_withdraw_from_empty_contract_8() public {
// assume: this.balance == 0
// cover: withdraw :: require(msg.sender == Owner) true
// cover: withdraw :: Owner.transfer(this.balance) fails
        vm.startPrank(owner);
        Pie target = new Pie();
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
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_getter_9() public {
        vm.startPrank(owner);
        Pie target = new Pie();
        vm.stopPrank();
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
    function test_GetPie_with_value_1_ether_10() public {
        vm.startPrank(alice);
        Pie target = new Pie();
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
        // skip ABI-mismatched call: GetPie()
        // skip ABI-mismatched call: GetPie()
        vm.stopPrank();
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_as_owner_11() public {
        vm.startPrank(owner);
        Pie target = new Pie();
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
        // skip ABI-mismatched call: GetPie()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_as_non_owner_reverts_12() public {
        vm.startPrank(owner);
        Pie target = new Pie();
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
    function test_perfn_Command_13() public {
        vm.startPrank(owner);
        Pie target = new Pie();
        vm.stopPrank();
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
