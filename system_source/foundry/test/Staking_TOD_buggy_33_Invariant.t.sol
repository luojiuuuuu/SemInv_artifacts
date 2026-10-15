// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_33.sol";

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
contract StakingHandler is LegacyCheatcodes {
    Staking public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Staking _target) public {
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

    function call_play_TOD37(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD37(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD37() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD37()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD3(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD3(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD3() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD3()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD9(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD9(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD9()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD25(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD25(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD25() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD25()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD19(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD19(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD19() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD19()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD26() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD26()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD26(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD26(uint256)", arg0));
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

    function call_setReward_TOD20() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD20()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD20(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD20(uint256)", arg0));
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

    function call_startStaking(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("startStaking(uint256)", arg0));
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

    function call_redeem() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("redeem()"));
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

    function call_changeStakeTokens(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeStakeTokens(uint256)", arg0));
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

    function call_changeStakeTime(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeStakeTime(uint256)", arg0));
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

    function call_changeStakingPercentage(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeStakingPercentage(uint256)", arg0));
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

    function call_lockWithdrawals() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("lockWithdrawals()"));
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
}

contract StakingBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    Staking target;
    StakingHandler handler;

    function setUp() public {
        target = new Staking(address(0x1001));
        handler = new StakingHandler(target);
        _vm().deal(address(handler), 100 ether);
        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));
    }

    function _run_basic_sequence() internal {
        handler.call_setReward_TOD2();
        handler.call_claimReward_TOD2(1);
        handler.call_play_TOD17(bytes32(0));
        handler.call_getReward_TOD17();
        handler.call_play_TOD27(bytes32(0));
        handler.call_getReward_TOD27();
        handler.call_setReward_TOD32();
        handler.call_claimReward_TOD32(1);
        handler.call_transferOwnership(address(0x1001));
        handler.call_setReward_TOD38();
        handler.call_claimReward_TOD38(1);
        handler.call_play_TOD37(bytes32(0));
        handler.call_getReward_TOD37();
        handler.call_play_TOD3(bytes32(0));
        handler.call_getReward_TOD3();
        handler.call_play_TOD9(bytes32(0));
        handler.call_getReward_TOD9();
        handler.call_play_TOD25(bytes32(0));
        handler.call_getReward_TOD25();
        handler.call_play_TOD19(bytes32(0));
        handler.call_getReward_TOD19();
        handler.call_setReward_TOD26();
        handler.call_claimReward_TOD26(1);
        handler.call_play_TOD31(bytes32(0));
        handler.call_getReward_TOD31();
        handler.call_play_TOD13(bytes32(0));
        handler.call_getReward_TOD13();
        handler.call_setReward_TOD20();
        handler.call_claimReward_TOD20(1);
        handler.call_setReward_TOD14();
        handler.call_claimReward_TOD14(1);
        handler.call_startStaking(1);
        handler.call_setReward_TOD30();
        handler.call_claimReward_TOD30(1);
        handler.call_redeem();
        handler.call_setReward_TOD8();
        handler.call_claimReward_TOD8(1);
        handler.call_changeStakeTokens(1);
        handler.call_play_TOD39(bytes32(0));
        handler.call_getReward_TOD39();
        handler.call_changeStakeTime(1);
        handler.call_setReward_TOD36();
        handler.call_claimReward_TOD36(1);
        handler.call_changeStakingPercentage(1);
        handler.call_play_TOD35(bytes32(0));
        handler.call_getReward_TOD35();
        handler.call_lockWithdrawals();
        handler.call_setReward_TOD40();
        handler.call_claimReward_TOD40(1);
        handler.call_play_TOD33(bytes32(0));
        handler.call_getReward_TOD33();
    }
}

contract StakingStateTransitionPropertyTest is StakingBasePropertyTest {

    function test_transition_fn_claimed_TOD2_claimReward_TOD2() public {
        handler.call_claimReward_TOD2(1);
    }

    function test_transition_fn_claimed_TOD32_claimReward_TOD32() public {
        handler.call_claimReward_TOD32(1);
    }

    function test_transition_fn_claimed_TOD38_claimReward_TOD38() public {
        handler.call_claimReward_TOD38(1);
    }

    function test_transition_fn_claimed_TOD30_claimReward_TOD30() public {
        handler.call_claimReward_TOD30(1);
    }

    function test_transition_fn_claimed_TOD14_claimReward_TOD14() public {
        handler.call_claimReward_TOD14(1);
    }

    function test_transition_fn_claimed_TOD40_claimReward_TOD40() public {
        handler.call_claimReward_TOD40(1);
    }

    function test_transition_fn_claimed_TOD26_claimReward_TOD26() public {
        handler.call_claimReward_TOD26(1);
    }

    function test_transition_fn_claimed_TOD20_claimReward_TOD20() public {
        handler.call_claimReward_TOD20(1);
    }

    function test_transition_fn_claimed_TOD36_claimReward_TOD36() public {
        handler.call_claimReward_TOD36(1);
    }

    function test_transition_fn_claimed_TOD8_claimReward_TOD8() public {
        handler.call_claimReward_TOD8(1);
    }

    function test_transition_fn_lock_lockWithdrawals() public {
        handler.call_lockWithdrawals();
    }
}

contract StakingAccessPropertyTest is StakingBasePropertyTest {

    function test_property_access_transferOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_lockWithdrawals() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("lockWithdrawals()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract StakingLegacyTerminalSupplementTest is StakingBasePropertyTest {

    function test_supplement_claimed_TOD2_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD2()) {
            uint256 curr = handler.curr_claimed_TOD2();
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

    function test_supplement_claimed_TOD38_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD38()) {
            uint256 curr = handler.curr_claimed_TOD38();
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

    function test_supplement_claimed_TOD26_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD26()) {
            uint256 curr = handler.curr_claimed_TOD26();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD20_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD20()) {
            uint256 curr = handler.curr_claimed_TOD20();
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

    function test_supplement_claimed_TOD8_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD8()) {
            uint256 curr = handler.curr_claimed_TOD8();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_lock_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_lock()) {
            uint256 curr = handler.curr_lock();
            _assertTrue(curr == 1);
        }
    }
}
