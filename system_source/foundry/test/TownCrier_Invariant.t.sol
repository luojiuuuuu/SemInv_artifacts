// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/0x89c1b3807d4c67df034fffb62f3509561218d30b.sol";

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
contract TownCrierHandler is LegacyCheatcodes {
    TownCrier public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(TownCrier _target) public {
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

    function call_TownCrier() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("TownCrier()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_upgrade(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("upgrade(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_reset(uint256 arg0,uint256 arg1,uint256 arg2) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("reset(uint256,uint256,uint256)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_suspend() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("suspend()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_restart() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("restart()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_request(uint8 arg0,address arg1,bytes4 arg2,uint256 arg3,bytes32[] memory arg4) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg3 = uint256(uint256(arg3) % 1000);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("request(uint8,address,bytes4,uint256,bytes32[])", arg0,arg1,arg2,arg3,arg4));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_deliver(uint64 arg0,bytes32 arg1,uint64 arg2,bytes32 arg3) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint64(uint256(arg0) % 1000);
        arg2 = uint64(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("deliver(uint64,bytes32,uint64,bytes32)", arg0,arg1,arg2,arg3));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_cancel(uint64 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint64(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("cancel(uint64)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract TownCrierLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    TownCrier target;
    TownCrierHandler handler;

    function setUp() public {
        target = new TownCrier();
        handler = new TownCrierHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_TownCrier();
        handler.call_upgrade(address(0x1001));
        handler.call_reset(1, 1, 1);
        handler.call_suspend();
        handler.call_restart();
        handler.call_withdraw();
        handler.call_deliver(1, bytes32(0), 1, bytes32(0));
        handler.call_cancel(1);
    }

    function test_property_access_upgrade() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("upgrade(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_reset() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("reset(uint256,uint256,uint256)", 1, 1, 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_suspend() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("suspend()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_restart() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("restart()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_request() public {
        bytes32[] memory acc_request_requestData = new bytes32[](1);
        acc_request_requestData[0] = bytes32(0);
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("request(uint8,address,bytes4,uint256,bytes32[])", 1, address(0x1001), bytes4(0), 1, acc_request_requestData));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_deliver() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("deliver(uint64,bytes32,uint64,bytes32)", 1, bytes32(0), 1, bytes32(0)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_cancel() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("cancel(uint64)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}