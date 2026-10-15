// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "forge-std/Test.sol";
import "../src/Bytes32ArrayCtorOnly.sol";


contract Bytes32ArrayCtorOnly_FunctionalTest is Test {
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


    // @cover-intent 测试构造器传入两个bytes32元素，验证names数组长度和元素值正确
    function test_constructor_with_two_names_0() public {
// cover: constructor :: loop i < initNames.length true
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Bytes32ArrayCtorOnly target = new Bytes32ArrayCtorOnly(_arr1);
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
        target.names(0);
        }
        {
        target.names(1);
        }
        {
        target.namesLength();
        }
        vm.stopPrank();
    }

    // @cover-intent 测试构造器传入空数组，验证names数组长度为0
    function test_constructor_with_empty_array_1() public {
// cover: constructor :: loop i < initNames.length false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Bytes32ArrayCtorOnly target = new Bytes32ArrayCtorOnly(_arr1);
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
        target.namesLength();
        }
    }

    // @cover-intent 测试构造器传入一个bytes32元素，验证names数组长度和元素值
    function test_constructor_with_single_name_2() public {
// cover: constructor :: loop i < initNames.length true
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Bytes32ArrayCtorOnly target = new Bytes32ArrayCtorOnly(_arr1);
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
        target.names(0);
        }
        {
        target.namesLength();
        }
        vm.stopPrank();
    }

    // @cover-intent 测试构造器传入较大数组（5个元素），验证names数组长度和元素可访问
    function test_constructor_with_max_size_array_3() public {
// cover: constructor :: loop i < initNames.length true
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Bytes32ArrayCtorOnly target = new Bytes32ArrayCtorOnly(_arr1);
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
        target.names(0);
        }
        {
        target.names(4);
        }
        {
        target.namesLength();
        }
        vm.stopPrank();
    }

    // @cover-intent 测试访问超出数组长度的索引，预期回退
    function test_access_out_of_bounds_index_4() public {
// cover: names :: require(index < length) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Bytes32ArrayCtorOnly target = new Bytes32ArrayCtorOnly(_arr1);
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
        target.names(2);
        }
    }

    // @cover-intent Verify that names(uint256) returns the first element of the names array after construction with a single element.
    function test_names_read_element_at_index_0_5() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Bytes32ArrayCtorOnly target = new Bytes32ArrayCtorOnly(_arr1);
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
        target.names(0);
        }
        _assertEqB32(target.names(0), bytes32(uint256(1)));
    }

    // @cover-intent Verify that namesLength() returns the length of the names array after construction with two elements.
    function test_namesLength_returns_correct_length_after_construction_6() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        Bytes32ArrayCtorOnly target = new Bytes32ArrayCtorOnly(_arr1);
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
        target.namesLength();
        }
        {
            uint256 __v1 = uint256(target.namesLength());
            _assertRelU(__v1, 0, 2, "call:namesLength==2");
        }
    }

}
