// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_21.sol";

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
contract StableDEXHandler is LegacyCheatcodes {
    StableDEX public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(StableDEX _target) public {
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

    function call_sendto_txorigin13(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin13(address,uint256,address)", arg0,arg1,arg2));
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

    function call_sendto_txorigin1(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
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
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
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
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin17(address,uint256,address)", arg0,arg1,arg2));
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

    function call_sendto_txorigin37(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
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

    function call_sendto_txorigin9(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin9(address,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendto_txorigin25(address payable arg0,uint256 arg1,address arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
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

    function call_withdrawAll_txorigin26(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin26(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setDexStatus(bool arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setDexStatus(bool)", arg0));
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

    function call_addToken(address arg0,string memory arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("addToken(address,string,uint256)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawAll_txorigin14(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin14(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_deposit() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("deposit()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawAll_txorigin30(address payable arg0,address arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawAll_txorigin30(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_tokenDeposit(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("tokenDeposit(address,uint256)", arg0,arg1));
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

    function call_withdraw(uint8 arg0,address arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw(uint8,address,uint256)", arg0,arg1,arg2));
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

    function call_adminProfitWithdraw(uint8 arg0,address arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("adminProfitWithdraw(uint8,address)", arg0,arg1));
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

    function call_setwithdrawfee(address[] memory arg0,uint256[] memory arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setwithdrawfee(address[],uint256[])", arg0,arg1));
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

    function call_makeOrder(uint256[9] memory arg0,address[2] memory arg1,string memory arg2,uint8 arg3,bytes32 arg4,bytes32 arg5) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg3 = uint8(uint256(arg3) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("makeOrder(uint256[9],address[2],string,uint8,bytes32,bytes32)", arg0,arg1,arg2,arg3,arg4,arg5));
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
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendto_txorigin33(address,uint256,address)", arg0,arg1,arg2));
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
}

contract StableDEXBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    StableDEX target;
    StableDEXHandler handler;

    function setUp() public {
        target = new StableDEX(address(0x1001), address(0x1001));
        handler = new StableDEXHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_sendto_txorigin13(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin11(address(0x1001), 1, address(0x1001));
        handler.call_sendto_txorigin1(address(0x1001), 1, address(0x1001));
        handler.call_withdrawAll_txorigin2(address(0x1001), address(0x1001));
        handler.call_sendto_txorigin17(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin7(address(0x1001), 1, address(0x1001));
        handler.call_sendto_txorigin37(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin3(address(0x1001), 1, address(0x1001));
        handler.call_sendto_txorigin9(address(0x1001), 1, address(0x1001));
        handler.call_sendto_txorigin25(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin19(address(0x1001), 1, address(0x1001));
        handler.call_withdrawAll_txorigin26(address(0x1001), address(0x1001));
        handler.call_setDexStatus(false);
        handler.call_transferTo_txorigin23(address(0x1001), 1, address(0x1001));
        handler.call_addToken(address(0x1001), "", 1);
        handler.call_withdrawAll_txorigin14(address(0x1001), address(0x1001));
        handler.call_deposit();
        handler.call_withdrawAll_txorigin30(address(0x1001), address(0x1001));
        handler.call_tokenDeposit(address(0x1001), 1);
        handler.call_bug_txorigin8(address(0x1001));
        handler.call_withdraw(1, address(0x1001), 1);
        handler.call_transferTo_txorigin39(address(0x1001), 1, address(0x1001));
        handler.call_adminProfitWithdraw(1, address(0x1001));
        handler.call_bug_txorigin36(address(0x1001));
        handler.call_transferTo_txorigin35(address(0x1001), 1, address(0x1001));
        handler.call_bug_txorigin40(address(0x1001));
        handler.call_sendto_txorigin33(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin27(address(0x1001), 1, address(0x1001));
        handler.call_transferTo_txorigin31(address(0x1001), 1, address(0x1001));
    }
}

contract StableDEXStateTransitionPropertyTest is StableDEXBasePropertyTest {

    function test_transition_fn_dexStatus_setDexStatus() public {
        handler.call_setDexStatus(false);
    }
}

contract StableDEXAccessPropertyTest is StableDEXBasePropertyTest {

    function test_property_access_setDexStatus() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setDexStatus(bool)", false));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_adminProfitWithdraw() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("adminProfitWithdraw(uint8,address)", 1, address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_setwithdrawfee() public {
        address[] memory acc_setwithdrawfee_addr = new address[](1);
        acc_setwithdrawfee_addr[0] = address(0x1001);
        uint256[] memory acc_setwithdrawfee_feeamount = new uint256[](1);
        acc_setwithdrawfee_feeamount[0] = 1;
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setwithdrawfee(address[],uint256[])", acc_setwithdrawfee_addr, acc_setwithdrawfee_feeamount));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}