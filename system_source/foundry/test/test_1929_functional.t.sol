// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xf70d589d76eebdd7c12cc5eec99f8f6fa4233b9e.sol";

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


    // @cover-intent Authorization & Access Control: Verify that the owner can successfully withdraw the contract balance.
    function test_Positive_path_Owner_withdraws_balance_0() public {
// assume: owner == Owner
// cover: withdraw :: require(msg.sender == Owner) true
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
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner cannot call withdraw.
    function test_Negative_path_Non_owner_tries_to_withdraw_1() public {
// assume: bob != Owner
// cover: withdraw :: require(msg.sender == Owner) false
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
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdraw();
        }
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending exactly 1 ether does not trigger the transfer (boundary condition).
    function test_GetFreebie_with_exactly_1_ether_2() public {
// cover: GetFreebie :: msg.value > 1 ether false
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
        {
        target.GetFreebie.value(1 ether)();
        }
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending more than 1 ether triggers Owner.transfer and msg.sender.transfer, draining the contract.
    function test_GetFreebie_with_more_than_1_ether_triggers_double_transfer_3() public {
// cover: GetFreebie :: msg.value > 1 ether true
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
        {
        target.GetFreebie.value(2 ether)();
        }
    }

    // @cover-intent External Interaction & Environment: Verify that owner can call Command to send ETH and data to an arbitrary address.
    function test_Command_with_owner_calls_arbitrary_address_4() public {
// assume: owner == Owner
// cover: Command :: require(msg.sender == Owner) true
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
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.prank(owner);
        // skip malformed call: Command(bob, "0x") (bad raw arg for Command.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot call Command.
    function test_Command_with_non_owner_reverts_5() public {
// assume: bob != Owner
// cover: Command :: require(msg.sender == Owner) false
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
        vm.prank(bob);
        // skip malformed call: Command(alice, "0x") (bad raw arg for Command.arg1: type=bytes, raw="0x")
    }

    // @cover-intent Protocol State Machine: Verify that if msg.sender is the special address, Owner is updated before transfer.
    function test_Owner_changes_via_withdraw_special_address_6() public {
// assume: owner == 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b
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
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent Financial & Accounting: Verify that sending 0 ether does not trigger the transfer.
    function test_GetFreebie_with_0_value_7() public {
// cover: GetFreebie :: msg.value > 1 ether false
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
        target.GetFreebie();
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Financial & Accounting
    function test_GetFreebie_positive_8() public {
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
        {
        target.GetFreebie.value(2 ether)();
        }
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_9() public {
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
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
        // TODO assert: owner.balance == 2 ether
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_negative_non_owner_10() public {
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
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_11() public {
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
        target.Owner();
        }
    }

    // @cover-intent minimal test for Command
    function test_perfn_Command_12() public {
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
