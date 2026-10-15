// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_4.sol";

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
contract PHOHandler is LegacyCheatcodes {
    PHO public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(PHO _target) public {
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

    function call_transfer_intou26(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou26(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou20(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou20(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou32(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou32(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou38(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou38(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou4(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou4(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou7() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou7()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou23() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou23()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou14(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou14(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou30(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou30(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou8(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou8(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou39() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou39()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou36(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou36(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou35() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou35()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou40(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou40(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou33(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou33(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou33() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou33()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou27() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou27()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burnCoins(uint256 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnCoins(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou31() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou31()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou13(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou13(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou13() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou13()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract PHOBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    PHO target;
    PHOHandler handler;

    function setUp() public {
        target = new PHO();
        handler = new PHOHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_transfer(address(0x1001), 1);
        handler.call_transfer_intou26(address(0x1001), 1);
        handler.call_bug_intou20(1);
        handler.call_bug_intou32(1);
        handler.call_transfer_intou38(address(0x1001), 1);
        handler.call_bug_intou4(1);
        handler.call_bug_intou7();
        handler.call_bug_intou23();
        handler.call_transfer_intou14(address(0x1001), 1);
        handler.call_transfer_intou30(address(0x1001), 1);
        handler.call_bug_intou8(1);
        handler.call_bug_intou39();
        handler.call_bug_intou36(1);
        handler.call_bug_intou35();
        handler.call_bug_intou40(1);
        handler.call_increaseLockTime_intou33(1);
        handler.call_withdraw_intou33();
        handler.call_bug_intou27();
        handler.call_burnCoins(1);
        handler.call_bug_intou31();
        handler.call_increaseLockTime_intou13(1);
        handler.call_withdraw_intou13();
    }
}

contract PHOAccessPropertyTest is PHOBasePropertyTest {

    function test_property_access_burnCoins() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnCoins(uint256)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}