// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/AROS_exp.sol";
contract AROSAttackImplementationHandler {
    AROSAttackImplementation public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(AROSAttackImplementation _target, Vm _vm) {
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
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        try target.attack{value:value}() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
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

    function call_pancakeV3FlashCallback(uint256 arg0,uint256 arg1,bytes memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        try target.pancakeV3FlashCallback(arg0,arg1,arg2) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_uniswapV3FlashCallback(uint256 arg0,uint256 arg1,bytes memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        try target.uniswapV3FlashCallback(arg0,arg1,arg2) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract AROSAttackImplementationBaseTest is Test {
    AROSAttackImplementation target;
    AROSAttackImplementationHandler handler;

    function setUp() public virtual {
        target = new AROSAttackImplementation();
        handler = new AROSAttackImplementationHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = handler.call_attack.selector;
        selectors[1] = handler.call_onMoolahFlashLoan.selector;
        selectors[2] = handler.call_lockAcquired.selector;
        selectors[3] = handler.call_pancakeV3FlashCallback.selector;
        selectors[4] = handler.call_uniswapV3FlashCallback.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract AROSAttackImplementationAccountingInvariantTest is AROSAttackImplementationBaseTest {
}

contract AROSAttackImplementationStateInvariantTest is AROSAttackImplementationBaseTest {
}

contract AROSAttackImplementationStateTransitionPropertyTest is AROSAttackImplementationBaseTest {
}

contract AROSAttackImplementationAccessInvariantTest is AROSAttackImplementationBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    AROSAttackImplementation target;
    constructor(address t) {
        target = AROSAttackImplementation(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
