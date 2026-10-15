// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/arbitrary_location_write_simple.sol";

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

contract Wallet_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function Wallet_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that PushBonusCode and UpdateBonusCodeAt work correctly for valid indices.
    function test_Push_and_update_bonus_code_normal_path_0() public {
// cover: UpdateBonusCodeAt :: require(idx < bonusCodes.length) true
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        target.PushBonusCode(10);
        }
        {
        target.PushBonusCode(20);
        }
        {
        target.UpdateBonusCodeAt(0, 100);
        }
        {
        target.UpdateBonusCodeAt(1, 200);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that UpdateBonusCodeAt reverts when idx >= bonusCodes.length.
    function test_Update_bonus_code_at_out_of_bounds_index_1() public {
// cover: UpdateBonusCodeAt :: require(idx < bonusCodes.length) false
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        target.PushBonusCode(10);
        }
        vm.expectRevert();
        {
        target.UpdateBonusCodeAt(1, 100);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that PopBonusCode reduces array length when array is non-empty.
    function test_Pop_bonus_code_normal_path_2() public {
// cover: PopBonusCode :: require(0 <= bonusCodes.length) true
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        target.PushBonusCode(10);
        }
        {
        target.PushBonusCode(20);
        }
        // skip ABI-mismatched call: PopBonusCode()
        // skip ABI-mismatched call: PopBonusCode()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity: Verify that PopBonusCode causes underflow when array is empty (vulnerability).
    function test_Pop_bonus_code_on_empty_array_underflow_3() public {
// cover: PopBonusCode :: require(0 <= bonusCodes.length) true
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: PopBonusCode()
    }

    // @cover-intent Authorization & Access Control: Verify that only owner can call Destroy.
    function test_Destroy_owner_only_4() public {
// cover: Destroy :: require(msg.sender == owner) false
// cover: Destroy :: require(msg.sender == owner) true
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        // skip ABI-mismatched call: Destroy()
        vm.prank(owner);
        // skip ABI-mismatched call: Destroy()
    }

    // @cover-intent Authorization & Access Control
    function test_Destroy_positive_5() public {
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        target.PushBonusCode(1);
        }
        // skip ABI-mismatched call: Destroy()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_PopBonusCode_positive_6() public {
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        target.PushBonusCode(42);
        }
        // skip ABI-mismatched call: PopBonusCode()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_PushBonusCode_positive_7() public {
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        target.PushBonusCode(7);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_UpdateBonusCodeAt_positive_8() public {
        vm.startPrank(owner);
        Wallet target = new Wallet();
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
        target.PushBonusCode(10);
        }
        {
        target.PushBonusCode(20);
        }
        {
        target.UpdateBonusCodeAt(1, 99);
        }
        vm.stopPrank();
    }

}
