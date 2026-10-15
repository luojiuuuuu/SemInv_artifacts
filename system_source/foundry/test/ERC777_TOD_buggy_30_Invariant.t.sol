// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_30.sol";

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
contract ERC777Handler is LegacyCheatcodes {
    ERC777 public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(ERC777 _target) public {
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

    function call_send(address arg0,uint256 arg1,bytes memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("send(address,uint256,bytes)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burn(uint256 arg0,bytes memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burn(uint256,bytes)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_authorizeOperator(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("authorizeOperator(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_revokeOperator(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("revokeOperator(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_operatorSend(address arg0,address arg1,uint256 arg2,bytes memory arg3,bytes memory arg4) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("operatorSend(address,address,uint256,bytes,bytes)", arg0,arg1,arg2,arg3,arg4));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_operatorBurn(address arg0,uint256 arg1,bytes memory arg2,bytes memory arg3) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("operatorBurn(address,uint256,bytes,bytes)", arg0,arg1,arg2,arg3));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_approve(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("approve(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferFrom(address arg0,address arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD18() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD18()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD18(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD18(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play_TOD29(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play_TOD29(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getReward_TOD29() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("getReward_TOD29()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD6() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD6()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD6(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD6(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward_TOD16() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward_TOD16()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_TOD16(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_TOD16(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
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
}

contract ERC777BasePropertyTest is SimpleAssert, LegacyCheatcodes {
    ERC777 target;
    ERC777Handler handler;

    function setUp() public {
        address[] memory ctor_defaultOperators = new address[](1);
        ctor_defaultOperators[0] = address(0x1001);
        target = new ERC777("", "", ctor_defaultOperators);
        handler = new ERC777Handler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_send(address(0x1001), 1, hex"");
        handler.call_burn(1, hex"");
        handler.call_authorizeOperator(address(0x1001));
        handler.call_revokeOperator(address(0x1001));
        handler.call_operatorSend(address(0x1001), address(0x1001), 1, hex"", hex"");
        handler.call_operatorBurn(address(0x1001), 1, hex"", hex"");
        handler.call_transfer(address(0x1001), 1);
        handler.call_approve(address(0x1001), 1);
        handler.call_transferFrom(address(0x1001), address(0x1001), 1);
        handler.call_setReward_TOD18();
        handler.call_claimReward_TOD18(1);
        handler.call_play_TOD29(bytes32(0));
        handler.call_getReward_TOD29();
        handler.call_setReward_TOD6();
        handler.call_claimReward_TOD6(1);
        handler.call_setReward_TOD16();
        handler.call_claimReward_TOD16(1);
        handler.call_setReward_TOD24();
        handler.call_claimReward_TOD24(1);
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
        handler.call_play_TOD11(bytes32(0));
        handler.call_getReward_TOD11();
        handler.call_play_TOD1(bytes32(0));
        handler.call_getReward_TOD1();
        handler.call_setReward_TOD2();
        handler.call_claimReward_TOD2(1);
    }
}

contract ERC777AccountingPropertyTest is ERC777BasePropertyTest {

    function test_property_accounting_0() public {
        _run_basic_sequence();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            sum += target.balanceOf(a);
        }
        _assertTrue(sum <= target.totalSupply());
    }

    function test_property_eth_conservation_0() public {
        _run_basic_sequence();
        uint256 totalSent = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            totalSent += handler.ethSent(handler.actor(i));
        }
        _assertTrue(address(target).balance <= totalSent);
    }
}

contract ERC777StateTransitionPropertyTest is ERC777BasePropertyTest {

    function test_transition_fn_claimed_TOD28_claimReward_TOD28() public {
        handler.call_claimReward_TOD28(1);
    }

    function test_transition_fn_claimed_TOD10_claimReward_TOD10() public {
        handler.call_claimReward_TOD10(1);
    }

    function test_transition_fn_claimed_TOD12_claimReward_TOD12() public {
        handler.call_claimReward_TOD12(1);
    }

    function test_transition_fn_claimed_TOD34_claimReward_TOD34() public {
        handler.call_claimReward_TOD34(1);
    }

    function test_transition_fn_claimed_TOD22_claimReward_TOD22() public {
        handler.call_claimReward_TOD22(1);
    }

    function test_transition_fn_claimed_TOD2_claimReward_TOD2() public {
        handler.call_claimReward_TOD2(1);
    }

    function test_transition_fn_claimed_TOD18_claimReward_TOD18() public {
        handler.call_claimReward_TOD18(1);
    }

    function test_transition_fn_claimed_TOD6_claimReward_TOD6() public {
        handler.call_claimReward_TOD6(1);
    }

    function test_transition_fn_claimed_TOD16_claimReward_TOD16() public {
        handler.call_claimReward_TOD16(1);
    }

    function test_transition_fn_claimed_TOD24_claimReward_TOD24() public {
        handler.call_claimReward_TOD24(1);
    }
}

contract ERC777AccessPropertyTest is ERC777BasePropertyTest {

    function test_property_access_authorizeOperator() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("authorizeOperator(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_revokeOperator() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("revokeOperator(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_operatorSend() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("operatorSend(address,address,uint256,bytes,bytes)", address(0x1001), address(0x1001), 1, hex"", hex""));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_operatorBurn() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("operatorBurn(address,uint256,bytes,bytes)", address(0x1001), 1, hex"", hex""));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract ERC777LegacyTerminalSupplementTest is ERC777BasePropertyTest {

    function test_supplement_claimed_TOD28_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD28()) {
            uint256 curr = handler.curr_claimed_TOD28();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD10_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD10()) {
            uint256 curr = handler.curr_claimed_TOD10();
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

    function test_supplement_claimed_TOD22_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD22()) {
            uint256 curr = handler.curr_claimed_TOD22();
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

    function test_supplement_claimed_TOD18_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD18()) {
            uint256 curr = handler.curr_claimed_TOD18();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD6_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD6()) {
            uint256 curr = handler.curr_claimed_TOD6();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_claimed_TOD16_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_claimed_TOD16()) {
            uint256 curr = handler.curr_claimed_TOD16();
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
}
