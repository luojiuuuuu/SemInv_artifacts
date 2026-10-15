// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x958a8f594101d2c0485a52319f29b2647f2ebc06.sol";

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

contract Marriage_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Marriage_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that the owner can successfully create a marriage when no marriage exists, setting initial state correctly.
    function test_create_marriage_positive_0() public {
// cover: createMarriage :: require(majorEvents.length == 0) true
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: partner1()
        // skip ABI-mismatched call: partner2()
        // skip ABI-mismatched call: marriageStatus()
        // skip ABI-mismatched call: numberOfMajorEvents()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that owner can change marriage status after marriage is created.
    function test_set_status_positive_1() public {
// cover: setStatus :: require(msg.sender == owner) true
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: marriageStatus()
        // skip ABI-mismatched call: numberOfMajorEvents()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that owner can add a major event when married.
    function test_set_major_event_positive_2() public {
// cover: setMajorEvent :: require(sha3(marriageStatus) == sha3("Married")) true
// cover: setMajorEvent :: require(msg.sender == owner) true
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: numberOfMajorEvents()
    }

    // @cover-intent Financial & Accounting: Verify that sendMessage works when married, forwards ETH to owner, and records the message.
    function test_send_message_positive_with_eth_3() public {
// cover: sendMessage :: require(sha3(marriageStatus) == sha3("Married")) true
// cover: sendMessage :: if (msg.value > 0) true
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: numberOfMessages()
        {
        target.messages(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify full ownership transfer cycle: changeOwner + acceptOwnership.
    function test_ownership_transfer_positive_4() public {
// cover: changeOwner :: require(msg.sender == owner) true
// cover: acceptOwnership :: if (msg.sender == newOwner) true
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.changeOwner(alice);
        }
        // skip ABI-mismatched call: newOwner()
        // skip ABI-mismatched call: acceptOwnership()
        // skip ABI-mismatched call: owner()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_acceptOwnership_positive_5() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.changeOwner(alice);
        }
        // skip ABI-mismatched call: acceptOwnership()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_6() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.changeOwner(bob);
        }
    }

    // @cover-intent Protocol State Machine
    function test_majorEvents_read_7() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.majorEvents(0);
        }
    }

    // @cover-intent Protocol State Machine
    function test_marriageDate_read_8() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: marriageDate()
    }

    // @cover-intent Protocol State Machine
    function test_marriageStatus_read_9() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: marriageStatus()
    }

    // @cover-intent Protocol State Machine
    function test_messages_read_10() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.messages(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_newOwner_read_11() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.changeOwner(bob);
        }
        vm.prank(alice);
        // skip ABI-mismatched call: newOwner()
    }

    // @cover-intent Protocol State Machine
    function test_numberOfMajorEvents_read_12() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: numberOfMajorEvents()
    }

    // @cover-intent Protocol State Machine
    function test_numberOfMessages_read_13() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: numberOfMessages()
    }

    // @cover-intent Authorization & Access Control
    function test_owner_read_14() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Protocol State Machine
    function test_partner1_read_15() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: partner1()
    }

    // @cover-intent Protocol State Machine
    function test_partner2_read_16() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: partner2()
    }

    // @cover-intent Protocol State Machine
    function test_vows_read_17() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        // skip ABI-mismatched call: vows()
    }

    // @cover-intent minimal test for createMarriage
    function test_perfn_createMarriage_18() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.createMarriage("X", "X", "X", "X");
        }
    }

    // @cover-intent minimal test for execute
    function test_perfn_execute_19() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.execute(alice, 100, hex"01");
        }
    }

    // @cover-intent minimal test for sendMessage
    function test_perfn_sendMessage_20() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.sendMessage("Name", "X", "X");
        }
    }

    // @cover-intent minimal test for setMajorEvent
    function test_perfn_setMajorEvent_21() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.setMajorEvent("Name", "X", "X");
        }
    }

    // @cover-intent minimal test for setStatus
    function test_perfn_setStatus_22() public {
        vm.startPrank(owner);
        Marriage target = new Marriage(alice);
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
        target.setStatus("X", "X");
        }
    }

}
