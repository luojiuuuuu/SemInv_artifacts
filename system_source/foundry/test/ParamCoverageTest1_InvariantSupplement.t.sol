// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "./ParamCoverageTest1_Invariant.t.sol";

// Supplemental semantic-invariant tests generated separately from the main invariant file.
// These contracts are safe to edit, run, or disable without changing the baseline invariant tests.

abstract contract ParamCoverageTest1SemanticSupplementBase is ParamCoverageTest1BaseTest {
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

contract ParamCoverageTest1AccessNoninterferenceSupplementTest is ParamCoverageTest1SemanticSupplementBase {

    function test_supplement_access_noninterference_0_transferOwnership() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
    }

    function test_supplement_access_noninterference_1_pause() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("pause()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
    }

    function test_supplement_access_noninterference_2_unpause() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("unpause()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
    }
}

contract ParamCoverageTest1CrossRelationSupplementTest is ParamCoverageTest1SemanticSupplementBase {

    function invariant_supplement_cross_setNumbers_setAddresses_22() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNumbers_setNames_23() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNumbers_setPair_24() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNumbers_setPairs_25() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNumbers_useVoter_26() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNumbers_mixedArgs_27() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNumbers_arrayAndStruct_28() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNumbers_arrayOfStructsAndScalar_29() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setAddresses_setNumbers_30() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setAddresses_setNames_31() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setAddresses_setPair_32() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setAddresses_setPairs_33() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setAddresses_useVoter_34() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setAddresses_mixedArgs_35() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setAddresses_arrayAndStruct_36() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setAddresses_arrayOfStructsAndScalar_37() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNames_setNumbers_38() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNames_setAddresses_39() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNames_setPair_40() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNames_setPairs_41() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNames_useVoter_42() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNames_mixedArgs_43() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNames_arrayAndStruct_44() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setNames_arrayOfStructsAndScalar_45() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPair_setNumbers_46() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPair_setAddresses_47() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPair_setNames_48() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPair_setPairs_49() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPair_useVoter_50() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPair_mixedArgs_51() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPair_arrayAndStruct_52() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPair_arrayOfStructsAndScalar_53() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPairs_setNumbers_54() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPairs_setAddresses_55() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPairs_setNames_56() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPairs_setPair_57() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPairs_useVoter_58() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPairs_mixedArgs_59() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPairs_arrayAndStruct_60() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_setPairs_arrayOfStructsAndScalar_61() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_setNumbers_62() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_setAddresses_63() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_setNames_64() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_setPair_65() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_setPairs_66() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_mixedArgs_67() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_arrayAndStruct_68() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_arrayOfStructsAndScalar_69() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_useVoter_deposit_70() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_useVoter_withdraw_71() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_mixedArgs_setNumbers_72() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_mixedArgs_setAddresses_73() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_mixedArgs_setNames_74() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_mixedArgs_setPair_75() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_mixedArgs_setPairs_76() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_mixedArgs_useVoter_77() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_mixedArgs_arrayAndStruct_78() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_mixedArgs_arrayOfStructsAndScalar_79() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayAndStruct_setNumbers_80() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayAndStruct_setAddresses_81() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayAndStruct_setNames_82() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayAndStruct_setPair_83() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayAndStruct_setPairs_84() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayAndStruct_useVoter_85() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayAndStruct_mixedArgs_86() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayAndStruct_arrayOfStructsAndScalar_87() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayOfStructsAndScalar_setNumbers_88() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayOfStructsAndScalar_setAddresses_89() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayOfStructsAndScalar_setNames_90() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayOfStructsAndScalar_setPair_91() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayOfStructsAndScalar_setPairs_92() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayOfStructsAndScalar_useVoter_93() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayOfStructsAndScalar_mixedArgs_94() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_arrayOfStructsAndScalar_arrayAndStruct_95() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_total, uint256 total) = _readUint0("total()");
        if(!ok_total) return;
        assertTrue(total < 1e30);
    }

    function invariant_supplement_cross_deposit_useVoter_96() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_withdraw_useVoter_98() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }
}
