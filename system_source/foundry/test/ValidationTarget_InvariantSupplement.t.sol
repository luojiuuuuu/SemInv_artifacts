// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "./ValidationTarget_Invariant.t.sol";

// Supplemental semantic-invariant tests generated separately from the main invariant file.
// These contracts are safe to edit, run, or disable without changing the baseline invariant tests.

abstract contract ValidationTargetSemanticSupplementBase is ValidationTargetBaseTest {
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

contract ValidationTargetAccountingSupplementTest is ValidationTargetSemanticSupplementBase {

    function invariant_supplement_accounting_sum_0() public view {
        // invariant: I1.accounting.sum_supply_consistency
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            (bool okBal, uint256 balValue) = _readUint1Addr("_balances(address)", a);
            if(!okBal) return;
            sum += balValue;
        }
        (bool okSupply, uint256 supplyValue) = _readUint0("_totalSupply()");
        if(!okSupply) return;
        assertTrue(sum <= supplyValue);
    }
}

contract ValidationTargetAccessNoninterferenceSupplementTest is ValidationTargetSemanticSupplementBase {

    function test_supplement_access_noninterference_0_transferOwnership() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_1_pause() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("pause()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_2_unpause() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("unpause()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_3_mint() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("mint(address,uint256)", address(0x1001), 1));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_4_burn() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burn(address,uint256)", address(0x1001), 1));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_5_activate() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activate()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_6_close() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("close()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_7_rollbackStage() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("rollbackStage()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_8_emergencyPause() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("emergencyPause()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_9_resume() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("resume()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_10_addWhitelist() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("addWhitelist(address)", address(0x1001)));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_11_removeWhitelist() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("removeWhitelist(address)", address(0x1001)));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_12_mintBonus() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("mintBonus(address,uint256)", address(0x1001), 1));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_13_burnBonus() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnBonus(address,uint256)", address(0x1001), 1));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_14_resetToInitForTest() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("_owner()");
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("_totalSupply()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("resetToInitForTest()"));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("_owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("_totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }
}

contract ValidationTargetTerminalSupplementTest is ValidationTargetSemanticSupplementBase {

    function invariant_supplement_phase_terminal_absorbing() public view {
        // invariant: I3.state.terminal_absorbing
        if(handler.entered_terminal_phase()) {
            uint256 curr = handler.curr_phase();
            assertTrue(curr == 2);
        }
    }
}

contract ValidationTargetCrossRelationSupplementTest is ValidationTargetSemanticSupplementBase {

    function invariant_supplement_cross__mint_totalSupply_5() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
    }

    function invariant_supplement_cross__mint_balanceOf_6() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__mint__transfer_8() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__mint__wipe_9() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__mint_mintBonus_10() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__burn_totalSupply_12() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
    }

    function invariant_supplement_cross__burn_balanceOf_13() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__burn__transfer_15() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__burn__wipe_16() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__burn_burnBonus_18() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__transfer_balanceOf_19() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__transfer__mint_20() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__transfer__burn_21() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__transfer__wipe_22() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__transfer_mintBonus_23() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__transfer_burnBonus_24() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__wipe_totalSupply_25() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
    }

    function invariant_supplement_cross__wipe_balanceOf_26() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__wipe__mint_27() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__wipe__burn_28() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__wipe__transfer_29() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__wipe_mintBonus_30() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__wipe_burnBonus_31() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross__activate__close_32() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross__activate_resetToInitForTest_33() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross__close__activate_34() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross__close_resetToInitForTest_35() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross__advanceStage__advanceStageByAssign_36() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__advanceStage__advanceStageUnary_37() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__advanceStage__rollbackStage_38() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__advanceStage_forceNextStage_39() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__advanceStageByAssign__advanceStage_40() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__advanceStageByAssign__advanceStageUnary_41() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__advanceStageByAssign__rollbackStage_42() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__advanceStageByAssign_forceNextStage_43() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__rollbackStage__advanceStage_44() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__rollbackStage__advanceStageByAssign_45() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__rollbackStage__advanceStageUnary_46() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross__rollbackStage_forceNextStage_47() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross_forceNextStage__advanceStage_50() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross_forceNextStage__advanceStageByAssign_51() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross_forceNextStage__advanceStageUnary_52() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross_forceNextStage__rollbackStage_53() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_stage, uint256 stage) = _readUint0("stage()");
        if(!ok_stage) return;
        assertTrue(stage < 1e30);
    }

    function invariant_supplement_cross_mintBonus_totalSupply_54() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
    }

    function invariant_supplement_cross_mintBonus_balanceOf_55() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_mintBonus__mint_56() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_mintBonus__transfer_58() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_mintBonus__wipe_59() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_burnBonus_totalSupply_61() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
    }

    function invariant_supplement_cross_burnBonus_balanceOf_62() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_burnBonus__burn_64() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_burnBonus__transfer_65() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_burnBonus__wipe_66() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_totalSupply, uint256 totalSupply) = _readUint0("_totalSupply()");
        if(!ok_totalSupply) return;
        assertTrue(totalSupply < 1e30);
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("_balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("_balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_resetToInitForTest__activate_68() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross_resetToInitForTest__close_69() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross_increaseBonusPool_decreaseBonusPool_70() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_bonusPool, uint256 bonusPool) = _readUint0("bonusPool()");
        if(!ok_bonusPool) return;
        assertTrue(bonusPool < 1e30);
    }

    function invariant_supplement_cross_increaseBonusPool_rewriteBonusPool_71() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_bonusPool, uint256 bonusPool) = _readUint0("bonusPool()");
        if(!ok_bonusPool) return;
        assertTrue(bonusPool < 1e30);
    }

    function invariant_supplement_cross_decreaseBonusPool_increaseBonusPool_72() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_bonusPool, uint256 bonusPool) = _readUint0("bonusPool()");
        if(!ok_bonusPool) return;
        assertTrue(bonusPool < 1e30);
    }

    function invariant_supplement_cross_decreaseBonusPool_rewriteBonusPool_73() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_bonusPool, uint256 bonusPool) = _readUint0("bonusPool()");
        if(!ok_bonusPool) return;
        assertTrue(bonusPool < 1e30);
    }

    function invariant_supplement_cross_rewriteBonusPool_increaseBonusPool_74() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_bonusPool, uint256 bonusPool) = _readUint0("bonusPool()");
        if(!ok_bonusPool) return;
        assertTrue(bonusPool < 1e30);
    }

    function invariant_supplement_cross_rewriteBonusPool_decreaseBonusPool_75() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_bonusPool, uint256 bonusPool) = _readUint0("bonusPool()");
        if(!ok_bonusPool) return;
        assertTrue(bonusPool < 1e30);
    }
}
