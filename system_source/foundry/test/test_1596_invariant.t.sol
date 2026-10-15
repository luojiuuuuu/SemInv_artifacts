// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/buggy_5.sol";

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
contract TokenERC20Handler is LegacyCheatcodes {
    TokenERC20 public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(TokenERC20 _target) public {
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

    function call_bug_unchk_send6() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send6()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send16() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send16()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send24() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send24()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send5() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send5()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send15() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send15()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send28() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send28()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send8() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send8()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send27() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send27()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send31() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send31()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send1() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send1()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send2() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send2()"));
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

    function call_bug_unchk_send17() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send17()"));
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

    function call_bug_unchk_send3() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send3()"));
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

    function call_bug_unchk_send9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send9()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burn(uint256 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burn(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send25() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send25()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burnFrom(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnFrom(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk_send19() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("bug_unchk_send19()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract TokenERC20LegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    TokenERC20 target;
    TokenERC20Handler handler;

    function setUp() public {
        target = new TokenERC20(1, "", "");
        handler = new TokenERC20Handler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_bug_unchk_send6();
        handler.call_bug_unchk_send16();
        handler.call_bug_unchk_send24();
        handler.call_bug_unchk_send5();
        handler.call_bug_unchk_send15();
        handler.call_bug_unchk_send28();
        handler.call_bug_unchk_send8();
        handler.call_bug_unchk_send27();
        handler.call_bug_unchk_send31();
        handler.call_bug_unchk_send1();
        handler.call_bug_unchk_send2();
        handler.call_transfer(address(0x1001), 1);
        handler.call_bug_unchk_send17();
        handler.call_transferFrom(address(0x1001), address(0x1001), 1);
        handler.call_bug_unchk_send3();
        handler.call_approve(address(0x1001), 1);
        handler.call_bug_unchk_send9();
        handler.call_burn(1);
        handler.call_bug_unchk_send25();
        handler.call_burnFrom(address(0x1001), 1);
        handler.call_bug_unchk_send19();
    }

    function test_property_access_burn() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("burn(uint256)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_burnFrom() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("burnFrom(address,uint256)", address(0x1001), 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}