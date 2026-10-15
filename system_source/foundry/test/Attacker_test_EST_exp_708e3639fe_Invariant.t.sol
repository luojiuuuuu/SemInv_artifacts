// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/EST_exp.sol";
contract AttackerHandler {
    Attacker public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(Attacker _target, Vm _vm) {
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

    function call_start(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.start(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract AttackerBaseTest is Test {
    Attacker target;
    AttackerHandler handler;

    function setUp() public virtual {
        target = new Attacker();
        handler = new AttackerHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = handler.call_onMoolahFlashLoan.selector;
        selectors[1] = handler.call_receive.selector;
        selectors[2] = handler.call_start.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract AttackerAccountingInvariantTest is AttackerBaseTest {
}

contract AttackerStateInvariantTest is AttackerBaseTest {
}

contract AttackerStateTransitionPropertyTest is AttackerBaseTest {
}

contract AttackerAccessInvariantTest is AttackerBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    Attacker target;
    constructor(address t) {
        target = Attacker(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
