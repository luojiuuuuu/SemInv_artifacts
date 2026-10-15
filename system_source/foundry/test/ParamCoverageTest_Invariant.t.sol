// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/ParamCoverageTest.sol";
contract ParamCoverageTestHandler {
    ParamCoverageTest public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking
    uint256 public prev_lastB;
    uint256 public curr_lastB;
    bool public seen_lastB;
    bool public entered_terminal_lastB;

    constructor(ParamCoverageTest _target, Vm _vm) {
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

    function _snapshot_before_lastB() internal {
        if(seen_lastB) {
            prev_lastB = curr_lastB;
        } else {
            prev_lastB = target.lastB() ? 1 : 0;
            seen_lastB = true;
        }
        curr_lastB = target.lastB() ? 1 : 0;
    }

    function _snapshot_after_lastB() internal {
        curr_lastB = target.lastB() ? 1 : 0;
    }

    function call_setUintArray(uint256[] memory arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_lastB();
        vm.startPrank(sender);
        try target.setUintArray(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_lastB();
    }

    function call_setBytes32Array(bytes32[] memory arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_lastB();
        vm.startPrank(sender);
        try target.setBytes32Array(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_lastB();
    }

    function call_setTuple(uint256 arg0,bool arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_lastB();
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.setTuple(arg0,arg1) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_lastB();
    }
}

contract ParamCoverageTestBaseTest is Test {
    ParamCoverageTest target;
    ParamCoverageTestHandler handler;

    function setUp() public virtual {
        ParamCoverageTest.Pair[] memory ctor_initPairs = new ParamCoverageTest.Pair[](1);
        ctor_initPairs[0] = ParamCoverageTest.Pair(1, false);
        target = new ParamCoverageTest(ctor_initPairs);
        handler = new ParamCoverageTestHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = handler.call_setTuple.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract ParamCoverageTestAccountingInvariantTest is ParamCoverageTestBaseTest {
}

contract ParamCoverageTestStateInvariantTest is ParamCoverageTestBaseTest {

}

contract ParamCoverageTestStateTransitionPropertyTest is ParamCoverageTestBaseTest {

    function test_property_transition_lastB_setTuple() public {
        uint256 beforeV = target.lastB() ? 1 : 0;
        handler.call_setTuple(1, false);
        uint256 afterV = target.lastB() ? 1 : 0;
    }
}

contract ParamCoverageTestAccessInvariantTest is ParamCoverageTestBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    ParamCoverageTest target;
    constructor(address t) {
        target = ParamCoverageTest(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}