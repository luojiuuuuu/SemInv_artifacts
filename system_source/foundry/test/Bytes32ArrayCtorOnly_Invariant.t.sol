// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/Bytes32ArrayCtorOnly.sol";
contract Bytes32ArrayCtorOnlyHandler {
    Bytes32ArrayCtorOnly public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(Bytes32ArrayCtorOnly _target, Vm _vm) {
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
}

contract Bytes32ArrayCtorOnlyBaseTest is Test {
    Bytes32ArrayCtorOnly target;
    Bytes32ArrayCtorOnlyHandler handler;

    function setUp() public virtual {
        bytes32[] memory ctor_initNames = new bytes32[](1);
        ctor_initNames[0] = bytes32(0);
        target = new Bytes32ArrayCtorOnly(ctor_initNames);
        handler = new Bytes32ArrayCtorOnlyHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));
    }
}

contract Bytes32ArrayCtorOnlyAccountingInvariantTest is Bytes32ArrayCtorOnlyBaseTest {
}

contract Bytes32ArrayCtorOnlyStateInvariantTest is Bytes32ArrayCtorOnlyBaseTest {
}

contract Bytes32ArrayCtorOnlyStateTransitionPropertyTest is Bytes32ArrayCtorOnlyBaseTest {
}

contract Bytes32ArrayCtorOnlyAccessInvariantTest is Bytes32ArrayCtorOnlyBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    Bytes32ArrayCtorOnly target;
    constructor(address t) {
        target = Bytes32ArrayCtorOnly(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}