// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xdb1c55f6926e7d847ddf8678905ad871a68199d2.sol";

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

contract FreeEth_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function FreeEth_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that GetFreebie transfers the entire contract balance to the sender when msg.value > 1 ether, and that the Owner also receives the balance (due to the double transfer).
    function test_GetFreebie_positive_boundary_0() public {
// assume: address(this).balance >= 2 ether
// cover: GetFreebie :: msg.value > 1 ether true
        vm.startPrank(alice);
        FreeEth target = new FreeEth();
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
        target.GetFreebie.value(2 ether)();
        }
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
    }

    // @cover-intent Financial & Accounting: Verify that GetFreebie does nothing when msg.value <= 1 ether.
    function test_GetFreebie_negative_boundary_1() public {
// cover: GetFreebie :: msg.value > 1 ether false
        vm.startPrank(alice);
        FreeEth target = new FreeEth();
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
        target.GetFreebie.value(0.5 ether)();
        }
        // TODO assert: alice.balance == 0.5 ether
    }

    // @cover-intent Authorization & Access Control: Verify that the owner can withdraw the entire contract balance.
    function test_withdraw_owner_positive_2() public {
// assume: owner == Owner
// cover: withdraw :: msg.sender == Owner true
        vm.startPrank(alice);
        FreeEth target = new FreeEth();
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
        target.GetFreebie.value(2 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner (alice) cannot call withdraw.
    function test_withdraw_nonowner_revert_3() public {
// assume: alice != Owner
// cover: withdraw :: msg.sender == Owner false
        vm.startPrank(owner);
        FreeEth target = new FreeEth();
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
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that if msg.sender is the hardcoded address 0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af, the Owner is set to that address, then the require passes and the balance is transferred.
    function test_withdraw_special_address_ownership_change_4() public {
// assume: carol == 0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af
// cover: withdraw :: msg.sender == 0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af true
        vm.startPrank(alice);
        FreeEth target = new FreeEth();
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
        target.GetFreebie.value(2 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent External Interaction & Environment: Verify that the owner can call Command to send ETH to an arbitrary address with arbitrary data.
    function test_Command_owner_positive_5() public {
// assume: owner == Owner
// cover: Command :: msg.sender == Owner true
        vm.startPrank(alice);
        FreeEth target = new FreeEth();
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
        target.GetFreebie.value(2 ether)();
        }
        vm.prank(owner);
        // skip malformed call: Command(bob, "0x") (bad raw arg for Command.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call Command.
    function test_Command_nonowner_revert_6() public {
// assume: alice != Owner
// cover: Command :: msg.sender == Owner false
        vm.startPrank(owner);
        FreeEth target = new FreeEth();
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
        // skip malformed call: Command(bob, "0x") (bad raw arg for Command.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Financial & Accounting
    function test_GetFreebie_positive_7() public {
        vm.startPrank(alice);
        FreeEth target = new FreeEth();
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
        target.GetFreebie.value(2 ether)();
        }
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == initial_balance_alice + this.balance_before - 2 ether
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_owner_8() public {
        vm.startPrank(owner);
        FreeEth target = new FreeEth();
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
        target.GetFreebie.value(2 ether)();
        }
        {
        target.withdraw();
        }
        vm.stopPrank();
        // TODO assert: address(target).balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_revert_non_owner_9() public {
        vm.startPrank(owner);
        FreeEth target = new FreeEth();
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
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_10() public {
        vm.startPrank(owner);
        FreeEth target = new FreeEth();
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
        target.Owner();
        }
    }

    // @cover-intent minimal test for Command
    function test_perfn_Command_11() public {
        vm.startPrank(owner);
        FreeEth target = new FreeEth();
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
