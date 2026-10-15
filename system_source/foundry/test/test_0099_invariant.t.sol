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

    function call_bug_re_ent34() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent34()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callme_re_ent21() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("callme_re_ent21()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_balances_re_ent36() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_balances_re_ent36()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callme_re_ent42() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("callme_re_ent42()"));
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

    function call_buyTicket_re_ent2() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("buyTicket_re_ent2()"));
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

    function call_withdrawFunds_re_ent17(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawFunds_re_ent17(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawFunds_re_ent10(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawFunds_re_ent10(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_balances_re_ent21() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_balances_re_ent21()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawBalance_re_ent12() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBalance_re_ent12()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_re_ent11() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_re_ent11()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_balances_re_ent1() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_balances_re_ent1()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_re_ent41() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent41()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_callme_re_ent35() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("callme_re_ent35()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawBalance_re_ent40() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBalance_re_ent40()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawBalance_re_ent33() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBalance_re_ent33()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_re_ent27() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent27()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawFunds_re_ent31(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawFunds_re_ent31(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_re_ent13() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent13()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_buyTicket_re_ent37() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("buyTicket_re_ent37()"));
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

    function call_withdrawFunds_re_ent3(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawFunds_re_ent3(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_buyTicket_re_ent9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("buyTicket_re_ent9()"));
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

    function call_claimReward_re_ent25() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_re_ent25()"));
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

    function call_withdrawBalance_re_ent19() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBalance_re_ent19()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawBalance_re_ent26() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBalance_re_ent26()"));
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

    function call_bug_re_ent20() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent20()"));
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

    function call_claimReward_re_ent32() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_re_ent32()"));
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

    function call_withdrawFunds_re_ent38(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawFunds_re_ent38(uint256)", arg0));
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

    function call_claimReward_re_ent4() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_re_ent4()"));
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

    function call_callme_re_ent7() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("callme_re_ent7()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_buyTicket_re_ent23() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("buyTicket_re_ent23()"));
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

    function call_callme_re_ent14() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("callme_re_ent14()"));
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

    function call_buyTicket_re_ent30() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("buyTicket_re_ent30()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_balances_re_ent8() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_balances_re_ent8()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward_re_ent39() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_re_ent39()"));
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
        handler.call_bug_re_ent34();
        handler.call_callme_re_ent21();
        handler.call_withdraw_balances_re_ent36();
        handler.call_callme_re_ent42();
        handler.call_onlyOwnerTransferOwnership(address(0x1001));
        handler.call_buyTicket_re_ent2();
        handler.call_acceptOwnership();
        handler.call_withdrawFunds_re_ent17(1);
        handler.call_withdrawFunds_re_ent10(1);
        handler.call_withdraw_balances_re_ent21();
        handler.call_withdrawBalance_re_ent12();
        handler.call_claimReward_re_ent11();
        handler.call_withdraw_balances_re_ent1();
        handler.call_bug_re_ent41();
        handler.call_callme_re_ent35();
        handler.call_withdrawBalance_re_ent40();
        handler.call_withdrawBalance_re_ent33();
        handler.call_bug_re_ent27();
        handler.call_withdrawFunds_re_ent31(1);
        handler.call_bug_re_ent13();
        handler.call_buyTicket_re_ent37();
        handler.call_changeSafeguardStatus();
        handler.call_withdrawFunds_re_ent3(1);
        handler.call_buyTicket_re_ent9();
        handler.call_changeFeeAccount(address(0x1001));
        handler.call_claimReward_re_ent25();
        handler.call_changetradingFee(1);
        handler.call_withdrawBalance_re_ent19();
        handler.call_withdrawBalance_re_ent26();
        handler.call_withdrawTradingFeeOwner();
        handler.call_bug_re_ent20();
        handler.call_deposit();
        handler.call_claimReward_re_ent32();
        handler.call_withdraw(1);
        handler.call_withdrawFunds_re_ent38(1);
        handler.call_depositToken(address(0x1001), 1);
        handler.call_claimReward_re_ent4();
        handler.call_withdrawToken(address(0x1001), 1);
        handler.call_callme_re_ent7();
        handler.call_buyTicket_re_ent23();
        handler.call_order(address(0x1001), 1, address(0x1001), 1, 1, 1);
        handler.call_callme_re_ent14();
        handler.call_trade(address(0x1001), 1, address(0x1001), 1, 1, 1, address(0x1001), 1, bytes32(0), bytes32(0), 1);
        handler.call_buyTicket_re_ent30();
        handler.call_withdraw_balances_re_ent8();
        handler.call_claimReward_re_ent39();
        handler.call_cancelOrder(address(0x1001), 1, address(0x1001), 1, 1, 1, 1, bytes32(0), bytes32(0));
    }
}

contract BitpayerDEXStateTransitionPropertyTest is BitpayerDEXBasePropertyTest {

    function test_transition_fn_not_called_re_ent20_bug_re_ent20() public {
        handler.call_bug_re_ent20();
    }

    function test_transition_fn_not_called_re_ent27_bug_re_ent27() public {
        handler.call_bug_re_ent27();
    }

    function test_transition_fn_safeGuard_changeSafeguardStatus() public {
        handler.call_changeSafeguardStatus();
    }

    function test_transition_fn_not_called_re_ent13_bug_re_ent13() public {
        handler.call_bug_re_ent13();
    }

    function test_transition_fn_not_called_re_ent41_bug_re_ent41() public {
        handler.call_bug_re_ent41();
    }

    function test_transition_fn_not_called_re_ent34_bug_re_ent34() public {
        handler.call_bug_re_ent34();
    }
}

contract BitpayerDEXAccessPropertyTest is BitpayerDEXBasePropertyTest {

    function test_property_access_bug_re_ent34() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent34()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

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

    function test_property_access_bug_re_ent41() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent41()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_bug_re_ent27() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent27()"));
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

    function test_property_access_bug_re_ent20() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent20()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}