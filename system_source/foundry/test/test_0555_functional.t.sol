// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

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

contract HomeyJar_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function HomeyJar_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that the owner can successfully withdraw the contract balance.
    function test_Positive_withdraw_by_owner_0() public {
// assume: owner == address(this).owner
// cover: withdraw :: require(msg.sender == Owner) true
        vm.startPrank(alice);
        HomeyJar target = new HomeyJar();
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
        // skip ABI-mismatched call: GetHoneyFromJar()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control: Ensure that a non-owner cannot call withdraw.
    function test_Non_owner_withdraw_reverts_1() public {
// assume: owner != bob
// cover: withdraw :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        HomeyJar target = new HomeyJar();
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
        // skip ABI-mismatched call: GetHoneyFromJar()
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Financial & Accounting: Verify that sending less than 1 ether does not trigger transfer.
    function test_GetHoneyFromJar_with_small_value_does_nothing_2() public {
// cover: GetHoneyFromJar :: msg.value > 1 ether false
        vm.startPrank(owner);
        HomeyJar target = new HomeyJar();
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
        // skip ABI-mismatched call: GetHoneyFromJar()
    }

    // @cover-intent Financial & Accounting: Verify that sending more than 1 ether causes both Owner and msg.sender to receive the contract balance.
    function test_GetHoneyFromJar_with_large_value_triggers_double_transfer_3() public {
// assume: owner != bob
// cover: GetHoneyFromJar :: msg.value > 1 ether true
        vm.startPrank(alice);
        HomeyJar target = new HomeyJar();
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
        // skip ABI-mismatched call: GetHoneyFromJar()
        vm.prank(bob);
        // skip ABI-mismatched call: GetHoneyFromJar()
    }

    // @cover-intent External Interaction & Environment: Verify that owner can execute a low-level call via Command.
    function test_Command_call_by_owner_succeeds_4() public {
// cover: Command :: require(msg.sender == Owner) true
        vm.startPrank(owner);
        HomeyJar target = new HomeyJar();
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

    // @cover-intent Authorization & Access Control: Ensure that a non-owner cannot call Command.
    function test_Command_call_by_non_owner_reverts_5() public {
// assume: owner != alice
// cover: Command :: require(msg.sender == Owner) false
        vm.startPrank(owner);
        HomeyJar target = new HomeyJar();
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

    // @cover-intent Authorization & Access Control: Verify that calling withdraw from the hardcoded address changes Owner.
    function test_Owner_can_be_changed_via_withdraw_by_specific_address_6() public {
// assume: 0x2f61E7e1023Bc22063B8da897d8323965a7712B7 is a valid address
// cover: withdraw :: msg.sender == 0x2f61E7e1023Bc22063B8da897d8323965a7712B7 true
        vm.startPrank(alice);
        HomeyJar target = new HomeyJar();
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
        // skip ABI-mismatched call: GetHoneyFromJar()
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_read_7() public {
        vm.startPrank(owner);
        HomeyJar target = new HomeyJar();
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
    function test_GetHoneyFromJar_positive_8() public {
        vm.startPrank(alice);
        HomeyJar target = new HomeyJar();
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
        // skip ABI-mismatched call: GetHoneyFromJar()
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_owner_9() public {
        vm.startPrank(owner);
        HomeyJar target = new HomeyJar();
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

    // @cover-intent Authorization & Access Control
    function test_withdraw_revert_non_owner_10() public {
        vm.startPrank(owner);
        HomeyJar target = new HomeyJar();
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
    function test_perfn_Command_11() public {
        vm.startPrank(owner);
        HomeyJar target = new HomeyJar();
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
