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

    function call_bug_unchk_send16() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send16()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send24() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send24()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send27() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send27()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send21() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send21()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send10() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send10()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send22() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send22()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send12() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send12()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send11() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send11()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send1() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send1()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send2() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send2()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send17() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send17()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send3() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send3()"));
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
        handler.call_bug_unchk_send16();
        handler.call_bug_unchk_send24();
        handler.call_bug_unchk_send27();
        handler.call_bug_unchk_send21();
        handler.call_bug_unchk_send10();
        handler.call_bug_unchk_send22();
        handler.call_bug_unchk_send12();
        handler.call_bug_unchk_send11();
        handler.call_bug_unchk_send1();
        handler.call_bug_unchk_send2();
        handler.call_bug_unchk_send17();
        handler.call_bug_unchk_send3();
    }
}

contract OperatedStateTransitionPropertyTest is OperatedBasePropertyTest {
}