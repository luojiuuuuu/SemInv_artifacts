// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xe82f0742a71a02b9e9ffc142fdcb6eb1ed06fb87.sol";

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

contract Freebie_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Freebie_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that only the Owner can successfully withdraw the contract balance.
    function test_Owner_withdraws_balance_0() public {
// assume: owner == Owner
// cover: withdraw :: require(msg.sender == Owner) true
        vm.startPrank(alice);
        Freebie target = new Freebie();
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
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner caller is reverted when calling withdraw.
    function test_Non_owner_cannot_withdraw_1() public {
// assume: owner != bob
// cover: withdraw :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        Freebie target = new Freebie();
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
        vm.expectRevert();
        vm.prank(bob);
        {
        target.withdraw();
        }
        // TODO assert: owner.balance == 0
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending less than 1 ether to GetFreebie does not trigger any transfer.
    function test_GetFreebie_with_less_than_1_ether_does_not_transfer_2() public {
// cover: GetFreebie :: msg.value > 1 ether false
        vm.startPrank(alice);
        Freebie target = new Freebie();
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
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify that sending exactly 1 ether to GetFreebie does not trigger any transfer (boundary condition).
    function test_GetFreebie_with_exactly_1_ether_does_not_transfer_3() public {
// cover: GetFreebie :: msg.value > 1 ether false
        vm.startPrank(alice);
        Freebie target = new Freebie();
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

    // @cover-intent Financial & Accounting: Verify that sending more than 1 ether to GetFreebie transfers the entire contract balance to the caller.
    function test_GetFreebie_with_more_than_1_ether_transfers_balance_to_caller_4() public {
// cover: GetFreebie :: msg.value > 1 ether true
        vm.startPrank(bob);
        Freebie target = new Freebie();
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
        {
        target.GetFreebie.value(2 ether)();
        }
        vm.prank(alice);
        {
        target.GetFreebie.value(2 ether)();
        }
        // TODO assert: bob.balance == 0
    }

    // @cover-intent External Interaction & Environment: Verify that the Owner can call Command to execute arbitrary low-level calls.
    function test_Owner_calls_Command_with_arbitrary_data_5() public {
// assume: owner == Owner
// cover: Command :: require(msg.sender == Owner) true
        vm.startPrank(owner);
        Freebie target = new Freebie();
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
        target.Command(alice, hex"");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that a non-owner caller is reverted when calling Command.
    function test_Non_owner_cannot_call_Command_6() public {
// assume: owner != bob
// cover: Command :: require(msg.sender == Owner) false
        vm.startPrank(owner);
        Freebie target = new Freebie();
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

    // @cover-intent Authorization & Access Control: Verify that Owner can withdraw the accumulated balance after multiple GetFreebie calls.
    function test_Owner_can_withdraw_after_GetFreebie_accumulation_7() public {
// assume: owner == Owner
// cover: withdraw :: require(msg.sender == Owner) true
        vm.startPrank(alice);
        Freebie target = new Freebie();
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
        vm.prank(bob);
        {
        target.GetFreebie.value(0.3 ether)();
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent Financial & Accounting
    function test_GetFreebie_positive_path_8() public {
        vm.startPrank(alice);
        Freebie target = new Freebie();
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
        // TODO assert: alice.balance == initial_balance(alice) - 2 ether + contract_balance_before
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_9() public {
        vm.startPrank(owner);
        Freebie target = new Freebie();
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

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_path_10() public {
        vm.startPrank(owner);
        Freebie target = new Freebie();
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
    }

    // @cover-intent minimal test for Command
    function test_perfn_Command_11() public {
        vm.startPrank(owner);
        Freebie target = new Freebie();
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
