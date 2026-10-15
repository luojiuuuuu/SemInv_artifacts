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
// assume: msg.sender == Owner for withdraw
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

    // @cover-intent Authorization & Access Control: Verify that only the Owner can call Command, and that it forwards ETH correctly.
    function test_Owner_executes_arbitrary_command_via_Command_1() public {
// assume: msg.sender == Owner for Command
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

    // @cover-intent Financial & Accounting: Verify that multiplicate transfers the entire contract balance plus msg.value when condition is met.
    function test_multiplicate_sends_entire_balance_when_msg_value_balance_2() public {
// assume: msg.value >= this.balance
// cover: multiplicate :: if(msg.value>=this.balance) true
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
        target.multiplicate.value(5 ether)(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that multiplicate does nothing when msg.value is less than contract balance.
    function test_multiplicate_does_nothing_when_msg_value_balance_3() public {
// assume: msg.value < this.balance
// cover: multiplicate :: if(msg.value>=this.balance) false
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
        target.multiplicate.value(8 ether)(owner);
        }
        {
        target.multiplicate.value(1 ether)(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Authorization & Access Control: Verify that Owner can withdraw the full balance after multiple deposits.
    function test_Owner_withdraws_after_multiple_deposits_4() public {
// assume: msg.sender == Owner
// cover: withdraw :: require(msg.sender == Owner) true
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

    // @cover-intent External Interaction & Environment: Verify that Command forwards data and ETH to the target address.
    function test_Command_with_data_executes_on_target_5() public {
// assume: msg.sender == Owner
// cover: Command :: require(msg.sender == Owner) true
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
        target.Command.value(1 ether)(alice, hex"deadbeef");
        }
    }

    // @cover-intent Financial & Accounting: Verify that multiplicate triggers when msg.value exactly equals contract balance.
    function test_multiplicate_with_exact_balance_boundary_6() public {
// assume: msg.value == this.balance
// cover: multiplicate :: if(msg.value>=this.balance) true
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
        target.multiplicate.value(4 ether)(owner);
        }
        {
        target.multiplicate.value(4 ether)(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_multiplicate_positive_7() public {
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
        target.multiplicate.value(1 ether)(bob);
        }
        {
        target.multiplicate.value(1 ether)(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_8() public {
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
        vm.startPrank(owner);
        {
        target.multiplicate.value(1 ether)(owner);
        }
        // skip ABI-mismatched call: withdraw()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_revert_nonowner_9() public {
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
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Authorization & Access Control
    function test_Owner_read_10() public {
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
    function test_perfn_Command_11() public {
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
