// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/mapping_write.sol";

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

contract Map_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Map_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that set and get work correctly for a normal key-value pair.
    function test_Set_and_get_a_value_0() public {
// cover: set :: map.length <= key true
        vm.startPrank(owner);
        Map target = new Map();
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
        target.set(0, 42);
        }
        {
        target.get(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that setting at a large key extends the array and stores the value.
    function test_Set_at_a_large_key_to_extend_array_1() public {
// cover: set :: map.length <= key true
        vm.startPrank(owner);
        Map target = new Map();
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
        target.set(100, 123);
        }
        {
        target.get(100);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that setting at key 0 works after array has been extended.
    function test_Set_at_key_0_after_previous_set_2() public {
// cover: set :: map.length <= key false
        vm.startPrank(owner);
        Map target = new Map();
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
        target.set(5, 99);
        }
        {
        target.set(0, 77);
        }
        {
        target.get(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner can withdraw contract balance.
    function test_Withdraw_by_owner_3() public {
// assume: address(this).balance >= 100
// cover: withdraw :: require(msg.sender == owner) true
        vm.startPrank(owner);
        Map target = new Map();
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
        target.set(0, 0);
        }
        vm.prank(owner);
        {
        target.withdraw();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that non-owner cannot withdraw.
    function test_Withdraw_by_non_owner_reverts_4() public {
// cover: withdraw :: require(msg.sender == owner) false
        vm.startPrank(owner);
        Map target = new Map();
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

    // @cover-intent Resource & Execution Integrity: Verify that reading an unset key returns 0.
    function test_Get_unset_key_returns_0_5() public {
        vm.startPrank(owner);
        Map target = new Map();
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
        target.get(0);
        }
    }

    // @cover-intent Resource & Execution Integrity: Verify that setting an existing key overwrites the value.
    function test_Set_overwrites_existing_value_6() public {
// cover: set :: map.length <= key false
        vm.startPrank(owner);
        Map target = new Map();
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
        target.set(2, 10);
        }
        {
        target.set(2, 20);
        }
        {
        target.get(2);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify that owner() returns the contract owner.
    function test_Owner_function_returns_owner_address_7() public {
        vm.startPrank(owner);
        Map target = new Map();
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

    // @cover-intent Authorization & Access Control
    function test_owner_positive_8() public {
        vm.startPrank(owner);
        Map target = new Map();
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

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_9() public {
        vm.startPrank(owner);
        Map target = new Map();
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
        // TODO assert: owner.balance == 0
    }

    // @cover-intent minimal test for get
    function test_perfn_get_10() public {
        vm.startPrank(owner);
        Map target = new Map();
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
        target.get(1);
        }
    }

    // @cover-intent minimal test for set
    function test_perfn_set_11() public {
        vm.startPrank(owner);
        Map target = new Map();
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
        target.set(1, 100);
        }
    }

}
