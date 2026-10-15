// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_47.sol";

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
contract AcunarIEOHandler is LegacyCheatcodes {
    AcunarIEO public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(AcunarIEO _target) public {
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

    function call_withdrawLeftOver_unchk9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk9()"));
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

    function call_sendToWinner_unchk20() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk20()"));
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

    function call_sendToWinner_unchk32() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk32()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_cash_unchk34(uint256 arg0,uint256 arg1,address payable arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("cash_unchk34(uint256,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawLeftOver_unchk21() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk21()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_cash_unchk10(uint256 arg0,uint256 arg1,address payable arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("cash_unchk10(uint256,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_unchk47(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_unchk47(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_cash_unchk22(uint256 arg0,uint256 arg1,address payable arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("cash_unchk22(uint256,uint256,address)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_my_func_uncheck12(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("my_func_uncheck12(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
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

    function call_UncheckedExternalCall_unchk4() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("UncheckedExternalCall_unchk4()"));
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

    function call_sendToWinner_unchk8() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk8()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_halt() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("halt()"));
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

    function call_unhalt() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhalt()"));
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

    function call_changeDepositAddress(address payable arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeDepositAddress(address)", arg0));
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

    function call_sendToWinner_unchk44() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendToWinner_unchk44()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_invest() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("invest()"));
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

    function call_withdrawLeftOver_unchk33() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawLeftOver_unchk33()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burn() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burn()"));
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
}

contract AcunarIEOBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    AcunarIEO target;
    AcunarIEOHandler handler;

    function setUp() public {
        target = new AcunarIEO(address(0x1001));
        handler = new AcunarIEOHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_withdrawLeftOver_unchk9();
        handler.call_callnotchecked_unchk25(address(0x1001));
        handler.call_transfer(address(0x1001), 1);
        handler.call_bug_unchk19();
        handler.call_unhandledsend_unchk26(address(0x1001));
        handler.call_approve(address(0x1001), 1);
        handler.call_sendToWinner_unchk20();
        handler.call_transferFrom(address(0x1001), address(0x1001), 1);
        handler.call_sendToWinner_unchk32();
        handler.call_cash_unchk34(1, 1, address(0x1001));
        handler.call_withdrawLeftOver_unchk21();
        handler.call_cash_unchk10(1, 1, address(0x1001));
        handler.call_my_func_unchk47(address(0x1001));
        handler.call_cash_unchk22(1, 1, address(0x1001));
        handler.call_my_func_uncheck12(address(0x1001));
        handler.call_my_func_unchk11(address(0x1001));
        handler.call_unhandledsend_unchk38(address(0x1001));
        handler.call_cash_unchk46(1, 1, address(0x1001));
        handler.call_UncheckedExternalCall_unchk4();
        handler.call_bug_unchk7();
        handler.call_my_func_unchk23(address(0x1001));
        handler.call_unhandledsend_unchk14(address(0x1001));
        handler.call_bug_unchk30();
        handler.call_callnotchecked_unchk1(address(0x1001));
        handler.call_withdrawBal_unchk41();
        handler.call_bug_unchk42();
        handler.call_unhandledsend_unchk2(address(0x1001));
        handler.call_bug_unchk43();
        handler.call_my_func_uncheck48(address(0x1001));
        handler.call_withdrawBal_unchk17();
        handler.call_callnotchecked_unchk37(address(0x1001));
        handler.call_bug_unchk3(address(0x1001));
        handler.call_callnotchecked_unchk13(address(0x1001));
        handler.call_sendToWinner_unchk8();
        handler.call_halt();
        handler.call_bug_unchk39(address(0x1001));
        handler.call_unhalt();
        handler.call_my_func_uncheck36(address(0x1001));
        handler.call_changeDepositAddress(address(0x1001));
        handler.call_my_func_unchk35(address(0x1001));
        handler.call_sendToWinner_unchk44();
        handler.call_invest();
        handler.call_UncheckedExternalCall_unchk40();
        handler.call_fallback();
        handler.call_withdrawLeftOver_unchk33();
        handler.call_burn();
        handler.call_bug_unchk27(address(0x1001));
        handler.call_bug_unchk31();
        handler.call_withdrawLeftOver_unchk45();
    }
}

contract AcunarIEOAccountingPropertyTest is AcunarIEOBasePropertyTest {

    function test_property_accounting_0() public {
        _run_basic_sequence();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            sum += target.balances(a);
        }
        _assertTrue(sum <= target.raisedAmount());
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

    function test_property_accounting_1() public {
        _run_basic_sequence();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            sum += target.balances(a);
        }
        _assertTrue(sum <= target.supply());
    }

    function test_property_eth_conservation_1() public {
        _run_basic_sequence();
        uint256 totalSent = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            totalSent += handler.ethSent(handler.actor(i));
        }
        _assertTrue(address(target).balance <= totalSent);
    }
}

contract AcunarIEOAccountingAnomalyPropertyTest is AcunarIEOBasePropertyTest {

    function test_property_accounting_anomaly_0_burn() public {
        // anomaly reason: updates mapping but not paired supply
        handler.call_burn();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            sum += target.balances(handler.actor(i));
        }
        _assertEq(sum, target.raisedAmount());
    }
}

contract AcunarIEOStateTransitionPropertyTest is AcunarIEOBasePropertyTest {

    function test_transition_fn_payedOut_unchk20_sendToWinner_unchk20() public {
        handler.call_sendToWinner_unchk20();
    }

    function test_transition_fn_ieoState_halt() public {
        handler.call_halt();
    }

    function test_transition_fn_ieoState_unhalt() public {
        handler.call_unhalt();
    }

    function test_transition_fn_ieoState_invest() public {
        handler.call_invest();
    }

    function test_transition_fn_ieoState___fallback__() public {
        handler.call_fallback();
    }

    function test_transition_fn_ieoState_burn() public {
        handler.call_burn();
    }

    function test_transition_fn_payedOut_unchk44_sendToWinner_unchk44() public {
        handler.call_sendToWinner_unchk44();
    }

    function test_transition_fn_payedOut_unchk8_sendToWinner_unchk8() public {
        handler.call_sendToWinner_unchk8();
    }

    function test_transition_fn_payedOut_unchk32_sendToWinner_unchk32() public {
        handler.call_sendToWinner_unchk32();
    }
}

contract AcunarIEOAccessPropertyTest is AcunarIEOBasePropertyTest {

    function test_property_access_halt() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("halt()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_unhalt() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("unhalt()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract AcunarIEOLegacyAccountingSupplementTest is AcunarIEOBasePropertyTest {

    function test_supplement_accounting_delta_0_burn() public {
        // invariant: I1.accounting.delta_consistency
        // anomaly reason: updates mapping but not paired supply
        handler.call_burn();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            sum += target.balances(handler.actor(i));
        }
        _assertEq(sum, target.raisedAmount());
    }
}

contract AcunarIEOLegacyTerminalSupplementTest is AcunarIEOBasePropertyTest {

    function test_supplement_payedOut_unchk20_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk20()) {
            uint256 curr = handler.curr_payedOut_unchk20();
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

    function test_supplement_payedOut_unchk8_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_payedOut_unchk8()) {
            uint256 curr = handler.curr_payedOut_unchk8();
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

contract AcunarIEOLegacyEthFlowSupplementTest is AcunarIEOBasePropertyTest {

    function test_supplement_eth_balance_bound_0_winAmount_unchk20() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.winAmount_unchk20() <= address(target).balance);
    }

    function test_supplement_eth_balance_bound_1_winAmount_unchk32() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.winAmount_unchk32() <= address(target).balance);
    }

    function test_supplement_eth_balance_bound_2_raisedAmount() public {
        // invariant: I1.accounting.eth_balance_consistency
        _run_basic_sequence();
        _assertTrue(target.raisedAmount() <= address(target).balance);
    }
}
