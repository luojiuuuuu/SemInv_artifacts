// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/RWAVault_exp.sol";
contract RWAVaultAttackHandler {
    RWAVaultAttack public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(RWAVaultAttack _target, Vm _vm) {
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

    function call_execute() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.execute() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract RWAVaultAttackBaseTest is Test {
    RWAVaultAttack target;
    RWAVaultAttackHandler handler;

    function setUp() public virtual {
        target = new RWAVaultAttack(address(0x1001));
        handler = new RWAVaultAttackHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = handler.call_execute.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract RWAVaultAttackAccountingInvariantTest is RWAVaultAttackBaseTest {
}

contract RWAVaultAttackStateInvariantTest is RWAVaultAttackBaseTest {
}

contract RWAVaultAttackStateTransitionPropertyTest is RWAVaultAttackBaseTest {
}

contract RWAVaultAttackAccessInvariantTest is RWAVaultAttackBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    RWAVaultAttack target;
    constructor(address t) {
        target = RWAVaultAttack(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
