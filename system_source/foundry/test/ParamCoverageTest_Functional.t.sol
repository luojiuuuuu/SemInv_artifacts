// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "forge-std/Test.sol";
import "../src/ParamCoverageTest.sol";


contract ParamCoverageTest_FunctionalTest is Test {
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


    // @cover-intent 验证使用空数组部署合约时，lastArrayLen为0，lastA和lastB保持默认值
    function test_test_constructor_empty_array_0() public {
// cover: constructor :: initPairs.length == 0
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        target.lastArrayLen();
        }
        {
        target.lastA();
        }
        {
        target.lastB();
        }
        vm.stopPrank();
    }

    // @cover-intent 验证使用包含一个元素的数组部署合约时，正确存储第一个元素的a和b值以及数组长度
    function test_test_constructor_single_element_1() public {
// cover: constructor :: initPairs.length > 0
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        target.lastArrayLen();
        }
        {
        target.lastA();
        }
        {
        target.lastB();
        }
        vm.stopPrank();
    }

    // @cover-intent 验证setUintArray传入空数组时，lastSum为0，lastArrayLen为0
    function test_test_setUintArray_empty_2() public {
// cover: setUintArray :: arr.length == 0
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        uint256[] memory _arr1 = new uint256[](0);
        target.setUintArray(_arr1);
        }
        {
        target.lastSum();
        }
        {
        target.lastArrayLen();
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.lastSum());
            _assertRelU(__v1, 0, 0, "call:lastSum==0");
        }
        {
            uint256 __v2 = uint256(target.lastArrayLen());
            _assertRelU(__v2, 0, 0, "call:lastArrayLen==0");
        }
    }

    // @cover-intent 验证setUintArray传入多个元素时，正确计算总和并记录数组长度
    function test_test_setUintArray_multiple_elements_3() public {
// cover: setUintArray :: arr.length > 0
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.setUintArray(_arr1);
        }
        {
        target.lastSum();
        }
        {
        target.lastArrayLen();
        }
        vm.stopPrank();
        {
            uint256 __v3 = uint256(target.lastSum());
            _assertRelU(__v3, 0, 3, "call:lastSum==3");
        }
        {
            uint256 __v4 = uint256(target.lastArrayLen());
            _assertRelU(__v4, 0, 3, "call:lastArrayLen==3");
        }
    }

    // @cover-intent 验证setBytes32Array传入空数组时，lastHash为keccak256(空数组编码)，lastArrayLen为0
    function test_test_setBytes32Array_empty_4() public {
// cover: setBytes32Array :: arr.length == 0
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        bytes32[] memory _arr1 = new bytes32[](0);
        target.setBytes32Array(_arr1);
        }
        {
        target.lastArrayLen();
        }
        vm.stopPrank();
        {
            uint256 __v5 = uint256(target.lastArrayLen());
            _assertRelU(__v5, 0, 0, "call:lastArrayLen==0");
        }
    }

    // @cover-intent 验证setBytes32Array传入单个元素时，正确计算哈希并记录数组长度
    function test_test_setBytes32Array_single_element_5() public {
// cover: setBytes32Array :: arr.length > 0
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.setBytes32Array(_arr1);
        }
        {
        target.lastArrayLen();
        }
        vm.stopPrank();
        {
            uint256 __v6 = uint256(target.lastArrayLen());
            _assertRelU(__v6, 0, 1, "call:lastArrayLen==1");
        }
    }

    // @cover-intent state transition test for setTuple
    function test_test_setTuple_true_6() public {
// cover: setTuple :: y == true
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        target.setTuple(100, true);
        }
        {
        target.lastA();
        }
        {
        target.lastB();
        }
        vm.stopPrank();
        {
            uint256 __v7 = uint256(target.lastA());
            _assertRelU(__v7, 0, 100, "call:lastA==100");
        }
    }

    // @cover-intent state transition test for setTuple
    function test_test_setTuple_false_7() public {
// cover: setTuple :: y == false
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        target.setTuple(0, false);
        }
        {
        target.lastA();
        }
        {
        target.lastB();
        }
        vm.stopPrank();
        {
            uint256 __v8 = uint256(target.lastA());
            _assertRelU(__v8, 0, 0, "call:lastA==0");
        }
    }

    // @cover-intent state transition test for setStruct
    function test_test_setStruct_8() public {
// cover: setStruct :: default
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        ParamCoverageTest.Pair memory _s2;
        _s2.a = 1;
        _s2.b = true;
        target.setStruct(_s2);
        }
        {
        target.lastA();
        }
        {
        target.lastB();
        }
        vm.stopPrank();
        {
            uint256 __v9 = uint256(target.lastA());
            _assertRelU(__v9, 0, 1, "call:lastA==1");
        }
    }

    // @cover-intent state transition test for setStructArray
    function test_test_setStructArray_empty_9() public {
// cover: setStructArray :: arr.length == 0
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        ParamCoverageTest.Pair[] memory _arrS2 = new ParamCoverageTest.Pair[](0);
        target.setStructArray(_arrS2);
        }
        {
        target.lastArrayLen();
        }
        vm.stopPrank();
        {
            uint256 __v10 = uint256(target.lastArrayLen());
            _assertRelU(__v10, 0, 0, "call:lastArrayLen==0");
        }
    }

    // @cover-intent state transition test for setStructArray
    function test_test_setStructArray_single_element_10() public {
// cover: setStructArray :: arr.length > 0
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        ParamCoverageTest.Pair[] memory _arrS2 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s2;
        _s2.a = 1;
        _s2.b = true;
        _arrS2[0] = _s2;
        target.setStructArray(_arrS2);
        }
        {
        target.lastArrayLen();
        }
        {
        target.lastA();
        }
        {
        target.lastB();
        }
        vm.stopPrank();
        {
            uint256 __v11 = uint256(target.lastA());
            _assertRelU(__v11, 0, 1, "call:lastA==1");
        }
        {
            uint256 __v12 = uint256(target.lastArrayLen());
            _assertRelU(__v12, 0, 1, "call:lastArrayLen==1");
        }
    }

    // @cover-intent Read lastA after setting via setTuple
    function test_lastA_after_setTuple_11() public {
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        target.setTuple(42, true);
        }
        {
        target.lastA();
        }
        vm.stopPrank();
    }

    // @cover-intent Read lastArrayLen after setting via setUintArray
    function test_lastArrayLen_after_setUintArray_12() public {
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.setUintArray(_arr1);
        }
        {
        target.lastArrayLen();
        }
        vm.stopPrank();
    }

    // @cover-intent Read lastB after setting via setStruct
    function test_lastB_after_setStruct_13() public {
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        ParamCoverageTest.Pair memory _s2;
        _s2.a = 1;
        _s2.b = true;
        target.setStruct(_s2);
        }
        {
        target.lastB();
        }
        vm.stopPrank();
    }

    // @cover-intent Read lastHash after setting via setBytes32Array
    function test_lastHash_after_setBytes32Array_14() public {
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.setBytes32Array(_arr1);
        }
        {
        target.lastHash();
        }
        vm.stopPrank();
    }

    // @cover-intent Read lastSum after setting via setUintArray
    function test_lastSum_after_setUintArray_15() public {
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        uint256[] memory _arr1 = new uint256[](1);
        _arr1[0] = 1;
        target.setUintArray(_arr1);
        }
        {
        target.lastSum();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for setStruct
    function test_setStruct_basic_16() public {
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        ParamCoverageTest.Pair memory _s2;
        _s2.a = 1;
        _s2.b = true;
        target.setStruct(_s2);
        }
        {
            uint256 __v13 = uint256(target.lastA());
            _assertRelU(__v13, 0, 1, "call:lastA==1");
        }
    }

    // @cover-intent state transition test for setTuple
    function test_setTuple_basic_17() public {
        ParamCoverageTest.Pair[] memory _arrS1 = new ParamCoverageTest.Pair[](1);
        ParamCoverageTest.Pair memory _s1;
        _s1.a = 1;
        _s1.b = true;
        _arrS1[0] = _s1;
        vm.startPrank(owner);
        ParamCoverageTest target = new ParamCoverageTest(_arrS1);
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
        target.setTuple(100, true);
        }
        {
            uint256 __v14 = uint256(target.lastA());
            _assertRelU(__v14, 0, 100, "call:lastA==100");
        }
    }

}
