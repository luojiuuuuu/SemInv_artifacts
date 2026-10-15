// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "./ResearchTarget_Invariant.t.sol";

// Supplemental semantic-invariant tests generated separately from the main invariant file.
// These contracts are safe to edit, run, or disable without changing the baseline invariant tests.

abstract contract ResearchTargetSemanticSupplementBase is ResearchTargetBaseTest {
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

contract ResearchTargetAccountingSupplementTest is ResearchTargetSemanticSupplementBase {

    function test_supplement_accounting_delta_0_mint() public {
        // invariant: I1.accounting.delta_consistency
        // anomaly reason: updates mapping but not paired supply
        handler.call_mint(address(0x1001), 1);
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            (bool okBal, uint256 balValue) = _readUint1Addr("balances(address)", a);
            if(!okBal) return;
            sum += balValue;
        }
        (bool okSupply, uint256 supplyValue) = _readUint0("totalSupply()");
        if(!okSupply) return;
        assertEq(sum, supplyValue);
    }

    function invariant_supplement_accounting_sum_0() public view {
        // invariant: I1.accounting.sum_supply_consistency
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            (bool okBal, uint256 balValue) = _readUint1Addr("balances(address)", a);
            if(!okBal) return;
            sum += balValue;
        }
        (bool okSupply, uint256 supplyValue) = _readUint0("totalSupply()");
        if(!okSupply) return;
        assertTrue(sum <= supplyValue);
    }
}

contract ResearchTargetAccessNoninterferenceSupplementTest is ResearchTargetSemanticSupplementBase {

    function test_supplement_access_noninterference_0_mint() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("totalSupply()");
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("mint(address,uint256)", address(0x1001), 1));
        ok;
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_1_transferOwnership() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("totalSupply()");
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        ok;
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_2_activate() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("totalSupply()");
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activate()"));
        ok;
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_3_close() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("totalSupply()");
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("close()"));
        ok;
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }

    function test_supplement_access_noninterference_4_reset() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_totalSupply, uint256 pre_totalSupply) = _readUint0("totalSupply()");
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        (bool okPre_phase, uint256 pre_phase) = _readUint0("phase()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("reset()"));
        ok;
        (bool okPost_totalSupply, uint256 post_totalSupply) = _readUint0("totalSupply()");
        if(okPre_totalSupply && okPost_totalSupply) assertEq(post_totalSupply, pre_totalSupply);
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
        (bool okPost_phase, uint256 post_phase) = _readUint0("phase()");
        if(okPre_phase && okPost_phase) assertEq(post_phase, pre_phase);
    }
}

contract ResearchTargetTerminalSupplementTest is ResearchTargetSemanticSupplementBase {

    function invariant_supplement_phase_terminal_absorbing() public view {
        // invariant: I3.state.terminal_absorbing
        if(handler.entered_terminal_phase()) {
            uint256 curr = handler.curr_phase();
            assertTrue(curr == 2);
        }
    }
}

contract ResearchTargetCrossRelationSupplementTest is ResearchTargetSemanticSupplementBase {

    function invariant_supplement_cross_deposit_mint_1() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_withdraw_mint_3() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_mint_deposit_4() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_mint_withdraw_5() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_balances_0, uint256 balances_0) = _readUint1Addr("balances(address)", handler.actor(0));
        (bool ok_balances_1, uint256 balances_1) = _readUint1Addr("balances(address)", handler.actor(1));
        if(!ok_balances_0 || !ok_balances_1) return;
        assertTrue(balances_0 <= 1e30 && balances_1 <= 1e30);
    }

    function invariant_supplement_cross_activate_close_6() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross_activate_reset_7() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross_close_activate_8() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross_close_reset_9() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross_reset_activate_10() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }

    function invariant_supplement_cross_reset_close_11() public view {
        // invariant: I4.transaction.write_read_consistency
        (bool ok_phase, uint256 phase) = _readUint0("phase()");
        if(!ok_phase) return;
        assertTrue(phase < 3);
    }
}
