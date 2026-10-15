// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_4.sol";

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
contract PHOHandler is LegacyCheatcodes {
    PHO public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(PHO _target) public {
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

    function call_setReward_TOD38() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD38()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD38(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD38(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD4() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD4()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD4(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD4(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD7(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD7(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD7() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD7()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD23(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD23(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD23() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD23()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD14() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD14()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD14(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD14(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD30() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD30()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD30(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD30(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD8() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD8()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD8(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD8(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD39(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD39(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD39() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD39()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD36() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD36()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD36(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD36(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD35(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD35(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD35() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD35()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD40() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD40()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD40(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD40(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD33(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD33(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD33() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD33()"));
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

    function call_burnCoins(uint256 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnCoins(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD31(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD31(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD31() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD31()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD13(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD13(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD13() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD13()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract PHOBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    PHO target;
    PHOHandler handler;

    function setUp() public {
        target = new PHO();
        handler = new PHOHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_transfer(address(0x1001), 1);
        handler.call_setReward_TOD26();
        handler.call_claimReward_TOD26(1);
        handler.call_setReward_TOD20();
        handler.call_claimReward_TOD20(1);
        handler.call_setReward_TOD32();
        handler.call_claimReward_TOD32(1);
        handler.call_setReward_TOD38();
        handler.call_claimReward_TOD38(1);
        handler.call_setReward_TOD4();
        handler.call_claimReward_TOD4(1);
        handler.call_play_TOD7(bytes32(0));
        handler.call_getReward_TOD7();
        handler.call_play_TOD23(bytes32(0));
        handler.call_getReward_TOD23();
        handler.call_setReward_TOD14();
        handler.call_claimReward_TOD14(1);
        handler.call_setReward_TOD30();
        handler.call_claimReward_TOD30(1);
        handler.call_setReward_TOD8();
        handler.call_claimReward_TOD8(1);
        handler.call_play_TOD39(bytes32(0));
        handler.call_getReward_TOD39();
        handler.call_setReward_TOD36();
        handler.call_claimReward_TOD36(1);
        handler.call_play_TOD35(bytes32(0));
        handler.call_getReward_TOD35();
        handler.call_setReward_TOD40();
        handler.call_claimReward_TOD40(1);
        handler.call_play_TOD33(bytes32(0));
        handler.call_getReward_TOD33();
        handler.call_play_TOD27(bytes32(0));
        handler.call_getReward_TOD27();
        handler.call_burnCoins(1);
        handler.call_play_TOD31(bytes32(0));
        handler.call_getReward_TOD31();
        handler.call_play_TOD13(bytes32(0));
        handler.call_getReward_TOD13();
    }
}

contract PHOAccountingPropertyTest is PHOBasePropertyTest {

    function test_property_accounting_0() public {
        _run_basic_sequence();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            sum += target.balances(a);
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

contract PHOStateTransitionPropertyTest is PHOBasePropertyTest {

    function test_transition_fn_claimed_TOD40_claimReward_TOD40() public {
        handler.call_claimReward_TOD40(1);
    }

    function test_transition_fn_claimed_TOD8_claimReward_TOD8() public {
        handler.call_claimReward_TOD8(1);
    }

    function test_transition_fn_claimed_TOD32_claimReward_TOD32() public {
        handler.call_claimReward_TOD32(1);
    }

    function test_transition_fn_claimed_TOD30_claimReward_TOD30() public {
        handler.call_claimReward_TOD30(1);
    }

    function test_transition_fn_claimed_TOD4_claimReward_TOD4() public {
        handler.call_claimReward_TOD4(1);
    }

    function test_transition_fn_claimed_TOD14_claimReward_TOD14() public {
        handler.call_claimReward_TOD14(1);
    }

    function test_transition_fn_claimed_TOD36_claimReward_TOD36() public {
        handler.call_claimReward_TOD36(1);
    }

    function test_transition_fn_claimed_TOD26_claimReward_TOD26() public {
        handler.call_claimReward_TOD26(1);
    }

    function test_transition_fn_claimed_TOD20_claimReward_TOD20() public {
        handler.call_claimReward_TOD20(1);
    }

    function test_transition_fn_claimed_TOD38_claimReward_TOD38() public {
        handler.call_claimReward_TOD38(1);
    }
}

contract PHOAccessPropertyTest is PHOBasePropertyTest {

    function test_property_access_burnCoins() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnCoins(uint256)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract PHOLegacyTerminalSupplementTest is PHOBasePropertyTest {

    function test_supplement_claimed_TOD40_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD40()) {
            uint256 curr = handler.curr_claimed_TOD40();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD8_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD8()) {
            uint256 curr = handler.curr_claimed_TOD8();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD32_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD32()) {
            uint256 curr = handler.curr_claimed_TOD32();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD30_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD30()) {
            uint256 curr = handler.curr_claimed_TOD30();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD4_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD4()) {
            uint256 curr = handler.curr_claimed_TOD4();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD14_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD14()) {
            uint256 curr = handler.curr_claimed_TOD14();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD36_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD36()) {
            uint256 curr = handler.curr_claimed_TOD36();
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

    function test_supplement_claimed_TOD38_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD38()) {
            uint256 curr = handler.curr_claimed_TOD38();
            _assertTrue(curr == 1);
        }
    }
}
