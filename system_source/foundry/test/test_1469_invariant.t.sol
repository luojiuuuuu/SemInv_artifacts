// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/SwarmRedistribution.sol";

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
contract SwarmRedistributionHandler is LegacyCheatcodes {
    SwarmRedistribution public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(SwarmRedistribution _target) public {
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

    function call_RES() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("RES()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_buy() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("buy()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_SwarmRedistribution() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("SwarmRedistribution()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_changeJohanNygrensAddress(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeJohanNygrensAddress(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_buyViaJohan() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("buyViaJohan()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sell(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sell(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract SwarmRedistributionLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    SwarmRedistribution target;
    SwarmRedistributionHandler handler;

    function setUp() public {
        target = new SwarmRedistribution();
        handler = new SwarmRedistributionHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_RES();
        handler.call_buy();
        handler.call_SwarmRedistribution();
        handler.call_changeJohanNygrensAddress(address(0x1001));
        handler.call_buyViaJohan();
        handler.call_sell(1);
        handler.call_transfer(address(0x1001), 1);
    }

    function test_property_access_transfer() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("transfer(address,uint256)", address(0x1001), 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}