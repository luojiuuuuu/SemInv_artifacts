// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/LiquidityVault.sol";
contract LiquidityVaultHandler {
    LiquidityVault public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(LiquidityVault _target, Vm _vm) {
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

    function call_deposit(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.deposit(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_withdraw(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.withdraw(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract LiquidityVaultBaseTest is Test {
    LiquidityVault target;
    LiquidityVaultHandler handler;

    function setUp() public virtual {
        target = new LiquidityVault(1);
        handler = new LiquidityVaultHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.call_deposit.selector;
        selectors[1] = handler.call_withdraw.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract LiquidityVaultAccountingInvariantTest is LiquidityVaultBaseTest {
}

contract LiquidityVaultStateInvariantTest is LiquidityVaultBaseTest {
}

contract LiquidityVaultStateTransitionPropertyTest is LiquidityVaultBaseTest {
}

contract LiquidityVaultAccessInvariantTest is LiquidityVaultBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    LiquidityVault target;
    constructor(address t) {
        target = LiquidityVault(payable(t));
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

abstract contract LiquidityVaultSemanticSupplementBase is LiquidityVaultBaseTest {
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

contract LiquidityVaultAccountingSupplementTest is LiquidityVaultSemanticSupplementBase {

    function test_supplement_accounting_delta_mismatch_0_withdraw() public {
        // invariant: I1.accounting.delta_consistency
        // precision-loss signal: paired account and aggregate deltas should match
        (bool okDeposit,) = address(target).call(abi.encodeWithSignature("deposit(uint256)", uint256(100)));
        if(!okDeposit) return;
        (bool okUserBefore, uint256 userBefore) = _readUint1Addr("userBalance(address)", address(this));
        (bool okTotalBefore, uint256 totalBefore) = _readUint0("totalLiquidity()");
        if(!okUserBefore || !okTotalBefore) return;
        (bool okAction,) = address(target).call(abi.encodeWithSignature("withdraw(uint256)", uint256(30)));
        if(!okAction) return;
        (bool okUserAfter, uint256 userAfter) = _readUint1Addr("userBalance(address)", address(this));
        (bool okTotalAfter, uint256 totalAfter) = _readUint0("totalLiquidity()");
        if(!okUserAfter || !okTotalAfter) return;
        assertEq(userBefore - userAfter, totalBefore - totalAfter);
    }
}
