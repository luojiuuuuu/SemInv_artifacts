// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/etheraffle.sol";

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
    function _assertTrue(bool x) internal pure { require(x); }
    function _assertEq(uint256 a, uint256 b) internal pure { require(a == b); }
}
contract Ethraffle_v4bHandler is LegacyCheatcodes {
    Ethraffle_v4b public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Ethraffle_v4b _target) public {
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

    function call_Ethraffle_v4b() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("Ethraffle_v4b()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_buyTickets() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("buyTickets()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getRefund() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("getRefund()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_endRaffle() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("endRaffle()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_togglePause() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("togglePause()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_kill() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("kill()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract Ethraffle_v4bLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    Ethraffle_v4b target;
    Ethraffle_v4bHandler handler;

    function setUp() public {
        target = new Ethraffle_v4b();
        handler = new Ethraffle_v4bHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_Ethraffle_v4b();
        handler.call_buyTickets();
        handler.call_getRefund();
        handler.call_endRaffle();
        handler.call_togglePause();
        handler.call_kill();
    }

    function test_property_access_endRaffle() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("endRaffle()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_togglePause() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("togglePause()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}
