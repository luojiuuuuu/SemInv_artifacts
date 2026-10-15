// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_43.sol";

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
contract OperatedHandler is LegacyCheatcodes {
    Operated public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Operated _target) public {
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

    function call_bug_unchk43() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk43()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_uncheck48(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_uncheck48(address)", arg0));
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

    function call_withdrawLeftOver_unchk9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk9()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callnotchecked_unchk25(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("callnotchecked_unchk25(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk19() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk19()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_unhandledsend_unchk26(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhandledsend_unchk26(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendToWinner_unchk20() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk20()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendToWinner_unchk32() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk32()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_unhandledsend_unchk38(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhandledsend_unchk38(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_cash_unchk46(uint256 arg0,uint256 arg1,address payable arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("cash_unchk46(uint256,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_UncheckedExternalCall_unchk4() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("UncheckedExternalCall_unchk4()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract OperatedBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    Operated target;
    OperatedHandler handler;

    function setUp() public {
        target = new Operated();
        handler = new OperatedHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_bug_unchk43();
        handler.call_my_func_uncheck48(address(0x1001));
        handler.call_bug_unchk31();
        handler.call_withdrawLeftOver_unchk9();
        handler.call_callnotchecked_unchk25(address(0x1001));
        handler.call_bug_unchk19();
        handler.call_unhandledsend_unchk26(address(0x1001));
        handler.call_sendToWinner_unchk20();
        handler.call_sendToWinner_unchk32();
        handler.call_unhandledsend_unchk38(address(0x1001));
        handler.call_cash_unchk46(1, 1, address(0x1001));
        handler.call_UncheckedExternalCall_unchk4();
    }
}

contract OperatedStateTransitionPropertyTest is OperatedBasePropertyTest {

    function test_transition_fn_payedOut_unchk32_sendToWinner_unchk32() public {
        handler.call_sendToWinner_unchk32();
    }

    function test_transition_fn_payedOut_unchk20_sendToWinner_unchk20() public {
        handler.call_sendToWinner_unchk20();
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract OperatedLegacyTerminalSupplementTest is OperatedBasePropertyTest {

    function test_supplement_payedOut_unchk32_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk32()) {
            uint256 curr = handler.curr_payedOut_unchk32();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_payedOut_unchk20_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk20()) {
            uint256 curr = handler.curr_payedOut_unchk20();
            _assertTrue(curr == 1);
        }
    }
}
