// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/Moonwell_exp.sol";
contract AttackContractHandler {
    AttackContract public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(AttackContract _target, Vm _vm) {
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

    function call_start() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.start() {
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
}

contract AttackContractBaseTest is Test {
    AttackContract target;
    AttackContractHandler handler;

    function setUp() public virtual {
        target = new AttackContract(address(0x1001), address(0x1001), address(0x1001), address(0x1001), address(0x1001), address(0x1001));
        handler = new AttackContractHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = handler.call_start.selector;
        selectors[1] = handler.call_uniswapV3FlashCallback.selector;
        selectors[2] = handler.call_uniswapV3SwapCallback.selector;
        selectors[3] = handler.call_receive.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract AttackContractAccountingInvariantTest is AttackContractBaseTest {
}

contract AttackContractStateInvariantTest is AttackContractBaseTest {
}

contract AttackContractStateTransitionPropertyTest is AttackContractBaseTest {
}

contract AttackContractAccessInvariantTest is AttackContractBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    AttackContract target;
    constructor(address t) {
        target = AttackContract(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
