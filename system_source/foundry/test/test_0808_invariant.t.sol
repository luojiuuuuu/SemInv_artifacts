// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/mapping_perfomance_2.sol";

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
contract MappingPerformance2setsHandler is LegacyCheatcodes {
    MappingPerformance2sets public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(MappingPerformance2sets _target) public {
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

    function call_set(bytes32 arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("set(bytes32,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_check(bytes32 arg0,uint256 arg1,bytes32 arg2,uint256 arg3,bytes32 arg4) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = uint256(uint256(arg1) % 1000);
        arg3 = uint256(uint256(arg3) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("check(bytes32,uint256,bytes32,uint256,bytes32)", arg0,arg1,arg2,arg3,arg4));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract MappingPerformance2setsLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    MappingPerformance2sets target;
    MappingPerformance2setsHandler handler;

    function setUp() public {
        target = new MappingPerformance2sets();
        handler = new MappingPerformance2setsHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_set(bytes32(0), 1);
        handler.call_check(bytes32(0), 1, bytes32(0), 1, bytes32(0));
    }
}