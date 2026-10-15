// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/LBP_exp.sol";
contract LBPAttackHandler {
    LBPAttack public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(LBPAttack _target, Vm _vm) {
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

    function call_onMoolahFlashLoan(uint256 arg0,bytes memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.onMoolahFlashLoan(arg0,arg1) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_lockAcquired(bytes memory arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.lockAcquired(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_receive() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call{value:value}("");
        lastCallOk = ok;
        vm.stopPrank();
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
}

contract LBPAttackBaseTest is Test {
    LBPAttack target;
    LBPAttackHandler handler;

    function setUp() public virtual {
        target = new LBPAttack();
        handler = new LBPAttackHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = handler.call_onMoolahFlashLoan.selector;
        selectors[1] = handler.call_lockAcquired.selector;
        selectors[2] = handler.call_receive.selector;
        selectors[3] = handler.call_run.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract LBPAttackAccountingInvariantTest is LBPAttackBaseTest {
}

contract LBPAttackStateInvariantTest is LBPAttackBaseTest {
}

contract LBPAttackStateTransitionPropertyTest is LBPAttackBaseTest {
}

contract LBPAttackAccessInvariantTest is LBPAttackBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    LBPAttack target;
    constructor(address t) {
        target = LBPAttack(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
