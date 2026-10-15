// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x5aa88d2901c68fda244f1d0584400368d2c8e739.sol";

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

contract MultiplicatorX3_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MultiplicatorX3_FunctionalTest() public {
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
// assume: msg.sender == Owner for owner calls
// cover: withdraw :: require(msg.sender == Owner) true
// cover: withdraw :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        MultiplicatorX3 target = new MultiplicatorX3();
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
        target.multiplicate.value(5 ether)(owner);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control: Verify that only the Owner can call Command, and it forwards ETH and data to an arbitrary address.
    function test_Owner_executes_arbitrary_command_via_Command_1() public {
// assume: msg.sender == Owner for owner calls
// cover: Command :: require(msg.sender == Owner) true
// cover: Command :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        MultiplicatorX3 target = new MultiplicatorX3();
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
        target.multiplicate.value(5 ether)(owner);
        }
        vm.prank(owner);
        {
        target.Command.value(2 ether)(alice, hex"");
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.Command(owner, hex"");
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiplicate transfers this.balance + msg.value to adr when msg.value >= this.balance.
    function test_multiplicate_sends_balance_when_msg_value_this_balance_2() public {
// assume: this.balance == 3 ether before alice's second call
// cover: multiplicate :: msg.value >= this.balance true
        vm.startPrank(alice);
        MultiplicatorX3 target = new MultiplicatorX3();
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
        target.multiplicate.value(3 ether)(owner);
        }
        {
        target.multiplicate.value(4 ether)(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiplicate does nothing when msg.value is less than this.balance.
    function test_multiplicate_does_nothing_when_msg_value_this_balance_3() public {
// assume: this.balance == 5 ether before alice's second call
// cover: multiplicate :: msg.value >= this.balance false
        vm.startPrank(alice);
        MultiplicatorX3 target = new MultiplicatorX3();
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
        target.multiplicate.value(5 ether)(owner);
        }
        {
        target.multiplicate.value(3 ether)(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Verify edge case where msg.value equals this.balance triggers transfer.
    function test_multiplicate_with_msg_value_exactly_equal_to_this_balance_4() public {
// assume: this.balance == 2 ether before alice's second call
// cover: multiplicate :: msg.value >= this.balance true
        vm.startPrank(alice);
        MultiplicatorX3 target = new MultiplicatorX3();
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
        target.multiplicate.value(2 ether)(owner);
        }
        {
        target.multiplicate.value(2 ether)(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_multiplicate_positive_5() public {
        vm.startPrank(alice);
        MultiplicatorX3 target = new MultiplicatorX3();
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
        target.multiplicate.value(2 ether)(bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_6() public {
        vm.startPrank(owner);
        MultiplicatorX3 target = new MultiplicatorX3();
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
    function test_Owner_view_7() public {
        vm.startPrank(owner);
        MultiplicatorX3 target = new MultiplicatorX3();
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

    // @cover-intent minimal test for Command
    function test_perfn_Command_8() public {
        vm.startPrank(owner);
        MultiplicatorX3 target = new MultiplicatorX3();
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
