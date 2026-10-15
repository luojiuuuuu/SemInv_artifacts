// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/0x958a8f594101d2c0485a52319f29b2647f2ebc06.sol";

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
contract MarriageHandler is LegacyCheatcodes {
    Marriage public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Marriage _target) public {
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

    function call_Owned() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("Owned()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_changeOwner(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeOwner(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_acceptOwnership() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("acceptOwnership()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_execute(address arg0,uint256 arg1,bytes memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("execute(address,uint256,bytes)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_Marriage(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("Marriage(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_createMarriage(string memory arg0,string memory arg1,string memory arg2,string memory arg3) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("createMarriage(string,string,string,string)", arg0,arg1,arg2,arg3));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setStatus(string memory arg0,string memory arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setStatus(string,string)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setMajorEvent(string memory arg0,string memory arg1,string memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setMajorEvent(string,string,string)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendMessage(string memory arg0,string memory arg1,string memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("sendMessage(string,string,string)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract MarriageLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    Marriage target;
    MarriageHandler handler;

    function setUp() public {
        target = new Marriage(address(0x1001));
        handler = new MarriageHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_Owned();
        handler.call_changeOwner(address(0x1001));
        handler.call_acceptOwnership();
        handler.call_execute(address(0x1001), 1, hex"");
        handler.call_Marriage(address(0x1001));
        handler.call_createMarriage("", "", "", "");
        handler.call_setStatus("", "");
        handler.call_setMajorEvent("", "", "");
        handler.call_sendMessage("", "", "");
    }

    function test_property_access_changeOwner() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("changeOwner(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_acceptOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("acceptOwnership()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_createMarriage() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("createMarriage(string,string,string,string)", "", "", "", ""));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_setStatus() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("setStatus(string,string)", "", ""));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}