// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/TesseraSwap_exp.sol";
contract TesseraSwapAttackerHandler {
    TesseraSwapAttacker public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(TesseraSwapAttacker _target, Vm _vm) {
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

    function call_executeAttack() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.executeAttack() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_tesseraSwapCallback(int256 arg0,int256 arg1,bytes memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = int256(int256(arg0) % int256(1000));
        arg1 = int256(int256(arg1) % int256(1000));
        try target.tesseraSwapCallback(arg0,arg1,arg2) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_uniswapV3SwapCallback(int256 arg0,int256 arg1,bytes memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = int256(int256(arg0) % int256(1000));
        arg1 = int256(int256(arg1) % int256(1000));
        try target.uniswapV3SwapCallback(arg0,arg1,arg2) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract TesseraSwapAttackerBaseTest is Test {
    TesseraSwapAttacker target;
    TesseraSwapAttackerHandler handler;

    function setUp() public virtual {
        target = new TesseraSwapAttacker();
        handler = new TesseraSwapAttackerHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = handler.call_executeAttack.selector;
        selectors[1] = handler.call_tesseraSwapCallback.selector;
        selectors[2] = handler.call_uniswapV3SwapCallback.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract TesseraSwapAttackerAccountingInvariantTest is TesseraSwapAttackerBaseTest {
}

contract TesseraSwapAttackerStateInvariantTest is TesseraSwapAttackerBaseTest {
}

contract TesseraSwapAttackerStateTransitionPropertyTest is TesseraSwapAttackerBaseTest {
}

contract TesseraSwapAttackerAccessInvariantTest is TesseraSwapAttackerBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    TesseraSwapAttacker target;
    constructor(address t) {
        target = TesseraSwapAttacker(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
