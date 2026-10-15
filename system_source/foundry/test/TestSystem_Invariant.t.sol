// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/TestSystem.sol";
contract TestSystemHandler {
    TestSystem public target;
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
    uint256 public prev_stage;
    uint256 public curr_stage;
    bool public seen_stage;
    bool public entered_terminal_stage;
    uint256 public prev__paused;
    uint256 public curr__paused;
    bool public seen__paused;
    bool public entered_terminal__paused;

    constructor(TestSystem _target, Vm _vm) {
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

    function _snapshot_before_stage() internal {
        if(seen_stage) {
            prev_stage = curr_stage;
        } else {
            prev_stage = uint(target.stage());
            seen_stage = true;
        }
        curr_stage = uint(target.stage());
    }

    function _snapshot_after_stage() internal {
        curr_stage = uint(target.stage());
    }

    function _snapshot_before__paused() internal {
        if(seen__paused) {
            prev__paused = curr__paused;
        } else {
            prev__paused = target.paused() ? 1 : 0;
            seen__paused = true;
        }
        curr__paused = target.paused() ? 1 : 0;
    }

    function _snapshot_after__paused() internal {
        curr__paused = target.paused() ? 1 : 0;
    }

    function call_transferOwnership(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.transferOwnership(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
        _snapshot_after_stage();
        _snapshot_after__paused();
    }

    function call_mint(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
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
        _snapshot_after_stage();
        _snapshot_after__paused();
    }

    function call_burn(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        try target.burn(arg0,arg1) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
        _snapshot_after_stage();
        _snapshot_after__paused();
    }

    function call_transfer(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        try target.transfer(arg0,arg1) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
        _snapshot_after_stage();
        _snapshot_after__paused();
    }

    function call_pause() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.pause() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
        _snapshot_after_stage();
        _snapshot_after__paused();
    }

    function call_unpause() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.unpause() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
        _snapshot_after_stage();
        _snapshot_after__paused();
    }

    function call_activate() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.activate() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
        _snapshot_after_stage();
        _snapshot_after__paused();
    }

    function call_close() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.close() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
        _snapshot_after_stage();
        _snapshot_after__paused();
    }

    function call_nextStage() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_phase();
        _snapshot_before_stage();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.nextStage() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_phase();
        _snapshot_after_stage();
        _snapshot_after__paused();
    }
}

contract TestSystemBaseTest is Test {
    TestSystem target;
    TestSystemHandler handler;

    function setUp() public virtual {
        target = new TestSystem();
        handler = new TestSystemHandler(target, vm);
        vm.deal(address(handler),100 ether);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)",address(handler)));
        ok;
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](9);
        selectors[0] = handler.call_transferOwnership.selector;
        selectors[1] = handler.call_mint.selector;
        selectors[2] = handler.call_burn.selector;
        selectors[3] = handler.call_transfer.selector;
        selectors[4] = handler.call_pause.selector;
        selectors[5] = handler.call_unpause.selector;
        selectors[6] = handler.call_activate.selector;
        selectors[7] = handler.call_close.selector;
        selectors[8] = handler.call_nextStage.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract TestSystemAccountingInvariantTest is TestSystemBaseTest {

    function invariant_accounting_0() public {
        uint sum = 0;
        uint n = handler.actorCount();
        for(uint i=0;i<n;i++){
            address a = handler.actor(i);
            sum += target.balanceOf(a);
        }
        assertEq(sum,target.totalSupply());
    }

    function invariant_eth_conservation_0() public {
        uint n = handler.actorCount();
        uint totalSent = 0;
        for(uint i=0;i<n;i++){
            address a = handler.actor(i);
            totalSent += handler.ethSent(a);
        }
        assertTrue(address(target).balance <= totalSent);
    }
}

contract TestSystemStateInvariantTest is TestSystemBaseTest {


    function invariant_stage_monotonic_uint() public view {
        if(handler.seen_stage()) {
            uint256 prev = handler.prev_stage();
            uint256 curr = handler.curr_stage();
            assertTrue(curr >= prev);
        }
    }

    function invariant_phase_no_rollback_after_terminal() public view {
        if(handler.entered_terminal_phase()) {
            uint256 curr = handler.curr_phase();
            assertTrue(curr == 2);
        }
    }
}

contract TestSystemStateTransitionPropertyTest is TestSystemBaseTest {

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

    function test_property_transition_stage_nextStage() public {
        uint256 beforeV = uint256(target.stage());
        handler.call_nextStage();
        uint256 afterV = uint256(target.stage());
        if(handler.lastCallOk()) {
            assertTrue(afterV == beforeV + 1);
        }
    }

    function test_property_transition__paused_pause() public {
        uint256 beforeV = target.paused() ? 1 : 0;
        handler.call_pause();
        uint256 afterV = target.paused() ? 1 : 0;
        if(handler.lastCallOk()) {
            assertTrue(afterV == 1);
        }
    }

    function test_property_transition__paused_unpause() public {
        uint256 beforeV = target.paused() ? 1 : 0;
        handler.call_unpause();
        uint256 afterV = target.paused() ? 1 : 0;
        if(handler.lastCallOk()) {
            assertTrue(afterV == 0);
        }
    }
}

contract TestSystemAccessInvariantTest is TestSystemBaseTest {

    function invariant_access_transferOwnership() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        assertTrue(!ok);
    }

    function invariant_access_mint() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("mint(address,uint256)", address(0x1001), 1));
        assertTrue(!ok);
    }

    function invariant_access_burn() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burn(address,uint256)", address(0x1001), 1));
        assertTrue(!ok);
    }

    function invariant_access_pause() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("pause()"));
        assertTrue(!ok);
    }

    function invariant_access_unpause() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("unpause()"));
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
}
// replay helper
contract ReplayHelper is Test {
    TestSystem target;
    constructor(address t) {
        target = TestSystem(payable(t));
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

abstract contract TestSystemSemanticSupplementBase is TestSystemBaseTest {
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

contract TestSystemAccessNoninterferenceSupplementTest is TestSystemSemanticSupplementBase {

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

    function test_supplement_access_noninterference_1_mint() public {
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

    function test_supplement_access_noninterference_2_burn() public {
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

    function test_supplement_access_noninterference_3_pause() public {
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

    function test_supplement_access_noninterference_4_unpause() public {
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
}
