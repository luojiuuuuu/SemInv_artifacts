// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/ValidationTarget.sol";
contract ValidationTargetHandler {
    ValidationTarget public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking
    uint256 public prev_stage;
    uint256 public curr_stage;
    bool public seen_stage;
    bool public entered_terminal_stage;
    uint256 public prev_phase;
    uint256 public curr_phase;
    bool public seen_phase;
    bool public entered_terminal_phase;
    uint256 public prev__paused;
    uint256 public curr__paused;
    bool public seen__paused;
    bool public entered_terminal__paused;

    constructor(ValidationTarget _target, Vm _vm) {
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
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.transferOwnership(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_pause() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.pause() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_unpause() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.unpause() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_mint(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
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
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_burn(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
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
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_transfer(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
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
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_activate() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.activate() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_close() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.close() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_nextStage() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.nextStage() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_nextStageByAssign() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.nextStageByAssign() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_nextStageUnary() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.nextStageUnary() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_rollbackStage() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.rollbackStage() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_emergencyPause() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.emergencyPause() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_resume() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.resume() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_addWhitelist(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.addWhitelist(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_removeWhitelist(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.removeWhitelist(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_forceNextStage() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.forceNextStage() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_mintBonus(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        try target.mintBonus(arg0,arg1) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_burnBonus(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        try target.burnBonus(arg0,arg1) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_redistribute(address arg0,address arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        try target.redistribute(arg0,arg1,arg2) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_resetToInitForTest() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        try target.resetToInitForTest() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_increaseBonusPool(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.increaseBonusPool(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_decreaseBonusPool(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.decreaseBonusPool(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_rewriteBonusPool(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.rewriteBonusPool(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }

    function call_wipeAccount(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_stage();
        _snapshot_before_phase();
        _snapshot_before__paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.wipeAccount(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_stage();
        _snapshot_after_phase();
        _snapshot_after__paused();
    }
}

contract ValidationTargetBaseTest is Test {
    ValidationTarget target;
    ValidationTargetHandler handler;

    function setUp() public virtual {
        target = new ValidationTarget();
        handler = new ValidationTargetHandler(target, vm);
        vm.deal(address(handler),100 ether);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)",address(handler)));
        ok;
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](25);
        selectors[0] = handler.call_transferOwnership.selector;
        selectors[1] = handler.call_pause.selector;
        selectors[2] = handler.call_unpause.selector;
        selectors[3] = handler.call_mint.selector;
        selectors[4] = handler.call_burn.selector;
        selectors[5] = handler.call_transfer.selector;
        selectors[6] = handler.call_activate.selector;
        selectors[7] = handler.call_close.selector;
        selectors[8] = handler.call_nextStage.selector;
        selectors[9] = handler.call_nextStageByAssign.selector;
        selectors[10] = handler.call_nextStageUnary.selector;
        selectors[11] = handler.call_rollbackStage.selector;
        selectors[12] = handler.call_emergencyPause.selector;
        selectors[13] = handler.call_resume.selector;
        selectors[14] = handler.call_addWhitelist.selector;
        selectors[15] = handler.call_removeWhitelist.selector;
        selectors[16] = handler.call_forceNextStage.selector;
        selectors[17] = handler.call_mintBonus.selector;
        selectors[18] = handler.call_burnBonus.selector;
        selectors[19] = handler.call_redistribute.selector;
        selectors[20] = handler.call_resetToInitForTest.selector;
        selectors[21] = handler.call_increaseBonusPool.selector;
        selectors[22] = handler.call_decreaseBonusPool.selector;
        selectors[23] = handler.call_rewriteBonusPool.selector;
        selectors[24] = handler.call_wipeAccount.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract ValidationTargetAccountingInvariantTest is ValidationTargetBaseTest {

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

contract ValidationTargetStateInvariantTest is ValidationTargetBaseTest {


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

contract ValidationTargetStateTransitionPropertyTest is ValidationTargetBaseTest {

    function test_property_transition_stage_nextStage() public {
        uint256 beforeV = uint256(target.stage());
        handler.call_nextStage();
        uint256 afterV = uint256(target.stage());
        if(handler.lastCallOk()) {
            assertTrue(afterV == beforeV + 1);
        }
    }

    function test_property_transition_stage_nextStageByAssign() public {
        uint256 beforeV = uint256(target.stage());
        handler.call_nextStageByAssign();
        uint256 afterV = uint256(target.stage());
        if(handler.lastCallOk()) {
            assertTrue(afterV == beforeV + 1);
        }
    }

    function test_property_transition_stage_nextStageUnary() public {
        uint256 beforeV = uint256(target.stage());
        handler.call_nextStageUnary();
        uint256 afterV = uint256(target.stage());
        if(handler.lastCallOk()) {
            assertTrue(afterV == beforeV + 1);
        }
    }

    function test_property_transition_stage_rollbackStage() public {
        uint256 beforeV = uint256(target.stage());
        handler.call_rollbackStage();
        uint256 afterV = uint256(target.stage());
        if(handler.lastCallOk()) {
            assertTrue(afterV + 1 == beforeV);
        }
    }

    function test_property_transition_stage_forceNextStage() public {
        uint256 beforeV = uint256(target.stage());
        handler.call_forceNextStage();
        uint256 afterV = uint256(target.stage());
        if(handler.lastCallOk()) {
            assertTrue(afterV == beforeV + 1);
        }
    }

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

    function test_property_transition_phase_resetToInitForTest() public {
        uint256 beforeV = uint256(target.phase());
        handler.call_resetToInitForTest();
        uint256 afterV = uint256(target.phase());
        if(handler.lastCallOk()) {
            assertTrue(afterV == 0);
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

    function test_property_transition__paused_emergencyPause() public {
        uint256 beforeV = target.paused() ? 1 : 0;
        handler.call_emergencyPause();
        uint256 afterV = target.paused() ? 1 : 0;
        if(handler.lastCallOk()) {
            assertTrue(afterV == 1);
        }
    }

    function test_property_transition__paused_resume() public {
        uint256 beforeV = target.paused() ? 1 : 0;
        handler.call_resume();
        uint256 afterV = target.paused() ? 1 : 0;
        if(handler.lastCallOk()) {
            assertTrue(afterV == 0);
        }
    }
}

contract ValidationTargetAccessInvariantTest is ValidationTargetBaseTest {

    function invariant_access_transferOwnership() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
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

    function invariant_access_rollbackStage() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("rollbackStage()"));
        assertTrue(!ok);
    }

    function invariant_access_emergencyPause() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("emergencyPause()"));
        assertTrue(!ok);
    }

    function invariant_access_resume() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("resume()"));
        assertTrue(!ok);
    }

    function invariant_access_addWhitelist() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("addWhitelist(address)", address(0x1001)));
        assertTrue(!ok);
    }

    function invariant_access_removeWhitelist() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("removeWhitelist(address)", address(0x1001)));
        assertTrue(!ok);
    }

    function invariant_access_mintBonus() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("mintBonus(address,uint256)", address(0x1001), 1));
        assertTrue(!ok);
    }

    function invariant_access_burnBonus() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnBonus(address,uint256)", address(0x1001), 1));
        assertTrue(!ok);
    }

    function invariant_access_resetToInitForTest() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("resetToInitForTest()"));
        assertTrue(!ok);
    }
}
// replay helper
contract ReplayHelper is Test {
    ValidationTarget target;
    constructor(address t) {
        target = ValidationTarget(payable(t));
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
