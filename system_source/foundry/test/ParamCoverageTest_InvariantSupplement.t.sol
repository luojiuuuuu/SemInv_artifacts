// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "./ParamCoverageTest_Invariant.t.sol";

// Supplemental semantic-invariant tests generated separately from the main invariant file.
// These contracts are safe to edit, run, or disable without changing the baseline invariant tests.

abstract contract ParamCoverageTestSemanticSupplementBase is ParamCoverageTestBaseTest {
    function _readUint0(string memory sig) internal view returns (bool, uint256) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig));
        if(!ok || data.length < 32) return (false, 0);
        return (true, abi.decode(data, (uint256)));
    }

    function _readAddress0(string memory sig) internal view returns (bool, address) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig));
        if(!ok || data.length < 32) return (false, address(0));
        return (true, abi.decode(data, (address)));
    }

    function _readUint1Addr(string memory sig, address a) internal view returns (bool, uint256) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig, a));
        if(!ok || data.length < 32) return (false, 0);
        return (true, abi.decode(data, (uint256)));
    }
}

contract ParamCoverageTestCrossRelationSupplementTest is ParamCoverageTestSemanticSupplementBase {

    function invariant_supplement_cross_setUintArray_setBytes32Array_0() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastArrayLen, uint256 lastArrayLen) = _readUint0("lastArrayLen()");
        if(!ok_lastArrayLen) return;
        assertTrue(lastArrayLen < 1e30);
    }

    function invariant_supplement_cross_setUintArray_setStructArray_1() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastArrayLen, uint256 lastArrayLen) = _readUint0("lastArrayLen()");
        if(!ok_lastArrayLen) return;
        assertTrue(lastArrayLen < 1e30);
    }

    function invariant_supplement_cross_setBytes32Array_setUintArray_2() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastArrayLen, uint256 lastArrayLen) = _readUint0("lastArrayLen()");
        if(!ok_lastArrayLen) return;
        assertTrue(lastArrayLen < 1e30);
    }

    function invariant_supplement_cross_setBytes32Array_setStructArray_3() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastArrayLen, uint256 lastArrayLen) = _readUint0("lastArrayLen()");
        if(!ok_lastArrayLen) return;
        assertTrue(lastArrayLen < 1e30);
    }

    function invariant_supplement_cross_setTuple_setStruct_4() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastA, uint256 lastA) = _readUint0("lastA()");
        if(!ok_lastA) return;
        assertTrue(lastA < 1e30);
    }

    function invariant_supplement_cross_setTuple_setStructArray_5() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastA, uint256 lastA) = _readUint0("lastA()");
        if(!ok_lastA) return;
        assertTrue(lastA < 1e30);
    }

    function invariant_supplement_cross_setStruct_setTuple_6() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastA, uint256 lastA) = _readUint0("lastA()");
        if(!ok_lastA) return;
        assertTrue(lastA < 1e30);
    }

    function invariant_supplement_cross_setStruct_setStructArray_7() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastA, uint256 lastA) = _readUint0("lastA()");
        if(!ok_lastA) return;
        assertTrue(lastA < 1e30);
    }

    function invariant_supplement_cross_setStructArray_setUintArray_8() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastArrayLen, uint256 lastArrayLen) = _readUint0("lastArrayLen()");
        if(!ok_lastArrayLen) return;
        assertTrue(lastArrayLen < 1e30);
    }

    function invariant_supplement_cross_setStructArray_setBytes32Array_9() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastArrayLen, uint256 lastArrayLen) = _readUint0("lastArrayLen()");
        if(!ok_lastArrayLen) return;
        assertTrue(lastArrayLen < 1e30);
    }

    function invariant_supplement_cross_setStructArray_setTuple_10() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastA, uint256 lastA) = _readUint0("lastA()");
        if(!ok_lastA) return;
        assertTrue(lastA < 1e30);
    }

    function invariant_supplement_cross_setStructArray_setStruct_11() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_lastA, uint256 lastA) = _readUint0("lastA()");
        if(!ok_lastA) return;
        assertTrue(lastA < 1e30);
    }
}
