// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_49.sol";

interface Vm {
    function deal(address who, uint256 newBalance) external;
    function startPrank(address) external;
    function stopPrank() external;
}

contract LegacyCheatcodes {
    function _vm() internal pure returns (Vm) {
        return Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    }
}

contract SimpleAssert {
    function _assertTrue(bool x) internal pure { require(x, "assertTrue failed"); }
    function _assertEq(uint256 a, uint256 b) internal pure { require(a == b, "assertEq failed"); }
}
contract TAMCHandler is LegacyCheatcodes {
    TAMC public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(TAMC _target) public {
        target = _target;

        actors.push(address(0x100));
        actors.push(address(0x200));
        actors.push(address(0x300));
        actors.push(address(0x400));
        actors.push(address(this));

        for(uint i=0;i<actors.length;i++){
            _vm().deal(actors[i],100 ether);
        }
    }

    function actorCount() public view returns(uint){
        return actors.length;
    }

    function actor(uint i) public view returns(address){
        return actors[i];
    }

    function call_sendToWinner_unchk8() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk8()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk39(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk39(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_uncheck36(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_uncheck36(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_unchk35(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_unchk35(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawLeftOver_unchk45() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk45()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_UncheckedExternalCall_unchk40() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("UncheckedExternalCall_unchk40()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawLeftOver_unchk33() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk33()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callnotchecked_unchk13(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("callnotchecked_unchk13(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendToWinner_unchk44() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk44()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_approve(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("approve(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk27(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk27(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferFrom(address arg0,address arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk31() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk31()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract TAMCBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    TAMC target;
    TAMCHandler handler;

    function setUp() public {
        target = new TAMC();
        handler = new TAMCHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_sendToWinner_unchk8();
        handler.call_bug_unchk39(address(0x1001));
        handler.call_my_func_uncheck36(address(0x1001));
        handler.call_my_func_unchk35(address(0x1001));
        handler.call_withdrawLeftOver_unchk45();
        handler.call_UncheckedExternalCall_unchk40();
        handler.call_transfer(address(0x1001), 1);
        handler.call_withdrawLeftOver_unchk33();
        handler.call_callnotchecked_unchk13(address(0x1001));
        handler.call_sendToWinner_unchk44();
        handler.call_approve(address(0x1001), 1);
        handler.call_bug_unchk27(address(0x1001));
        handler.call_transferFrom(address(0x1001), address(0x1001), 1);
        handler.call_bug_unchk31();
    }
}

contract TAMCAccountingPropertyTest is TAMCBasePropertyTest {

    function test_property_accounting_0() public {
        _run_basic_sequence();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            sum += target.balanceOf(a);
        }
        _assertTrue(sum <= target.totalSupply());
    }

    function test_property_eth_conservation_0() public {
        _run_basic_sequence();
        uint256 totalSent = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            totalSent += handler.ethSent(handler.actor(i));
        }
        _assertTrue(address(target).balance <= totalSent);
    }
}

contract TAMCStateTransitionPropertyTest is TAMCBasePropertyTest {

    function test_transition_fn_payedOut_unchk44_sendToWinner_unchk44() public {
        handler.call_sendToWinner_unchk44();
    }

    function test_transition_fn_payedOut_unchk8_sendToWinner_unchk8() public {
        handler.call_sendToWinner_unchk8();
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract TAMCLegacyTerminalSupplementTest is TAMCBasePropertyTest {

    function test_supplement_payedOut_unchk44_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk44()) {
            uint256 curr = handler.curr_payedOut_unchk44();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_payedOut_unchk8_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk8()) {
            uint256 curr = handler.curr_payedOut_unchk8();
            _assertTrue(curr == 1);
        }
    }
}
