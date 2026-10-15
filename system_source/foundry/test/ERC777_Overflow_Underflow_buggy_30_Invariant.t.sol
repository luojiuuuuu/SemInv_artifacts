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

    function call_transfer_intou18(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou18(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou29(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou29(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou29() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou29()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou62(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou62(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou16(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou16(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou24(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou24(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou5(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou5(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou5() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou5()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou15() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou15()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou28(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou28(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou34(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou34(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou21(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou21(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou21() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou21()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou10(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou10(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou22(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou22(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou12(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou12(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou11() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou11()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou1(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou1(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_ovrflow1() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_ovrflow1()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_undrflow2(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_undrflow2(address,uint256)", arg0,arg1));
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
        handler.call_transfer_intou18(address(0x1001), 1);
        handler.call_increaseLockTime_intou29(1);
        handler.call_withdraw_intou29();
        handler.call_transfer_intou62(address(0x1001), 1);
        handler.call_bug_intou16(1);
        handler.call_bug_intou24(1);
        handler.call_increaseLockTime_intou5(1);
        handler.call_withdraw_intou5();
        handler.call_bug_intou15();
        handler.call_bug_intou28(1);
        handler.call_transfer_intou34(address(0x1001), 1);
        handler.call_increaseLockTime_intou21(1);
        handler.call_withdraw_intou21();
        handler.call_transfer_intou10(address(0x1001), 1);
        handler.call_transfer_intou22(address(0x1001), 1);
        handler.call_bug_intou12(1);
        handler.call_bug_intou11();
        handler.call_increaseLockTime_intou1(1);
        handler.call_withdraw_ovrflow1();
        handler.call_transfer_undrflow2(address(0x1001), 1);
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