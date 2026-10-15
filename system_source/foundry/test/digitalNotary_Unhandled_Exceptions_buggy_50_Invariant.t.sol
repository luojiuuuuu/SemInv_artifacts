// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_50.sol";

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
contract digitalNotaryHandler is LegacyCheatcodes {
    digitalNotary public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(digitalNotary _target) public {
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

    function call_bug_unchk3(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk3(address)", arg0));
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

    function call_withdrawLeftOver_unchk45() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk45()"));
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

    function call_sethashfee(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sethashfee(uint256)", arg0));
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

    function call_setchangehashownerfee(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setchangehashownerfee(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk7() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk7()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_unchk23(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_unchk23(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setcontractactive(bool arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setcontractactive(bool)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_unhandledsend_unchk14(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhandledsend_unchk14(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk30() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk30()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setmanager(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("setmanager(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
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

    function call_transfercontractbalance() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfercontractbalance()"));
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

    function call_sendToWinner_unchk44() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk44()"));
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

    function call_registerHash(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("registerHash(bytes32)", arg0));
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

    function call_changeHashOwnership(bytes32 arg0,address arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("changeHashOwnership(bytes32,address)", arg0,arg1));
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

    function call_fallback() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(hex"01");
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

contract digitalNotaryBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    digitalNotary target;
    digitalNotaryHandler handler;

    function setUp() public {
        target = new digitalNotary();
        handler = new digitalNotaryHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_bug_unchk3(address(0x1001));
        handler.call_withdrawLeftOver_unchk9();
        handler.call_callnotchecked_unchk25(address(0x1001));
        handler.call_bug_unchk19();
        handler.call_unhandledsend_unchk26(address(0x1001));
        handler.call_sendToWinner_unchk20();
        handler.call_withdrawLeftOver_unchk45();
        handler.call_callnotchecked_unchk13(address(0x1001));
        handler.call_sendToWinner_unchk32();
        handler.call_unhandledsend_unchk38(address(0x1001));
        handler.call_sethashfee(1);
        handler.call_cash_unchk46(1, 1, address(0x1001));
        handler.call_UncheckedExternalCall_unchk4();
        handler.call_setchangehashownerfee(1);
        handler.call_bug_unchk7();
        handler.call_my_func_unchk23(address(0x1001));
        handler.call_setcontractactive(false);
        handler.call_unhandledsend_unchk14(address(0x1001));
        handler.call_bug_unchk30();
        handler.call_setmanager(address(0x1001));
        handler.call_sendToWinner_unchk8();
        handler.call_bug_unchk39(address(0x1001));
        handler.call_transfercontractbalance();
        handler.call_my_func_uncheck36(address(0x1001));
        handler.call_my_func_unchk35(address(0x1001));
        handler.call_sendToWinner_unchk44();
        handler.call_UncheckedExternalCall_unchk40();
        handler.call_registerHash(bytes32(0));
        handler.call_withdrawLeftOver_unchk33();
        handler.call_changeHashOwnership(bytes32(0), address(0x1001));
        handler.call_bug_unchk27(address(0x1001));
        handler.call_fallback();
        handler.call_bug_unchk31();
    }
}

contract digitalNotaryStateTransitionPropertyTest is digitalNotaryBasePropertyTest {

    function test_transition_fn_payedOut_unchk32_sendToWinner_unchk32() public {
        handler.call_sendToWinner_unchk32();
    }

    function test_transition_fn_payedOut_unchk44_sendToWinner_unchk44() public {
        handler.call_sendToWinner_unchk44();
    }

    function test_transition_fn_payedOut_unchk20_sendToWinner_unchk20() public {
        handler.call_sendToWinner_unchk20();
    }

    function test_transition_fn_contractactive_setcontractactive() public {
        handler.call_setcontractactive(false);
    }

    function test_transition_fn_payedOut_unchk8_sendToWinner_unchk8() public {
        handler.call_sendToWinner_unchk8();
    }
}

contract digitalNotaryAccessPropertyTest is digitalNotaryBasePropertyTest {

    function test_property_access_changeHashOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeHashOwnership(bytes32,address)", bytes32(0), address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract digitalNotaryLegacyTerminalSupplementTest is digitalNotaryBasePropertyTest {

    function test_supplement_payedOut_unchk32_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk32()) {
            uint256 curr = handler.curr_payedOut_unchk32();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_payedOut_unchk44_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk44()) {
            uint256 curr = handler.curr_payedOut_unchk44();
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

    function test_supplement_payedOut_unchk8_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk8()) {
            uint256 curr = handler.curr_payedOut_unchk8();
            _assertTrue(curr == 1);
        }
    }
}

contract digitalNotaryLegacyEthFlowSupplementTest is digitalNotaryBasePropertyTest {

    function test_supplement_eth_balance_bound_0_winAmount_unchk20() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.winAmount_unchk20() <= address(target).balance);
    }

    function test_supplement_eth_balance_bound_1_winAmount_unchk32() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.winAmount_unchk32() <= address(target).balance);
    }

    function test_supplement_eth_balance_bound_2_winAmount_unchk8() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.winAmount_unchk8() <= address(target).balance);
    }
}
