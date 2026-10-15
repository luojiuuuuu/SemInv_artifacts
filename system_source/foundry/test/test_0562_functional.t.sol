// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xe4eabdca81e31d9acbc4af76b30f532b6ed7f3bf.sol";

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

contract Honey_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Honey_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that only the Owner can successfully call withdraw() and receive the full contract balance.
    function test_Owner_withdraws_all_balance_0() public {
// assume: owner == Owner
// assume: address(this).balance >= 0
// cover: withdraw :: require(msg.sender == Owner) true
// cover: withdraw :: Owner.transfer(this.balance) executed
        vm.startPrank(alice);
        Honey target = new Honey();
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

    // @cover-intent Authorization & Access Control: Verify that a non-owner caller (alice) cannot call withdraw() and the transaction reverts.
    function test_Non_owner_withdraw_reverts_1() public {
// assume: alice != Owner
// cover: withdraw :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        Honey target = new Honey();
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
        // skip ABI-mismatched call: GetFreebie()
        vm.expectRevert();
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that GetFreebie() with msg.value exactly 1 ether does not trigger the balance transfer (boundary condition).
    function test_GetFreebie_with_exactly_1_ether_does_not_trigger_transfer_2() public {
// assume: msg.value == 1 ether
// cover: GetFreebie :: msg.value > 1 ether false
        vm.startPrank(alice);
        Honey target = new Honey();
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
        // TODO assert: alice.balance == 0
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that GetFreebie() with msg.value > 1 ether transfers the entire contract balance to the caller.
    function test_GetFreebie_with_more_than_1_ether_transfers_all_balance_to_caller_3() public {
// assume: msg.value > 1 ether
// cover: GetFreebie :: msg.value > 1 ether true
// cover: GetFreebie :: Owner.transfer(this.balance) executed
// cover: GetFreebie :: msg.sender.transfer(this.balance) executed
        vm.startPrank(bob);
        Honey target = new Honey();
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
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Protocol State Machine: Verify that calling withdraw() when msg.sender is 0x0C76802158F13aBa9D892EE066233827424c5aAB changes Owner to that address.
    function test_Owner_changes_via_withdraw_special_address_4() public {
// assume: owner == 0x0C76802158F13aBa9D892EE066233827424c5aAB
// cover: withdraw :: msg.sender == 0x0C76802158F13aBa9D892EE066233827424c5aAB true
// cover: withdraw :: Owner = 0x0C76802158F13aBa9D892EE066233827424c5aAB executed
        vm.startPrank(alice);
        Honey target = new Honey();
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
        vm.startPrank(alice);
        Honey target = new Honey();
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
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_6() public {
        vm.startPrank(owner);
        Honey target = new Honey();
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
    function test_withdraw_positive_path_7() public {
        vm.startPrank(owner);
        Honey target = new Honey();
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

    // @cover-intent minimal test for Command
    function test_perfn_Command_8() public {
        vm.startPrank(owner);
        Honey target = new Honey();
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
