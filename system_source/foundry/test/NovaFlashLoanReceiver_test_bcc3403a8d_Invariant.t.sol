// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/NovaBox_exp.sol";
contract NovaFlashLoanReceiverHandler {
    NovaFlashLoanReceiver public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(NovaFlashLoanReceiver _target, Vm _vm) {
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

    function call_startFlashLoan() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.startFlashLoan() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_executeOperation(address arg0,uint256 arg1,uint256 arg2,address arg3,bytes memory arg4) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = actors[uint256(keccak256(abi.encodePacked(arg3))) % actors.length];
        try target.executeOperation(arg0,arg1,arg2,arg3,arg4) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_fundHelperWithNova() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.fundHelperWithNova() {
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

contract NovaFlashLoanReceiverBaseTest is Test {
    NovaFlashLoanReceiver target;
    NovaFlashLoanReceiverHandler handler;

    function setUp() public virtual {
        target = new NovaFlashLoanReceiver(address(0x1001), 1);
        handler = new NovaFlashLoanReceiverHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = handler.call_startFlashLoan.selector;
        selectors[1] = handler.call_executeOperation.selector;
        selectors[2] = handler.call_fundHelperWithNova.selector;
        selectors[3] = handler.call_receive.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract NovaFlashLoanReceiverAccountingInvariantTest is NovaFlashLoanReceiverBaseTest {
}

contract NovaFlashLoanReceiverStateInvariantTest is NovaFlashLoanReceiverBaseTest {
}

contract NovaFlashLoanReceiverStateTransitionPropertyTest is NovaFlashLoanReceiverBaseTest {
}

contract NovaFlashLoanReceiverAccessInvariantTest is NovaFlashLoanReceiverBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    NovaFlashLoanReceiver target;
    constructor(address t) {
        target = NovaFlashLoanReceiver(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
