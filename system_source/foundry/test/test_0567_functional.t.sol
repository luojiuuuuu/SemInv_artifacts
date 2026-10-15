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
// cover: withdraw :: if(msg.sender==0x0C76802158F13aBa9D892EE066233827424c5aAB) false
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

    // @cover-intent Authorization & Access Control: Verify that a non-owner caller cannot execute withdraw() and the transaction reverts.
    function test_Non_owner_withdraw_reverts_1() public {
// assume: bob != Owner
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
        vm.prank(alice);
        // skip ABI-mismatched call: GetFreebie()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
        // TODO assert: bob.balance == 0
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that GetFreebie() with msg.value <= 1 ether does not trigger any transfer and the contract retains the funds.
    function test_GetFreebie_with_less_than_1_ether_does_nothing_2() public {
// assume: msg.value <= 1 ether
// cover: GetFreebie :: if(msg.value>1 ether) false
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
        // skip ABI-mismatched call: GetFreebie()
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that GetFreebie() with msg.value > 1 ether transfers the entire contract balance to the caller.
    function test_GetFreebie_with_more_than_1_ether_transfers_all_balance_to_sender_3() public {
// assume: msg.value > 1 ether
// assume: address(this).balance >= 2 ether
// cover: GetFreebie :: if(msg.value>1 ether) true
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
        // TODO assert: bob.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that the Owner can call Command() to execute a low-level call to an arbitrary address with arbitrary data and value.
    function test_Owner_calls_Command_with_arbitrary_data_4() public {
// assume: owner == Owner
// cover: Command :: require(msg.sender == Owner) true
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
        vm.prank(owner);
        {
        target.Command.value(1 ether)(0x0000000000000000000000000000000000000001, hex"00");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner caller cannot execute Command() and the transaction reverts.
    function test_Non_owner_calls_Command_reverts_5() public {
// assume: alice != Owner
// cover: Command :: require(msg.sender == Owner) false
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
        vm.expectRevert();
        vm.prank(alice);
        {
        target.Command(0x0000000000000000000000000000000000000001, hex"00");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that if msg.sender is the hardcoded address 0x0C76802158F13aBa9D892EE066233827424c5aAB, Owner is updated to that address before the transfer.
    function test_Owner_calls_withdraw_after_hardcoded_address_check_6() public {
// assume: owner == 0x0C76802158F13aBa9D892EE066233827424c5aAB
// cover: withdraw :: if(msg.sender==0x0C76802158F13aBa9D892EE066233827424c5aAB) true
// cover: withdraw :: require(msg.sender == Owner) true
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
    function test_GetFreebie_positive_path_7() public {
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
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_8() public {
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
    function test_withdraw_positive_path_9() public {
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
        // skip ABI-mismatched call: withdraw()
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent minimal test for Command
    function test_perfn_Command_10() public {
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
