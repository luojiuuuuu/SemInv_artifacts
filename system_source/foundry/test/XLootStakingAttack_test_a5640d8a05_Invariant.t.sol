// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/XLootStaking_exp.sol";
contract XLootStakingAttackHandler {
    XLootStakingAttack public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(XLootStakingAttack _target, Vm _vm) {
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

    function call_receiveFlashLoan(address[] memory arg0,uint256[] memory arg1,uint256[] memory arg2,bytes memory arg3) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.receiveFlashLoan(arg0,arg1,arg2,arg3) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract XLootStakingAttackBaseTest is Test {
    XLootStakingAttack target;
    XLootStakingAttackHandler handler;

    function setUp() public virtual {
        uint256[] memory ctor_baseIds = new uint256[](1);
        ctor_baseIds[0] = 1;
        target = new XLootStakingAttack(address(0x1001), ctor_baseIds);
        handler = new XLootStakingAttackHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.call_receive.selector;
        selectors[1] = handler.call_run.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract XLootStakingAttackAccountingInvariantTest is XLootStakingAttackBaseTest {
}

contract XLootStakingAttackStateInvariantTest is XLootStakingAttackBaseTest {
}

contract XLootStakingAttackStateTransitionPropertyTest is XLootStakingAttackBaseTest {
}

contract XLootStakingAttackAccessInvariantTest is XLootStakingAttackBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    XLootStakingAttack target;
    constructor(address t) {
        target = XLootStakingAttack(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
