// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/AztecEscapeHatch_exp.sol";
contract AztecEscapeHatch_expHandler {
    AztecEscapeHatch_exp public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(AztecEscapeHatch_exp _target, Vm _vm) {
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

    function call_testExploit_ETH() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.testExploit_ETH() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_testExploit_DAI() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.testExploit_DAI() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_testExploit_renBTC() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        try target.testExploit_renBTC() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract AztecEscapeHatch_expBaseTest is Test {
    AztecEscapeHatch_exp target;
    AztecEscapeHatch_expHandler handler;

    function setUp() public virtual {
        target = new AztecEscapeHatch_exp();
        handler = new AztecEscapeHatch_expHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = handler.call_testExploit_ETH.selector;
        selectors[1] = handler.call_testExploit_DAI.selector;
        selectors[2] = handler.call_testExploit_renBTC.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract AztecEscapeHatch_expAccountingInvariantTest is AztecEscapeHatch_expBaseTest {
}

contract AztecEscapeHatch_expStateInvariantTest is AztecEscapeHatch_expBaseTest {
}

contract AztecEscapeHatch_expStateTransitionPropertyTest is AztecEscapeHatch_expBaseTest {
}

contract AztecEscapeHatch_expAccessInvariantTest is AztecEscapeHatch_expBaseTest {
}
// replay helper
contract ReplayHelper is Test {
    AztecEscapeHatch_exp target;
    constructor(address t) {
        target = AztecEscapeHatch_exp(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}
