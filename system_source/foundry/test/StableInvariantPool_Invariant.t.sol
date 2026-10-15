// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/StableInvariantPool.sol";
contract StableInvariantPoolHandler {
    StableInvariantPool public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(StableInvariantPool _target, Vm _vm) {
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

    function call_swap(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        try target.swap(arg0,arg1) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract StableInvariantPoolBaseTest is Test {
    StableInvariantPool target;
    StableInvariantPoolHandler handler;

    function setUp() public virtual {
        target = new StableInvariantPool(1);
        handler = new StableInvariantPoolHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = handler.call_swap.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract StableInvariantPoolAccountingInvariantTest is StableInvariantPoolBaseTest {
}

contract StableInvariantPoolStateInvariantTest is StableInvariantPoolBaseTest {
}

contract StableInvariantPoolStateTransitionPropertyTest is StableInvariantPoolBaseTest {
}

contract StableInvariantPoolAccessInvariantTest is StableInvariantPoolBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    StableInvariantPool target;
    constructor(address t) {
        target = StableInvariantPool(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-invariant tests generated separately from the main invariant file.
// These contracts are safe to edit, run, or disable without changing the baseline invariant tests.

abstract contract StableInvariantPoolSemanticSupplementBase is StableInvariantPoolBaseTest {
    function _readUint0(string memory sig) internal view returns (bool, uint256) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig));
        if(!ok || data.length < 32) return (false, 0);
        return (true, abi.decode(data, (uint256)));
    }

    function _readAddress0(string memory sig) internal view returns (bool, address) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig));
        if(!ok || data.length < 32) return (false, address(0));
        return (true, abi.decode(data, (address)));
    }

    function _readUint1Addr(string memory sig, address a) internal view returns (bool, uint256) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig, a));
        if(!ok || data.length < 32) return (false, 0);
        return (true, abi.decode(data, (uint256)));
    }
}

contract StableInvariantPoolRoundingDriftSupplementTest is StableInvariantPoolSemanticSupplementBase {

    function test_supplement_swap_rounding_drift_positive_output() public {
        // invariant: I1.accounting.precision_loss
        // weak AMM oracle: a positive swap input should not silently round to zero output while mutating invariant state
        (bool okBefore, uint256 beforeInvariant) = _readUint0("invariantD()");
        if(!okBefore || beforeInvariant == 0) return;
        (bool okSwap, bytes memory data) = address(target).call(abi.encodeWithSignature("swap(address,uint256)", address(0xBEEF), uint256(2)));
        if(!okSwap || data.length < 32) return;
        uint256 amountOut = abi.decode(data, (uint256));
        (bool okAfter, uint256 afterInvariant) = _readUint0("invariantD()");
        if(!okAfter || afterInvariant == beforeInvariant) return;
        assertTrue(amountOut > 0);
    }
}
