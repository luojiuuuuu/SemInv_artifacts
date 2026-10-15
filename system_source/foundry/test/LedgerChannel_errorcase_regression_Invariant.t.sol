// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/spank_chain_payment.sol";

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
contract LedgerChannelHandler is LegacyCheatcodes {
    LedgerChannel public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(LedgerChannel _target) public {
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

    function call_createChannel(bytes32 arg0,address arg1,uint256 arg2,address arg3,uint256[2] memory arg4) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = actors[uint256(keccak256(abi.encodePacked(arg3))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("createChannel(bytes32,address,uint256,address,uint256[2])", arg0,arg1,arg2,arg3,arg4));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_LCOpenTimeout(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("LCOpenTimeout(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_joinChannel(bytes32 arg0,uint256[2] memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("joinChannel(bytes32,uint256[2])", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_deposit(bytes32 arg0,address arg1,uint256 arg2,bool arg3) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("deposit(bytes32,address,uint256,bool)", arg0,arg1,arg2,arg3));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_consensusCloseChannel(bytes32 arg0,uint256 arg1,uint256[4] memory arg2,string memory arg3,string memory arg4) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("consensusCloseChannel(bytes32,uint256,uint256[4],string,string)", arg0,arg1,arg2,arg3,arg4));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_updateLCstate(bytes32 arg0,uint256[6] memory arg1,bytes32 arg2,string memory arg3,string memory arg4) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("updateLCstate(bytes32,uint256[6],bytes32,string,string)", arg0,arg1,arg2,arg3,arg4));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_initVCstate(bytes32 arg0,bytes32 arg1,bytes memory arg2,address arg3,address arg4,uint256[2] memory arg5,uint256[4] memory arg6,string memory arg7) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg3 = actors[uint256(keccak256(abi.encodePacked(arg3))) % actors.length];
        arg4 = actors[uint256(keccak256(abi.encodePacked(arg4))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("initVCstate(bytes32,bytes32,bytes,address,address,uint256[2],uint256[4],string)", arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_settleVC(bytes32 arg0,bytes32 arg1,uint256 arg2,address arg3,address arg4,uint256[4] memory arg5,string memory arg6) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = actors[uint256(keccak256(abi.encodePacked(arg3))) % actors.length];
        arg4 = actors[uint256(keccak256(abi.encodePacked(arg4))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("settleVC(bytes32,bytes32,uint256,address,address,uint256[4],string)", arg0,arg1,arg2,arg3,arg4,arg5,arg6));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_closeVirtualChannel(bytes32 arg0,bytes32 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("closeVirtualChannel(bytes32,bytes32)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_byzantineCloseChannel(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("byzantineCloseChannel(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract LedgerChannelLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    LedgerChannel target;
    LedgerChannelHandler handler;

    function setUp() public {
        target = new LedgerChannel();
        handler = new LedgerChannelHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_LCOpenTimeout(bytes32(0));
        handler.call_deposit(bytes32(0), address(0x1001), 1, false);
        handler.call_closeVirtualChannel(bytes32(0), bytes32(0));
        handler.call_byzantineCloseChannel(bytes32(0));
    }
}