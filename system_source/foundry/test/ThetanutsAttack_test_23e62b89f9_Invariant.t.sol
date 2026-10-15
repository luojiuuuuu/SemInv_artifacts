// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/Thetanuts_exp.sol";
contract ThetanutsAttackHandler {
    ThetanutsAttack public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(ThetanutsAttack _target, Vm _vm) {
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

    function call_run() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.run() {
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

contract ThetanutsAttackBaseTest is Test {
    ThetanutsAttack target;
    ThetanutsAttackHandler handler;

    function setUp() public virtual {
        target = new ThetanutsAttack(address(0x1001));
        handler = new ThetanutsAttackHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = handler.call_run.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract ThetanutsAttackAccountingInvariantTest is ThetanutsAttackBaseTest {
}

contract ThetanutsAttackStateInvariantTest is ThetanutsAttackBaseTest {
}

contract ThetanutsAttackStateTransitionPropertyTest is ThetanutsAttackBaseTest {
}

contract ThetanutsAttackAccessInvariantTest is ThetanutsAttackBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    ThetanutsAttack target;
    constructor(address t) {
        target = ThetanutsAttack(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
