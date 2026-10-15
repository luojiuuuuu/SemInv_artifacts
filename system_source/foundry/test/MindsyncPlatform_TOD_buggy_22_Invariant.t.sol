// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_22.sol";

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
contract MindsyncPlatformHandler is LegacyCheatcodes {
    MindsyncPlatform public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(MindsyncPlatform _target) public {
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

    function call_setReward_TOD24() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD24()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD24(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD24(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD11(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD11(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD11() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD11()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferOwnership(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD1(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD1(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD1() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD1()"));
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

    function call_receiveApproval(address arg0,uint256 arg1,address arg2,bytes memory arg3) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("receiveApproval(address,uint256,address,bytes)", arg0,arg1,arg2,arg3));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD2() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD2()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD2(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD2(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_fallback() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(hex"01");
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD17(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD17(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD17() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD17()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD5(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD5(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD5() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD5()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD15(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD15(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD15() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD15()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD28() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD28()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD28(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD28(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD34() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD34()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD34(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD34(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD21(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD21(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD21() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD21()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD10() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD10()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD10(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD10(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD22() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD22()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD22(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD22(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD12() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD12()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD12(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD12(uint256)", arg0));
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

    function call_init(contract Token arg0,address arg1,uint256 arg2,uint256 arg3,uint256 arg4) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = uint256(uint256(arg3) % 1000);
        arg4 = uint256(uint256(arg4) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("init(contract,address,uint256,uint256,uint256)", arg0,arg1,arg2,arg3,arg4));
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

    function call_changeVotingRules(contract Token arg0,address arg1,uint256 arg2,uint256 arg3,uint256 arg4) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = uint256(uint256(arg3) % 1000);
        arg4 = uint256(uint256(arg4) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeVotingRules(contract,address,uint256,uint256,uint256)", arg0,arg1,arg2,arg3,arg4));
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

    function call_newProposal(address arg0,uint256 arg1,string memory arg2,bytes memory arg3) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("newProposal(address,uint256,string,bytes)", arg0,arg1,arg2,arg3));
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

    function call_sign(uint256 arg0,bool arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sign(uint256,bool)", arg0,arg1));
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

    function call_vote(uint256 arg0,bool arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("vote(uint256,bool)", arg0,arg1));
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

    function call_executeProposal(uint256 arg0,bytes memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("executeProposal(uint256,bytes)", arg0,arg1));
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
}

contract MindsyncPlatformBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    MindsyncPlatform target;
    MindsyncPlatformHandler handler;

    function setUp() public {
        target = new MindsyncPlatform();
        handler = new MindsyncPlatformHandler(target);
        _vm().deal(address(handler), 100 ether);
        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));
    }

    function _run_basic_sequence() internal {
        handler.call_setReward_TOD24();
        handler.call_claimReward_TOD24(1);
        handler.call_play_TOD11(bytes32(0));
        handler.call_getReward_TOD11();
        handler.call_transferOwnership(address(0x1001));
        handler.call_play_TOD1(bytes32(0));
        handler.call_getReward_TOD1();
        handler.call_play_TOD39(bytes32(0));
        handler.call_getReward_TOD39();
        handler.call_setReward_TOD36();
        handler.call_claimReward_TOD36(1);
        handler.call_receiveApproval(address(0x1001), 1, address(0x1001), hex"");
        handler.call_setReward_TOD2();
        handler.call_claimReward_TOD2(1);
        handler.call_fallback();
        handler.call_play_TOD17(bytes32(0));
        handler.call_getReward_TOD17();
        handler.call_play_TOD5(bytes32(0));
        handler.call_getReward_TOD5();
        handler.call_play_TOD15(bytes32(0));
        handler.call_getReward_TOD15();
        handler.call_setReward_TOD28();
        handler.call_claimReward_TOD28(1);
        handler.call_setReward_TOD34();
        handler.call_claimReward_TOD34(1);
        handler.call_play_TOD21(bytes32(0));
        handler.call_getReward_TOD21();
        handler.call_setReward_TOD10();
        handler.call_claimReward_TOD10(1);
        handler.call_setReward_TOD22();
        handler.call_claimReward_TOD22(1);
        handler.call_setReward_TOD12();
        handler.call_claimReward_TOD12(1);
        handler.call_play_TOD35(bytes32(0));
        handler.call_getReward_TOD35();
        handler.call_setReward_TOD40();
        handler.call_claimReward_TOD40(1);
        handler.call_play_TOD33(bytes32(0));
        handler.call_getReward_TOD33();
        handler.call_play_TOD27(bytes32(0));
        handler.call_getReward_TOD27();
        handler.call_play_TOD31(bytes32(0));
        handler.call_getReward_TOD31();
        handler.call_play_TOD13(bytes32(0));
        handler.call_getReward_TOD13();
        handler.call_setReward_TOD32();
        handler.call_claimReward_TOD32(1);
        handler.call_init(Token(address(0x1001)), address(0x1001), 1, 1, 1);
        handler.call_setReward_TOD38();
        handler.call_claimReward_TOD38(1);
        handler.call_changeVotingRules(Token(address(0x1001)), address(0x1001), 1, 1, 1);
        handler.call_setReward_TOD4();
        handler.call_claimReward_TOD4(1);
        handler.call_newProposal(address(0x1001), 1, "", hex"");
        handler.call_play_TOD7(bytes32(0));
        handler.call_getReward_TOD7();
        handler.call_play_TOD23(bytes32(0));
        handler.call_getReward_TOD23();
        handler.call_sign(1, false);
        handler.call_setReward_TOD14();
        handler.call_claimReward_TOD14(1);
        handler.call_vote(1, false);
        handler.call_setReward_TOD30();
        handler.call_claimReward_TOD30(1);
        handler.call_executeProposal(1, hex"");
        handler.call_setReward_TOD8();
        handler.call_claimReward_TOD8(1);
    }
}

contract MindsyncPlatformStateTransitionPropertyTest is MindsyncPlatformBasePropertyTest {

    function test_transition_fn_claimed_TOD10_claimReward_TOD10() public {
        handler.call_claimReward_TOD10(1);
    }

    function test_transition_fn_claimed_TOD32_claimReward_TOD32() public {
        handler.call_claimReward_TOD32(1);
    }

    function test_transition_fn_claimed_TOD12_claimReward_TOD12() public {
        handler.call_claimReward_TOD12(1);
    }

    function test_transition_fn_claimed_TOD34_claimReward_TOD34() public {
        handler.call_claimReward_TOD34(1);
    }

    function test_transition_fn_claimed_TOD4_claimReward_TOD4() public {
        handler.call_claimReward_TOD4(1);
    }

    function test_transition_fn_claimed_TOD24_claimReward_TOD24() public {
        handler.call_claimReward_TOD24(1);
    }

    function test_transition_fn_claimed_TOD28_claimReward_TOD28() public {
        handler.call_claimReward_TOD28(1);
    }

    function test_transition_fn_initialized_init() public {
        handler.call_init(Token(address(0x1001)), address(0x1001), 1, 1, 1);
    }

    function test_transition_fn_claimed_TOD14_claimReward_TOD14() public {
        handler.call_claimReward_TOD14(1);
    }

    function test_transition_fn_claimed_TOD40_claimReward_TOD40() public {
        handler.call_claimReward_TOD40(1);
    }

    function test_transition_fn_claimed_TOD36_claimReward_TOD36() public {
        handler.call_claimReward_TOD36(1);
    }

    function test_transition_fn_claimed_TOD30_claimReward_TOD30() public {
        handler.call_claimReward_TOD30(1);
    }

    function test_transition_fn_claimed_TOD2_claimReward_TOD2() public {
        handler.call_claimReward_TOD2(1);
    }

    function test_transition_fn_claimed_TOD22_claimReward_TOD22() public {
        handler.call_claimReward_TOD22(1);
    }

    function test_transition_fn_claimed_TOD38_claimReward_TOD38() public {
        handler.call_claimReward_TOD38(1);
    }

    function test_transition_fn_claimed_TOD8_claimReward_TOD8() public {
        handler.call_claimReward_TOD8(1);
    }
}

contract MindsyncPlatformAccessPropertyTest is MindsyncPlatformBasePropertyTest {

    function test_property_access_transferOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_init() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("init(contract,address,uint256,uint256,uint256)", Token(address(0x1001)), address(0x1001), 1, 1, 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract MindsyncPlatformLegacyTerminalSupplementTest is MindsyncPlatformBasePropertyTest {

    function test_supplement_claimed_TOD10_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD10()) {
            uint256 curr = handler.curr_claimed_TOD10();
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

    function test_supplement_claimed_TOD12_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD12()) {
            uint256 curr = handler.curr_claimed_TOD12();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD34_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD34()) {
            uint256 curr = handler.curr_claimed_TOD34();
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

    function test_supplement_claimed_TOD24_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD24()) {
            uint256 curr = handler.curr_claimed_TOD24();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD28_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD28()) {
            uint256 curr = handler.curr_claimed_TOD28();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_initialized_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_initialized()) {
            uint256 curr = handler.curr_initialized();
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

    function test_supplement_claimed_TOD40_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD40()) {
            uint256 curr = handler.curr_claimed_TOD40();
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

    function test_supplement_claimed_TOD30_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD30()) {
            uint256 curr = handler.curr_claimed_TOD30();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD2_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD2()) {
            uint256 curr = handler.curr_claimed_TOD2();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD22_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD22()) {
            uint256 curr = handler.curr_claimed_TOD22();
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

    function test_supplement_claimed_TOD8_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD8()) {
            uint256 curr = handler.curr_claimed_TOD8();
            _assertTrue(curr == 1);
        }
    }
}
