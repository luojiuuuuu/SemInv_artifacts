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

    function call_setReward_TOD22() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD22()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD22(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD22(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD12() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD12()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD12(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD12(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD27(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD27(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD27() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD27()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD17(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD17(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD17() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD17()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD37(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD37(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD37() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD37()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD3(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD3(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD3() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD3()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD9(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD9(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD9()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD25(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD25(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD25() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD25()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD19(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD19(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD19() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD19()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD26() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD26()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD26(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD26(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD20() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD20()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD20(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD20(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD32() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD32()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD32(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD32(uint256)", arg0));
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
        handler.call_setReward_TOD22();
        handler.call_claimReward_TOD22(1);
        handler.call_setReward_TOD12();
        handler.call_claimReward_TOD12(1);
        handler.call_play_TOD27(bytes32(0));
        handler.call_getReward_TOD27();
        handler.call_play_TOD17(bytes32(0));
        handler.call_getReward_TOD17();
        handler.call_play_TOD37(bytes32(0));
        handler.call_getReward_TOD37();
        handler.call_play_TOD3(bytes32(0));
        handler.call_getReward_TOD3();
        handler.call_play_TOD9(bytes32(0));
        handler.call_getReward_TOD9();
        handler.call_play_TOD25(bytes32(0));
        handler.call_getReward_TOD25();
        handler.call_play_TOD19(bytes32(0));
        handler.call_getReward_TOD19();
        handler.call_setReward_TOD26();
        handler.call_claimReward_TOD26(1);
        handler.call_setReward_TOD20();
        handler.call_claimReward_TOD20(1);
        handler.call_setReward_TOD32();
        handler.call_claimReward_TOD32(1);
    }
}

contract OperatedStateTransitionPropertyTest is OperatedBasePropertyTest {

    function test_transition_fn_claimed_TOD32_claimReward_TOD32() public {
        handler.call_claimReward_TOD32(1);
    }

    function test_transition_fn_claimed_TOD22_claimReward_TOD22() public {
        handler.call_claimReward_TOD22(1);
    }

    function test_transition_fn_claimed_TOD12_claimReward_TOD12() public {
        handler.call_claimReward_TOD12(1);
    }

    function test_transition_fn_claimed_TOD26_claimReward_TOD26() public {
        handler.call_claimReward_TOD26(1);
    }

    function test_transition_fn_claimed_TOD20_claimReward_TOD20() public {
        handler.call_claimReward_TOD20(1);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract OperatedLegacyTerminalSupplementTest is OperatedBasePropertyTest {

    function test_supplement_claimed_TOD32_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD32()) {
            uint256 curr = handler.curr_claimed_TOD32();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD22_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD22()) {
            uint256 curr = handler.curr_claimed_TOD22();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD12_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD12()) {
            uint256 curr = handler.curr_claimed_TOD12();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD26_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD26()) {
            uint256 curr = handler.curr_claimed_TOD26();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD20_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD20()) {
            uint256 curr = handler.curr_claimed_TOD20();
            _assertTrue(curr == 1);
        }
    }
}
