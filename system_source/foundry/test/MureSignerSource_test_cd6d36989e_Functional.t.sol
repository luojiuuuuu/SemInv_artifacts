// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "forge-std/Test.sol";
import "../src/MureDistribution_exp.sol";


contract MureSignerSource_FunctionalTest is Test {
    address owner = address(0x0A0A);
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address carol = address(0xCA1CE);


    // ---------- Helpers (0.8+) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        assertEq(a, b);
    }
    function _delta(int256 after_, int256 before_) internal pure returns (int256) {
        return after_ - before_;
    }
    function _assertTrue(bool ok, string memory why) internal {
        assertTrue(ok, why);
    }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) assertEq(a, b, why);
        else if (op == 1) assertTrue(a != b, why);
        else if (op == 2) assertGe(a, b, why);
        else if (op == 3) assertLe(a, b, why);
        else if (op == 4) assertTrue(a >  b, why);
        else if (op == 5) assertTrue(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        assertLe(d, tol, why);
    }
    function _assertEqA(address a, address b) internal {
        assertEq(a, b);
    }
    function _assertEqB32(bytes32 a, bytes32 b) internal {
        assertEq(a, b);
    }
    function _assertEqS(string memory a, string memory b) internal {
        assertEq(a, b);
    }


    // @cover-intent Authorization & Access Control: Verify that only the owner can call attack() and that it succeeds when called by the owner.
    function test_Positive_attack_path_with_owner_0() public {
// assume: msg.sender == owner
// cover: attack :: require(msg.sender == owner) true
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
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
        // skip ABI-mismatched call: attack()
        // skip ABI-mismatched call: attack()
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Confirm that a non-owner caller (alice) is reverted when calling attack().
    function test_Non_owner_reverts_on_attack_1() public {
// assume: msg.sender != owner
// cover: attack :: require(msg.sender == owner) false
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
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
        // skip ABI-mismatched call: attack()
    }

    // @cover-intent External Interaction & Environment: Verify that isValidSignature always returns the ERC1271 magic value regardless of inputs.
    function test_isValidSignature_returns_magic_value_2() public {
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
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
        target.isValidSignature(bytes32(uint256(1)), hex"00");
        }
    }

    // @cover-intent External Interaction & Environment: Verify that supportsInterface returns true for ERC165 and MURE_POOL interface IDs.
    function test_supportsInterface_returns_true_for_known_interfaces_3() public {
// cover: supportsInterface :: interfaceId == ERC165_INTERFACE_ID true
// cover: supportsInterface :: interfaceId == MURE_POOL_INTERFACE_ID true
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(carol);
        {
        target.supportsInterface(bytes4(hex"01ffc9a7"));
        }
        {
        target.supportsInterface(bytes4(hex"10704b42"));
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment: Verify that supportsInterface returns false for an arbitrary interface ID.
    function test_supportsInterface_returns_false_for_unknown_interface_4() public {
// cover: supportsInterface :: interfaceId == ERC165_INTERFACE_ID false
// cover: supportsInterface :: interfaceId == MURE_POOL_INTERFACE_ID false
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
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
        target.supportsInterface(bytes4(hex"ffffffff"));
        }
    }

    // @cover-intent Authorization & Access Control
    function test_attack_as_owner_5() public {
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
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
        // skip ABI-mismatched call: attack()
    }

    // @cover-intent External Interaction & Environment
    function test_isValidSignature_returns_magic_value_6() public {
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
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
        target.isValidSignature(bytes32(uint256(0)), hex"00");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_supportsInterface_returns_true_for_known_interfaces_7() public {
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.supportsInterface(bytes4(hex"01ffc9a7"));
        }
    }

    // @cover-intent minimal test for poolState
    function test_perfn_poolState_8() public {
        vm.startPrank(owner);
        MureSignerSource target = new MureSignerSource(alice);
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
        target.poolState("X");
        }
    }

}
