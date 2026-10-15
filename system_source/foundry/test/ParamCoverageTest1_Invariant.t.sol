// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/ParamCoverageTest1.sol";
contract ParamCoverageTest1Handler {
    ParamCoverageTest1 public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking
    uint256 public prev_paused;
    uint256 public curr_paused;
    bool public seen_paused;
    bool public entered_terminal_paused;

    constructor(ParamCoverageTest1 _target, Vm _vm) {
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

    function _snapshot_before_paused() internal {
        if(seen_paused) {
            prev_paused = curr_paused;
        } else {
            prev_paused = target.paused() ? 1 : 0;
            seen_paused = true;
        }
        curr_paused = target.paused() ? 1 : 0;
    }

    function _snapshot_after_paused() internal {
        curr_paused = target.paused() ? 1 : 0;
    }

    function call_transferOwnership(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.transferOwnership(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }

    function call_pause() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        try target.pause() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }

    function call_unpause() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        try target.unpause() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }

    function call_setNumbers(uint256[] memory arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        try target.setNumbers(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }

    function call_setAddresses(address[] memory arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        try target.setAddresses(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }

    function call_setNames(bytes32[] memory arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        try target.setNames(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }

    function call_mixedArgs(uint256 arg0,address arg1,bool arg2,bytes32 arg3,string memory arg4,bytes memory arg5) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        try target.mixedArgs(arg0,arg1,arg2,arg3,arg4,arg5) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }

    function call_deposit() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        try target.deposit{value:value}() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }

    function call_withdraw(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_paused();
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.withdraw(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_paused();
    }
}

contract ParamCoverageTest1BaseTest is Test {
    ParamCoverageTest1 target;
    ParamCoverageTest1Handler handler;

    function setUp() public virtual {
        bytes32[] memory ctor_initNames = new bytes32[](1);
        ctor_initNames[0] = bytes32(0);
        target = new ParamCoverageTest1(ctor_initNames);
        handler = new ParamCoverageTest1Handler(target, vm);
        vm.deal(address(handler),100 ether);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)",address(handler)));
        ok;
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](6);
        selectors[0] = handler.call_transferOwnership.selector;
        selectors[1] = handler.call_pause.selector;
        selectors[2] = handler.call_unpause.selector;
        selectors[3] = handler.call_mixedArgs.selector;
        selectors[4] = handler.call_deposit.selector;
        selectors[5] = handler.call_withdraw.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract ParamCoverageTest1AccountingInvariantTest is ParamCoverageTest1BaseTest {
}

contract ParamCoverageTest1StateInvariantTest is ParamCoverageTest1BaseTest {

}

contract ParamCoverageTest1StateTransitionPropertyTest is ParamCoverageTest1BaseTest {

    function test_property_transition_paused_pause() public {
        uint256 beforeV = target.paused() ? 1 : 0;
        handler.call_pause();
        uint256 afterV = target.paused() ? 1 : 0;
        if(handler.lastCallOk()) {
            assertTrue(afterV == 1);
        }
    }

    function test_property_transition_paused_unpause() public {
        uint256 beforeV = target.paused() ? 1 : 0;
        handler.call_unpause();
        uint256 afterV = target.paused() ? 1 : 0;
        if(handler.lastCallOk()) {
            assertTrue(afterV == 0);
        }
    }
}

contract ParamCoverageTest1AccessInvariantTest is ParamCoverageTest1BaseTest {

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
}
// replay helper
contract ReplayHelper is Test {
    ParamCoverageTest1 target;
    constructor(address t) {
        target = ParamCoverageTest1(payable(t));
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
