// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_35.sol";

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
contract BitpayerDEXHandler is LegacyCheatcodes {
    BitpayerDEX public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(BitpayerDEX _target) public {
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

    function call_my_func_unchk11(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_unchk11(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callnotchecked_unchk1(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("callnotchecked_unchk1(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendToWinner_unchk44() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk44()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callnotchecked_unchk37(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("callnotchecked_unchk37(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_onlyOwnerTransferOwnership(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("onlyOwnerTransferOwnership(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk3(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk3(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_acceptOwnership() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("acceptOwnership()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawLeftOver_unchk9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk9()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawBal_unchk41() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBal_unchk41()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk42() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk42()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_unhandledsend_unchk2(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhandledsend_unchk2(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk43() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk43()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_uncheck48(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_uncheck48(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawBal_unchk17() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBal_unchk17()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_UncheckedExternalCall_unchk40() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("UncheckedExternalCall_unchk40()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawLeftOver_unchk33() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk33()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk27(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk27(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk31() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk31()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawLeftOver_unchk45() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk45()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callnotchecked_unchk13(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("callnotchecked_unchk13(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callnotchecked_unchk25(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("callnotchecked_unchk25(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_changeSafeguardStatus() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeSafeguardStatus()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk19() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk19()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_unhandledsend_unchk26(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhandledsend_unchk26(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_changeFeeAccount(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeFeeAccount(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendToWinner_unchk20() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk20()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_changetradingFee(uint256 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changetradingFee(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendToWinner_unchk32() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk32()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_unhandledsend_unchk38(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhandledsend_unchk38(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawTradingFeeOwner() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawTradingFeeOwner()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_cash_unchk46(uint256 arg0,uint256 arg1,address payable arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("cash_unchk46(uint256,uint256,address)", arg0,arg1,arg2));
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

    function call_UncheckedExternalCall_unchk4() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("UncheckedExternalCall_unchk4()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk7() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk7()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_depositToken(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("depositToken(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_unchk23(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_unchk23(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawToken(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawToken(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_unhandledsend_unchk14(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhandledsend_unchk14(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk30() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk30()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_order(address arg0,uint256 arg1,address arg2,uint256 arg3,uint256 arg4,uint256 arg5) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        arg3 = uint256(uint256(arg3) % 1000);
        arg4 = uint256(uint256(arg4) % 1000);
        arg5 = uint256(uint256(arg5) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("order(address,uint256,address,uint256,uint256,uint256)", arg0,arg1,arg2,arg3,arg4,arg5));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendToWinner_unchk8() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk8()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_trade(address arg0,uint256 arg1,address arg2,uint256 arg3,uint256 arg4,uint256 arg5,address arg6,uint8 arg7,bytes32 arg8,bytes32 arg9,uint256 arg10) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        arg3 = uint256(uint256(arg3) % 1000);
        arg4 = uint256(uint256(arg4) % 1000);
        arg5 = uint256(uint256(arg5) % 1000);
        arg6 = actors[uint256(keccak256(abi.encodePacked(arg6))) % actors.length];
        arg7 = uint8(uint256(arg7) % 256);
        arg10 = uint256(uint256(arg10) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("trade(address,uint256,address,uint256,uint256,uint256,address,uint8,bytes32,bytes32,uint256)", arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_unchk39(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_unchk39(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_uncheck36(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_uncheck36(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_unchk35(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_unchk35(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_cancelOrder(address arg0,uint256 arg1,address arg2,uint256 arg3,uint256 arg4,uint256 arg5,uint8 arg6,bytes32 arg7,bytes32 arg8) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        arg3 = uint256(uint256(arg3) % 1000);
        arg4 = uint256(uint256(arg4) % 1000);
        arg5 = uint256(uint256(arg5) % 1000);
        arg6 = uint8(uint256(arg6) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("cancelOrder(address,uint256,address,uint256,uint256,uint256,uint8,bytes32,bytes32)", arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract BitpayerDEXBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    BitpayerDEX target;
    BitpayerDEXHandler handler;

    function setUp() public {
        target = new BitpayerDEX();
        handler = new BitpayerDEXHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_my_func_unchk11(address(0x1001));
        handler.call_callnotchecked_unchk1(address(0x1001));
        handler.call_sendToWinner_unchk44();
        handler.call_callnotchecked_unchk37(address(0x1001));
        handler.call_onlyOwnerTransferOwnership(address(0x1001));
        handler.call_bug_unchk3(address(0x1001));
        handler.call_acceptOwnership();
        handler.call_withdrawLeftOver_unchk9();
        handler.call_withdrawBal_unchk41();
        handler.call_bug_unchk42();
        handler.call_unhandledsend_unchk2(address(0x1001));
        handler.call_bug_unchk43();
        handler.call_my_func_uncheck48(address(0x1001));
        handler.call_withdrawBal_unchk17();
        handler.call_UncheckedExternalCall_unchk40();
        handler.call_withdrawLeftOver_unchk33();
        handler.call_bug_unchk27(address(0x1001));
        handler.call_bug_unchk31();
        handler.call_withdrawLeftOver_unchk45();
        handler.call_callnotchecked_unchk13(address(0x1001));
        handler.call_callnotchecked_unchk25(address(0x1001));
        handler.call_changeSafeguardStatus();
        handler.call_bug_unchk19();
        handler.call_unhandledsend_unchk26(address(0x1001));
        handler.call_changeFeeAccount(address(0x1001));
        handler.call_sendToWinner_unchk20();
        handler.call_changetradingFee(1);
        handler.call_sendToWinner_unchk32();
        handler.call_unhandledsend_unchk38(address(0x1001));
        handler.call_withdrawTradingFeeOwner();
        handler.call_cash_unchk46(1, 1, address(0x1001));
        handler.call_deposit();
        handler.call_UncheckedExternalCall_unchk4();
        handler.call_withdraw(1);
        handler.call_bug_unchk7();
        handler.call_depositToken(address(0x1001), 1);
        handler.call_my_func_unchk23(address(0x1001));
        handler.call_withdrawToken(address(0x1001), 1);
        handler.call_unhandledsend_unchk14(address(0x1001));
        handler.call_bug_unchk30();
        handler.call_order(address(0x1001), 1, address(0x1001), 1, 1, 1);
        handler.call_sendToWinner_unchk8();
        handler.call_trade(address(0x1001), 1, address(0x1001), 1, 1, 1, address(0x1001), 1, bytes32(0), bytes32(0), 1);
        handler.call_bug_unchk39(address(0x1001));
        handler.call_my_func_uncheck36(address(0x1001));
        handler.call_my_func_unchk35(address(0x1001));
        handler.call_cancelOrder(address(0x1001), 1, address(0x1001), 1, 1, 1, 1, bytes32(0), bytes32(0));
    }
}

contract BitpayerDEXStateTransitionPropertyTest is BitpayerDEXBasePropertyTest {

    function test_transition_fn_safeGuard_changeSafeguardStatus() public {
        handler.call_changeSafeguardStatus();
    }

    function test_transition_fn_payedOut_unchk8_sendToWinner_unchk8() public {
        handler.call_sendToWinner_unchk8();
    }

    function test_transition_fn_payedOut_unchk44_sendToWinner_unchk44() public {
        handler.call_sendToWinner_unchk44();
    }

    function test_transition_fn_payedOut_unchk20_sendToWinner_unchk20() public {
        handler.call_sendToWinner_unchk20();
    }

    function test_transition_fn_payedOut_unchk32_sendToWinner_unchk32() public {
        handler.call_sendToWinner_unchk32();
    }
}

contract BitpayerDEXAccessPropertyTest is BitpayerDEXBasePropertyTest {

    function test_property_access_onlyOwnerTransferOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("onlyOwnerTransferOwnership(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_acceptOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("acceptOwnership()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_changeSafeguardStatus() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeSafeguardStatus()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_changeFeeAccount() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeFeeAccount(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_changetradingFee() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changetradingFee(uint256)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_withdrawTradingFeeOwner() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawTradingFeeOwner()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract BitpayerDEXLegacyTerminalSupplementTest is BitpayerDEXBasePropertyTest {

    function test_supplement_payedOut_unchk8_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk8()) {
            uint256 curr = handler.curr_payedOut_unchk8();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_payedOut_unchk44_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk44()) {
            uint256 curr = handler.curr_payedOut_unchk44();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_payedOut_unchk20_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk20()) {
            uint256 curr = handler.curr_payedOut_unchk20();
            _assertTrue(curr == 1);
        }
    }

    function test_supplement_payedOut_unchk32_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk32()) {
            uint256 curr = handler.curr_payedOut_unchk32();
            _assertTrue(curr == 1);
        }
    }
}

contract BitpayerDEXLegacyEthFlowSupplementTest is BitpayerDEXBasePropertyTest {

    function test_supplement_eth_balance_bound_0_winAmount_unchk44() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.winAmount_unchk44() <= address(target).balance);
    }

    function test_supplement_eth_balance_bound_1_winAmount_unchk20() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.winAmount_unchk20() <= address(target).balance);
    }

    function test_supplement_eth_balance_bound_2_winAmount_unchk32() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.winAmount_unchk32() <= address(target).balance);
    }
}
