// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0xd2018bfaa266a9ec0a1a84b061640faa009def76.sol";

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


    // @cover-intent Financial & Accounting: Verify that Get() sends the contract balance to the sender when msg.value > 1 ether, and also sends the balance to Owner.
    function test_Get_positive_path_0() public {
// assume: address(this).balance >= 2 ether
// cover: Get :: msg.value > 1 ether true
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
        {
        target.Get.value(2 ether)();
        }
        {
        target.Get.value(2 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 2 ether
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that Get() does not transfer balance when msg.value <= 1 ether.
    function test_Get_edge_no_transfer_1() public {
// cover: Get :: msg.value > 1 ether false
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
        {
        target.Get.value(0.5 ether)();
        }
        // TODO assert: alice.balance == 0.5 ether
        // TODO assert: owner.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() sends contract balance to Owner when called by Owner.
    function test_withdraw_owner_positive_2() public {
// assume: address(this).balance >= 5 ether
// cover: withdraw :: msg.sender == Owner true
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
        vm.prank(owner);
        {
        target.withdraw();
        }
        // TODO assert: owner.balance == 5 ether
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() reverts when called by non-Owner.
    function test_withdraw_non_owner_revert_3() public {
// cover: withdraw :: msg.sender == Owner false
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
        {
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that withdraw() can change Owner to a hardcoded address and then transfer balance to new Owner.
    function test_withdraw_owner_change_positive_4() public {
// assume: address(this).balance >= 3 ether
// cover: withdraw :: msg.sender == 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6 true
// cover: withdraw :: msg.sender == Owner true
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
        vm.prank(owner);
        {
        target.withdraw();
        }
        // TODO assert: owner.balance == 3 ether
    }

    // @cover-intent External Interaction & Environment: Verify that Command() allows Owner to make a low-level call with value.
    function test_Command_owner_positive_5() public {
// cover: Command :: msg.sender == Owner true
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
        vm.prank(owner);
        {
        target.Command.value(1 ether)(alice, hex"");
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Authorization & Access Control: Verify that Command() reverts when called by non-Owner.
    function test_Command_non_owner_revert_6() public {
// cover: Command :: msg.sender == Owner false
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
        {
        target.Command(owner, hex"");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that Owner() returns the current owner address.
    function test_Owner_view_7() public {
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
        target.Owner();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_view_8() public {
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
        target.Owner();
        }
    }

    // @cover-intent Financial & Accounting
    function test_Get_positive_path_9() public {
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
        {
        target.Get.value(2 ether)();
        }
        {
        target.Get.value(2 ether)();
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 100 + 2 ether - 2 ether
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_path_10() public {
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
        target.withdraw();
        }
        {
        target.withdraw();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_negative_path_11() public {
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
        {
        target.withdraw();
        }
    }

    // @cover-intent minimal test for Command
    function test_perfn_Command_12() public {
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
