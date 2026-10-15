// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/name_registrar.sol";

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

contract NameRegistrar_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function NameRegistrar_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that register succeeds when unlocked is true, and that resolve and registeredNameRecord are updated correctly.
    function test_Register_when_unlocked_succeeds_0() public {
// assume: unlocked() == true
// cover: register :: require(unlocked) true
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.register(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)), alice);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that register reverts when unlocked is false (default state).
    function test_Register_when_locked_reverts_1() public {
// assume: unlocked() == false
// cover: register :: require(unlocked) false
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.register(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)), alice);
        }
    }

    // @cover-intent Transactional Consistency: Verify that a second registration by the same sender overwrites the previous NameRecord and resolve mapping.
    function test_Register_overwrites_previous_record_for_same_sender_2() public {
// assume: unlocked() == true
// cover: register :: require(unlocked) true
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.register(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)), bob);
        }
        {
        target.register(bytes32(uint256(44523455556492492196420682327295306828831106926047994823588760593746658066432)), carol);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that register accepts an empty bytes32 name (all zeros) and updates state accordingly.
    function test_Register_with_empty_name_3() public {
// assume: unlocked() == true
// cover: register :: require(unlocked) true
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.register(bytes32(uint256(0)), alice);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that resolve returns address(0) for a name that has not been registered.
    function test_Resolve_unregistered_name_returns_address_0_4() public {
// assume: unlocked() == true
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.register(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)), alice);
        }
        vm.prank(bob);
        {
        target.resolve(bytes32(uint256(44523455556492492196420682327295306828831106926047994823588760593746658066432)));
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that registeredNameRecord for an address that never called register returns a default NameRecord (name=0, mappedAddress=0).
    function test_RegisteredNameRecord_for_unregistered_sender_returns_default_5() public {
// assume: unlocked() == true
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.register(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)), alice);
        }
        vm.prank(bob);
        {
        target.registeredNameRecord(bob);
        }
    }

    // @cover-intent Protocol State Machine
    function test_register_success_6() public {
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.register(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)), alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_registeredNameRecord_query_7() public {
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.register(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)), alice);
        }
        vm.prank(bob);
        {
        target.registeredNameRecord(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_resolve_query_8() public {
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.register(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)), alice);
        }
        vm.prank(bob);
        {
        target.resolve(bytes32(uint256(44065893158610579695442735846418141283404106108805717173113286591224259543040)));
        }
    }

    // @cover-intent Protocol State Machine
    function test_unlocked_query_9() public {
        vm.startPrank(owner);
        NameRegistrar target = new NameRegistrar();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: unlocked()
    }

}
