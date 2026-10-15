// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/ResearchTarget.sol";
contract ResearchTargetHandler {
    ResearchTarget public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking
    uint256 public prev_phase;
    uint256 public curr_phase;
    bool public seen_phase;
    bool public entered_terminal_phase;

    constructor(ResearchTarget _target, Vm _vm) {
        target = _target;
        vm = _vm;

        actors.push(address(0x100));
        actors.push(address(0x200));
        actors.push(address(0x300));
        actors.push(address(0x400));
        actors.push(address(this));

        for(uint i=0;i<actors.length;i++){
            vm.deal(actors[i],100 ether);
        }
    }

    function actorCount() public view returns(uint){
        return actors.length;
    }

    function actor(uint i) public view returns(address){
        return actors[i];
    }

    function _snapshot_before_phase() internal {
        if(seen_phase) {
            prev_phase = curr_phase;
        } else {
            prev_phase = uint(target.phase());
            seen_phase = true;
        }
        curr_phase = uint(target.phase());
    }

    function _snapshot_after_phase() internal {
        curr_phase = uint(target.phase());
        if(curr_phase == 2) entered_terminal_phase = true;
    }

    function call_deposit() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_phase();
        vm.startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        try target.deposit{value:value}() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
    }

    function call_withdraw(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_phase();
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.withdraw(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
    }

    function call_mint(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        try target.mint(arg0,arg1) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
    }

    function call_transferOwnership(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.transferOwnership(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
    }

    function call_activate() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        vm.startPrank(sender);
        try target.activate() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
    }

    function call_close() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        vm.startPrank(sender);
        try target.close() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
    }

    function call_reset() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        vm.startPrank(sender);
        try target.reset() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
    }

    function call_receive() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_phase();
        vm.startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call{value:value}("");
        lastCallOk = ok;
        vm.stopPrank();
        _snapshot_after_phase();
    }
}

contract ResearchTargetBaseTest is Test {
    ResearchTarget target;
    ResearchTargetHandler handler;

    function setUp() public virtual {
        target = new ResearchTarget();
        handler = new ResearchTargetHandler(target, vm);
        vm.deal(address(handler),100 ether);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)",address(handler)));
        ok;
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](8);
        selectors[0] = handler.call_deposit.selector;
        selectors[1] = handler.call_withdraw.selector;
        selectors[2] = handler.call_mint.selector;
        selectors[3] = handler.call_transferOwnership.selector;
        selectors[4] = handler.call_activate.selector;
        selectors[5] = handler.call_close.selector;
        selectors[6] = handler.call_reset.selector;
        selectors[7] = handler.call_receive.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract ResearchTargetAccountingInvariantTest is ResearchTargetBaseTest {
}

contract ResearchTargetAccountingAnomalyTest is ResearchTargetBaseTest {
}

contract ResearchTargetStateInvariantTest is ResearchTargetBaseTest {

    function invariant_phase_no_rollback_after_terminal() public view {
        if(handler.entered_terminal_phase()) {
            uint256 curr = handler.curr_phase();
            assertTrue(curr == 2);
        }
    }
}

contract ResearchTargetStateTransitionPropertyTest is ResearchTargetBaseTest {

    function test_property_transition_phase_activate() public {
        uint256 beforeV = uint256(target.phase());
        handler.call_activate();
        uint256 afterV = uint256(target.phase());
        if(beforeV == 0 && handler.lastCallOk()) {
            assertTrue(afterV == 1);
        }
    }

    function test_property_transition_phase_close() public {
        uint256 beforeV = uint256(target.phase());
        handler.call_close();
        uint256 afterV = uint256(target.phase());
        if(beforeV == 1 && handler.lastCallOk()) {
            assertTrue(afterV == 2);
        }
    }

    function test_property_transition_phase_reset() public {
        uint256 beforeV = uint256(target.phase());
        handler.call_reset();
        uint256 afterV = uint256(target.phase());
        if(handler.lastCallOk()) {
            assertTrue(afterV == 0);
        }
    }
}

contract ResearchTargetAccessInvariantTest is ResearchTargetBaseTest {

    function invariant_access_mint() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("mint(address,uint256)", address(0x1001), 1));
        assertTrue(!ok);
    }

    function invariant_access_transferOwnership() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        assertTrue(!ok);
    }

    function invariant_access_activate() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activate()"));
        assertTrue(!ok);
    }

    function invariant_access_close() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("close()"));
        assertTrue(!ok);
    }

    function invariant_access_reset() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("reset()"));
        assertTrue(!ok);
    }
}
// replay helper
contract ReplayHelper is Test {
    ResearchTarget target;
    constructor(address t) {
        target = ResearchTarget(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
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
