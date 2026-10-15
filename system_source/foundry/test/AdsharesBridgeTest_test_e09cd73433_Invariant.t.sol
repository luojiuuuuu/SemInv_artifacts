// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/AdsharesBridge_exp.sol";
contract AdsharesBridgeTestHandler {
    AdsharesBridgeTest public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(AdsharesBridgeTest _target, Vm _vm) {
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

    function call_setUp() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.setUp() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_testExploit() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.testExploit() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract AdsharesBridgeTestBaseTest is Test {
    AdsharesBridgeTest target;
    AdsharesBridgeTestHandler handler;

    function setUp() public virtual {
        target = new AdsharesBridgeTest();
        handler = new AdsharesBridgeTestHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.call_setUp.selector;
        selectors[1] = handler.call_testExploit.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract AdsharesBridgeTestAccountingInvariantTest is AdsharesBridgeTestBaseTest {
}

contract AdsharesBridgeTestStateInvariantTest is AdsharesBridgeTestBaseTest {
}

contract AdsharesBridgeTestStateTransitionPropertyTest is AdsharesBridgeTestBaseTest {
}

contract AdsharesBridgeTestAccessInvariantTest is AdsharesBridgeTestBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    AdsharesBridgeTest target;
    constructor(address t) {
        target = AdsharesBridgeTest(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
