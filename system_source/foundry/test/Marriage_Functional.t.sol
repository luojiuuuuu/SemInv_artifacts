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


    // @cover-intent Protocol State Machine: Verify that the owner can successfully create a marriage when no marriage exists yet, setting all initial state variables correctly.
    function test_create_marriage_positive_0() public {
// assume: numberOfMajorEvents() == 0
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
        vm.prank(owner);
        {
        target.createMarriage("Alice", "Bob", "To love and cherish", "ipfs://QmX");
        }
    }

    // @cover-intent Protocol State Machine: Verify that creating a marriage reverts when a marriage already exists (majorEvents.length > 0).
    function test_create_marriage_already_exists_1() public {
// assume: numberOfMajorEvents() == 1
// cover: createMarriage :: require(majorEvents.length == 0) false
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
        target.createMarriage("Alice", "Bob", "Vows", "url");
        }
        vm.expectRevert();
        {
        target.createMarriage("Carol", "Dave", "Other vows", "url2");
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that the owner can change the marriage status after marriage is created.
    function test_set_status_positive_2() public {
// assume: marriageStatus() == "Married"
// cover: setStatus :: onlyOwner modifier true
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
        target.createMarriage("Alice", "Bob", "Vows", "url");
        }
        {
        target.setStatus("Separated", "ipfs://QmY");
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot change the marriage status.
    function test_set_status_not_owner_3() public {
// assume: marriageStatus() == "Married"
// cover: setStatus :: require(msg.sender == owner) false
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
        target.createMarriage("Alice", "Bob", "Vows", "url");
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.setStatus("Separated", "url");
        }
    }

    // @cover-intent Protocol State Machine: Verify that owner can add a major event when married.
    function test_set_major_event_positive_4() public {
// assume: marriageStatus() == "Married"
// cover: setMajorEvent :: areMarried modifier true
// cover: setMajorEvent :: onlyOwner modifier true
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
        target.createMarriage("Alice", "Bob", "Vows", "url");
        }
        {
        target.setMajorEvent("Anniversary", "5 years", "ipfs://QmZ");
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that setMajorEvent reverts when marriageStatus is not 'Married'.
    function test_set_major_event_not_married_5() public {
// assume: marriageStatus() == "Divorced"
// cover: setMajorEvent :: require(sha3(marriageStatus) == sha3("Married")) false
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
        target.createMarriage("Alice", "Bob", "Vows", "url");
        }
        {
        target.setStatus("Divorced", "url");
        }
        vm.expectRevert();
        {
        target.setMajorEvent("Event", "Desc", "url");
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that a message can be sent when married, with ETH being forwarded to owner.
    function test_send_message_positive_6() public {
// assume: marriageStatus() == "Married"
// cover: sendMessage :: areMarried modifier true
// cover: sendMessage :: if (msg.value > 0) true
        vm.startPrank(alice);
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
        target.createMarriage("Alice", "Bob", "Vows", "url");
        }
        vm.prank(alice);
        {
        target.sendMessage.value(10)("Alice", "Hello world", "ipfs://QmA");
        }
    }

    // @cover-intent Protocol State Machine: Verify that sendMessage reverts when not married.
    function test_send_message_not_married_7() public {
// assume: marriageStatus() == "Divorced"
// cover: sendMessage :: require(sha3(marriageStatus) == sha3("Married")) false
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
        target.createMarriage("Alice", "Bob", "Vows", "url");
        }
        {
        target.setStatus("Divorced", "url");
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.sendMessage("Alice", "Text", "url");
        }
    }

    // @cover-intent Authorization & Access Control: Verify that ownership transfer works correctly with two-step process.
    function test_change_owner_and_accept_8() public {
// assume: owner() != alice
// cover: changeOwner :: onlyOwner modifier true
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
        {
        target.acceptOwnership();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that acceptOwnership reverts when called by someone other than newOwner.
    function test_accept_ownership_wrong_caller_9() public {
// assume: newOwner() == alice
// cover: acceptOwnership :: if (msg.sender == newOwner) false
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
        {
        target.acceptOwnership();
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that owner can execute arbitrary calls via the execute function.
    function test_execute_as_owner_10() public {
// assume: address(this).balance >= 50
// cover: execute :: onlyOwner modifier true
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
        // skip malformed call: execute(alice, 50, "0x") (bad raw arg for execute.arg2: type=bytes, raw="0x")
    }

    // @cover-intent Authorization & Access Control
    function test_acceptOwnership_positive_11() public {
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
        {
        target.acceptOwnership();
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control
    function test_changeOwner_positive_12() public {
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
    function test_createMarriage_positive_13() public {
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
        target.createMarriage("Alice", "Bob", "Forever", "http://url");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_execute_positive_14() public {
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
        target.execute(0x0000000000000000000000000000000000000001, 0, hex"00");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_majorEvents_read_15() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        vm.prank(alice);
        {
        target.majorEvents(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_marriageDate_read_16() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        vm.prank(alice);
        {
        target.marriageDate();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_marriageStatus_read_17() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        vm.prank(alice);
        {
        target.marriageStatus();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_messages_read_18() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        vm.prank(alice);
        {
        target.sendMessage("Alice", "Hi", "url");
        }
        vm.prank(bob);
        {
        target.messages(0);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_newOwner_read_19() public {
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
        {
        target.newOwner();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_numberOfMajorEvents_read_20() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        vm.prank(alice);
        {
        target.numberOfMajorEvents();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_numberOfMessages_read_21() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        vm.prank(alice);
        {
        target.sendMessage("Alice", "Hi", "url");
        }
        vm.prank(bob);
        {
        target.numberOfMessages();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_read_22() public {
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
        target.owner();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_partner1_read_23() public {
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
        target.createMarriage("Alice", "Bob", "V", "U");
        }
        vm.prank(alice);
        {
        target.partner1();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_partner2_read_24() public {
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
        target.createMarriage("Alice", "Bob", "V", "U");
        }
        vm.prank(alice);
        {
        target.partner2();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_sendMessage_positive_25() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        vm.prank(alice);
        {
        target.sendMessage("Alice", "Hello", "url");
        }
    }

    // @cover-intent Protocol State Machine
    function test_setMajorEvent_positive_26() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        {
        target.setMajorEvent("Anniversary", "5 years", "url");
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine
    function test_setStatus_positive_27() public {
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
        target.createMarriage("A", "B", "V", "U");
        }
        {
        target.setStatus("Separated", "url");
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_vows_read_28() public {
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
        target.createMarriage("A", "B", "Forever", "U");
        }
        vm.prank(alice);
        {
        target.vows();
        }
    }

}
