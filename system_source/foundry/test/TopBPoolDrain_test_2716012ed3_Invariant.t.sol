// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/TOPBPool_exp.sol";
contract TopBPoolDrainHandler {
    TopBPoolDrain public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(TopBPoolDrain _target, Vm _vm) {
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

    function call_drain() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.drain() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract TopBPoolDrainBaseTest is Test {
    TopBPoolDrain target;
    TopBPoolDrainHandler handler;

    function setUp() public virtual {
        target = new TopBPoolDrain();
        handler = new TopBPoolDrainHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = handler.call_drain.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract TopBPoolDrainAccountingInvariantTest is TopBPoolDrainBaseTest {
}

contract TopBPoolDrainStateInvariantTest is TopBPoolDrainBaseTest {
}

contract TopBPoolDrainStateTransitionPropertyTest is TopBPoolDrainBaseTest {
}

contract TopBPoolDrainAccessInvariantTest is TopBPoolDrainBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    TopBPoolDrain target;
    constructor(address t) {
        target = TopBPoolDrain(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
