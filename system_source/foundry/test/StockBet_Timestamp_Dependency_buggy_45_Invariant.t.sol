// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_45.sol";

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
contract StockBetHandler is LegacyCheatcodes {
    StockBet public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(StockBet _target) public {
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

    function call_play_tmstmp27(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp27(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp31(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp31(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp3(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp3(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp19(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp19(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp26(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp26(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_tmstmp20() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_tmstmp20()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_tmstmp32() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_tmstmp32()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp38(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp38(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_tmstmp4() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_tmstmp4()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp7(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp7(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setOracle(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setOracle(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp23(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp23(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setInitialPrice(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setInitialPrice(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp14(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp14(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_closeGame() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("closeGame()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp30(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp30(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_betUp() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("betUp()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_tmstmp8() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_tmstmp8()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_betDown() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("betDown()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp39(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp39(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setFinalPrice(uint256 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setFinalPrice(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_tmstmp36() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_tmstmp36()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_collectOwnerWinnings() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("collectOwnerWinnings()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_tmstmp35(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_tmstmp35(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_collectPlayerWinnings() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("collectPlayerWinnings()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_tmstmp40() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_tmstmp40()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract StockBetBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    StockBet target;
    StockBetHandler handler;

    function setUp() public {
        target = new StockBet(1);
        handler = new StockBetHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_play_tmstmp27(1);
        handler.call_play_tmstmp31(1);
        handler.call_play_tmstmp3(1);
        handler.call_play_tmstmp19(1);
        handler.call_play_tmstmp26(1);
        handler.call_bug_tmstmp20();
        handler.call_bug_tmstmp32();
        handler.call_play_tmstmp38(1);
        handler.call_bug_tmstmp4();
        handler.call_play_tmstmp7(1);
        handler.call_setOracle(address(0x1001));
        handler.call_play_tmstmp23(1);
        handler.call_setInitialPrice(1);
        handler.call_play_tmstmp14(1);
        handler.call_closeGame();
        handler.call_play_tmstmp30(1);
        handler.call_betUp();
        handler.call_bug_tmstmp8();
        handler.call_betDown();
        handler.call_play_tmstmp39(1);
        handler.call_setFinalPrice(1);
        handler.call_bug_tmstmp36();
        handler.call_collectOwnerWinnings();
        handler.call_play_tmstmp35(1);
        handler.call_collectPlayerWinnings();
        handler.call_bug_tmstmp40();
    }
}

contract StockBetStateTransitionPropertyTest is StockBetBasePropertyTest {

    function test_transition_fn_initialPrice_setInitialPrice() public {
        handler.call_setInitialPrice(1);
    }

    function test_transition_fn_state_setInitialPrice() public {
        handler.call_setInitialPrice(1);
    }

    function test_transition_fn_state_closeGame() public {
        handler.call_closeGame();
    }

    function test_transition_fn_state_setFinalPrice() public {
        handler.call_setFinalPrice(1);
    }
}

contract StockBetAccessPropertyTest is StockBetBasePropertyTest {

    function test_property_access_setOracle() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setOracle(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_closeGame() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("closeGame()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_setFinalPrice() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setFinalPrice(uint256)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_collectOwnerWinnings() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("collectOwnerWinnings()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract StockBetLegacyTerminalSupplementTest is StockBetBasePropertyTest {

    function test_supplement_state_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_state()) {
            uint256 curr = handler.curr_state();
            _assertTrue(curr == 3);
        }
    }
}
