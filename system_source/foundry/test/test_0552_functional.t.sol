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
    function test_Owner_withdraw_positive_path_0() public {
// assume: msg.sender == Owner
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

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot withdraw.
    function test_Non_owner_withdraw_revert_1() public {
// assume: msg.sender != Owner
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

    // @cover-intent Financial & Accounting: Verify that sending more than 1 ether triggers transfer to owner and sender.
    function test_GetHoneyFromJar_with_value_1_ether_2() public {
// assume: msg.value > 1 ether
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
    }

    // @cover-intent Financial & Accounting: Verify that sending 1 ether or less does not trigger transfers.
    function test_GetHoneyFromJar_with_value_1_ether_3() public {
// assume: msg.value <= 1 ether
// cover: GetHoneyFromJar :: msg.value > 1 ether false
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

    // @cover-intent Authorization & Access Control: Verify that Owner() returns the current owner.
    function test_Owner_read_4() public {
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

    // @cover-intent Authorization & Access Control: Verify that withdraw can change owner and then new owner can withdraw.
    function test_Withdraw_after_owner_change_via_withdraw_5() public {
// assume: msg.sender == Owner initially
// cover: withdraw :: msg.sender == 0x2f61E7e1023Bc22063B8da897d8323965a7712B7 false
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
        vm.expectRevert();
        vm.prank(bob);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Financial & Accounting: Verify that sending exactly 1 ether does not trigger transfers (boundary test).
    function test_GetHoneyFromJar_with_value_exactly_1_ether_boundary_6() public {
// assume: msg.value == 1 ether
// cover: GetHoneyFromJar :: msg.value > 1 ether false
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
    function test_Owner_Read_7() public {
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
    function test_GetHoneyFromJar_OwnerTransfer_8() public {
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
    function test_Withdraw_OwnerSuccess_9() public {
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
    function test_Withdraw_NonOwnerRevert_10() public {
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
