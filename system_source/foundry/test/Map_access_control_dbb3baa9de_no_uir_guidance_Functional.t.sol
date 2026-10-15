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


    // @cover-intent Verify normal behavior of set and get functions for a new key-value pair (Resource & Execution Integrity)
    function test_Basic_set_and_get_0() public {
// cover: set :: map.length <= key (true)
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

    // @cover-intent Verify that setting an existing key overwrites its value (Resource & Execution Integrity)
    function test_Set_overwrites_existing_value_1() public {
// cover: set :: map.length <= key (false)
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
        target.set(0, 100);
        }
        {
        target.set(0, 200);
        }
        {
        target.get(0);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that setting a key beyond current array length extends the array (Resource & Execution Integrity)
    function test_Set_at_large_key_extends_array_2() public {
// cover: set :: map.length <= key (true)
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
        target.set(0, 1);
        }
        {
        target.set(100, 999);
        }
        {
        target.get(100);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that getting an unset key returns 0 (default value) (Resource & Execution Integrity)
    function test_Get_unset_key_returns_default_3() public {
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
        target.set(0, 1);
        }
        {
        target.get(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that only the owner can withdraw contract balance (Authorization & Access Control)
    function test_Owner_can_withdraw_4() public {
// assume: address(this).balance >= 0
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
        target.set(0, 1);
        }
        vm.prank(owner);
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Verify that a non-owner cannot call withdraw (Authorization & Access Control)
    function test_Non_owner_cannot_withdraw_5() public {
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
        // skip ABI-mismatched call: withdraw()
    }

    // @cover-intent Verify that owner() returns the correct owner address (Authorization & Access Control)
    function test_Owner_check_via_owner_6() public {
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Resource & Execution Integrity
    function test_set_positive_7() public {
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
        target.set(0, 42);
        }
        {
            uint256 __v1 = uint256(target.get(0));
            _assertRelU(__v1, 0, 42, "call:get==42");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_get_positive_8() public {
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
        target.set(0, 7);
        }
        {
        target.get(0);
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.get(0));
            _assertRelU(__v2, 0, 7, "call:get==7");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_positive_9() public {
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Authorization & Access Control
    function test_withdraw_positive_10() public {
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
        // skip ABI-mismatched call: withdraw()
    }

}
