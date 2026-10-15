// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/multiowned_vulnerable.sol";

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
contract MultiOwnableHandler is LegacyCheatcodes {
    MultiOwnable public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(MultiOwnable _target) public {
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

    function call_newOwner(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("newOwner(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_deleteOwner(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("deleteOwner(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract MultiOwnableLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    MultiOwnable target;
    MultiOwnableHandler handler;

    function setUp() public {
        target = new MultiOwnable();
        handler = new MultiOwnableHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_newOwner(address(0x1001));
        handler.call_deleteOwner(address(0x1001));
    }

    function test_property_access_newOwner() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("newOwner(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_deleteOwner() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("deleteOwner(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}
