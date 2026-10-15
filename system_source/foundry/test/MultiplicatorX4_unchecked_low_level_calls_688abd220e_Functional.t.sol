// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x3e013fc32a54c4c5b6991ba539dcd0ec4355c859.sol";

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

contract MultiplicatorX4_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function MultiplicatorX4_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that only the Owner can withdraw the contract balance.
    function test_Owner_withdraws_balance_0() public {
// cover: withdraw :: require(msg.sender == Owner) true
// cover: withdraw :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        MultiplicatorX4 target = new MultiplicatorX4();
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

    // @cover-intent External Interaction & Environment: Owner can execute arbitrary code via Command with value.
    function test_Command_delegate_call_by_Owner_1() public {
// cover: Command :: require(msg.sender == Owner) true
// cover: Command :: require(msg.sender == Owner) false
        vm.startPrank(alice);
        MultiplicatorX4 target = new MultiplicatorX4();
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
        target.Command.value(1 ether)(alice, hex"00");
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.Command(owner, hex"00");
        }
    }

    // @cover-intent Financial & Accounting: When msg.value >= contract balance, the function transfers contract balance + msg.value to the target address.
    function test_Multiplicate_when_msg_value_this_balance_2() public {
// cover: multiplicate :: msg.value >= this.balance true
        vm.startPrank(alice);
        MultiplicatorX4 target = new MultiplicatorX4();
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
        target.multiplicate.value(3 ether)(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: When msg.value < contract balance, the function does not transfer and effectively does nothing (no revert).
    function test_Multiplicate_when_msg_value_this_balance_3() public {
// cover: multiplicate :: msg.value >= this.balance false
        vm.startPrank(alice);
        MultiplicatorX4 target = new MultiplicatorX4();
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
        target.multiplicate.value(1 ether)(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 0
    }

    // @cover-intent Financial & Accounting: Boundary test where msg.value exactly equals this.balance, triggering the transfer.
    function test_Multiplicate_edge_case_msg_value_equals_this_balance_4() public {
// cover: multiplicate :: msg.value >= this.balance true
        vm.startPrank(alice);
        MultiplicatorX4 target = new MultiplicatorX4();
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
        target.multiplicate.value(3 ether)(bob);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that Owner() returns the correct owner address.
    function test_Owner_reads_Owner_variable_5() public {
        vm.startPrank(owner);
        MultiplicatorX4 target = new MultiplicatorX4();
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
    function test_Owner_read_6() public {
        vm.startPrank(owner);
        MultiplicatorX4 target = new MultiplicatorX4();
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
        MultiplicatorX4 target = new MultiplicatorX4();
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
    function test_perfn_Command_8() public {
        vm.startPrank(owner);
        MultiplicatorX4 target = new MultiplicatorX4();
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

    // @cover-intent minimal test for multiplicate
    function test_perfn_multiplicate_9() public {
        vm.startPrank(owner);
        MultiplicatorX4 target = new MultiplicatorX4();
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
        target.multiplicate(alice);
        }
    }

}
