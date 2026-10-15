// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/ThetanutsFi_exp.sol";
contract ThetanutsAttackerHandler {
    ThetanutsAttacker public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(ThetanutsAttacker _target, Vm _vm) {
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

    function call_attack() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.attack() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_executeOperation(address[] memory arg0,uint256[] memory arg1,uint256[] memory arg2,address arg3,bytes memory arg4) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg3 = actors[uint256(keccak256(abi.encodePacked(arg3))) % actors.length];
        try target.executeOperation(arg0,arg1,arg2,arg3,arg4) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract ThetanutsAttackerBaseTest is Test {
    ThetanutsAttacker target;
    ThetanutsAttackerHandler handler;

    function setUp() public virtual {
        target = new ThetanutsAttacker();
        handler = new ThetanutsAttackerHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = handler.call_attack.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract ThetanutsAttackerAccountingInvariantTest is ThetanutsAttackerBaseTest {
}

contract ThetanutsAttackerStateInvariantTest is ThetanutsAttackerBaseTest {
}

contract ThetanutsAttackerStateTransitionPropertyTest is ThetanutsAttackerBaseTest {
}

contract ThetanutsAttackerAccessInvariantTest is ThetanutsAttackerBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    ThetanutsAttacker target;
    constructor(address t) {
        target = ThetanutsAttacker(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
