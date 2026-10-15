// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_6.sol";

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
contract ChannelWalletHandler is LegacyCheatcodes {
    ChannelWallet public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(ChannelWallet _target) public {
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

    function call_withdrawAll_txorigin10(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin10(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawAll_txorigin22(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin22(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_txorigin12(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_txorigin12(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_txorigin36(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_txorigin36(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin35(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin35(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_txorigin40(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_txorigin40(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendto_txorigin33(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin33(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendto_txorigin1(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin1(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawAll_txorigin2(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin2(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendto_txorigin17(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin17(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendto_txorigin37(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin37(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin3(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin3(address,uint256,address)", arg0,arg1,arg2));
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

    function call_sendto_txorigin9(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin9(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferMasterRole(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferMasterRole(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendto_txorigin25(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin25(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin19(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin19(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_stop() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("stop()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawAll_txorigin26(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin26(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_start() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("start()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_txorigin20(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_txorigin20(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_txorigin32(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_txorigin32(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawAll_txorigin38(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin38(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_txorigin4(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_txorigin4(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin7(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin7(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin11(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin11(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin27(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin27(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin31(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin31(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendto_txorigin13(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin13(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin23(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin23(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawAll_txorigin14(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin14(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setAddress(string memory arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("setAddress(string,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawAll_txorigin30(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = address(uint160(actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length]));
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin30(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_updateChannel(string memory arg0,string memory arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("updateChannel(string,string,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_txorigin8(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_txorigin8(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_deleteChannel(string memory arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("deleteChannel(string)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferTo_txorigin39(address arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferTo_txorigin39(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract ChannelWalletBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    ChannelWallet target;
    ChannelWalletHandler handler;

    function setUp() public {
        target = new ChannelWallet();
        handler = new ChannelWalletHandler(target);
        _vm().deal(address(handler), 100 ether);
        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));
    }

    function _run_basic_sequence() internal {
        handler.call_withdrawAll_txorigin10(address(0x1001), address(0x1001));
        handler.call_withdrawAll_txorigin22(address(0x1001), address(0x1001));
        handler.call_bug_txorigin12(address(0x1001));
        handler.call_bug_txorigin36(address(0x1001));
        handler.call_transferTo_txorigin35(address(0x1001), 1, address(0x1001));
        handler.call_bug_txorigin40(address(0x1001));
        handler.call_sendto_txorigin33(address(0x1001), 1, address(0x1001));
        handler.call_sendto_txorigin1(address(0x1001), 1, address(0x1001));
        handler.call_withdrawAll_txorigin2(address(0x1001), address(0x1001));
        handler.call_sendto_txorigin17(address(0x1001), 1, address(0x1001));
        handler.call_sendto_txorigin37(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin3(address(0x1001), 1, address(0x1001));
        handler.call_transferOwnership(address(0x1001));
        handler.call_sendto_txorigin9(address(0x1001), 1, address(0x1001));
        handler.call_transferMasterRole(address(0x1001));
        handler.call_sendto_txorigin25(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin19(address(0x1001), 1, address(0x1001));
        handler.call_stop();
        handler.call_withdrawAll_txorigin26(address(0x1001), address(0x1001));
        handler.call_start();
        handler.call_bug_txorigin20(address(0x1001));
        handler.call_bug_txorigin32(address(0x1001));
        handler.call_withdrawAll_txorigin38(address(0x1001), address(0x1001));
        handler.call_bug_txorigin4(address(0x1001));
        handler.call_transferTo_txorigin7(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin11(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin27(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin31(address(0x1001), 1, address(0x1001));
        handler.call_sendto_txorigin13(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin23(address(0x1001), 1, address(0x1001));
        handler.call_withdrawAll_txorigin14(address(0x1001), address(0x1001));
        handler.call_setAddress("", address(0x1001));
        handler.call_withdrawAll_txorigin30(address(0x1001), address(0x1001));
        handler.call_updateChannel("", "", address(0x1001));
        handler.call_bug_txorigin8(address(0x1001));
        handler.call_deleteChannel("");
        handler.call_transferTo_txorigin39(address(0x1001), 1, address(0x1001));
    }
}

contract ChannelWalletStateTransitionPropertyTest is ChannelWalletBasePropertyTest {

    function test_transition_fn_stopped_stop() public {
        handler.call_stop();
    }

    function test_transition_fn_stopped_start() public {
        handler.call_start();
    }
}

contract ChannelWalletAccessPropertyTest is ChannelWalletBasePropertyTest {

    function test_property_access_transferOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_transferMasterRole() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferMasterRole(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_stop() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("stop()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_start() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("start()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}