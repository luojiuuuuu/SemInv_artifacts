// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_36.sol";

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
contract MindsyncPlatformHandler is LegacyCheatcodes {
    MindsyncPlatform public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(MindsyncPlatform _target) public {
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

    function call_withdraw_balances_re_ent15() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_balances_re_ent15()"));
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

    function call_callme_re_ent42() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("callme_re_ent42()"));
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

    function call_withdraw_balances_re_ent36() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_balances_re_ent36()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_receiveApproval(address arg0,uint256 arg1,address arg2,bytes memory arg3) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = actors[uint256(keccak256(abi.encodePacked(arg2))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("receiveApproval(address,uint256,address,bytes)", arg0,arg1,arg2,arg3));
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

    function call_callme_re_ent28() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("callme_re_ent28()"));
        lastCallOk = ok;
        _vm().stopPrank();
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

    function call_claimReward_re_ent32() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_re_ent32()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_init(Token arg0,address arg1,uint256 arg2,uint256 arg3,uint256 arg4) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = uint256(uint256(arg3) % 1000);
        arg4 = uint256(uint256(arg4) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("init(contract,address,uint256,uint256,uint256)", arg0,arg1,arg2,arg3,arg4));
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

    function call_changeVotingRules(Token arg0,address arg1,uint256 arg2,uint256 arg3,uint256 arg4) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = uint256(uint256(arg3) % 1000);
        arg4 = uint256(uint256(arg4) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeVotingRules(contract,address,uint256,uint256,uint256)", arg0,arg1,arg2,arg3,arg4));
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

    function call_newProposal(address arg0,uint256 arg1,string memory arg2,bytes memory arg3) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("newProposal(address,uint256,string,bytes)", arg0,arg1,arg2,arg3));
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

    function call_sign(uint256 arg0,bool arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sign(uint256,bool)", arg0,arg1));
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

    function call_vote(uint256 arg0,bool arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("vote(uint256,bool)", arg0,arg1));
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

    function call_executeProposal(uint256 arg0,bytes memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("executeProposal(uint256,bytes)", arg0,arg1));
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
}

contract MindsyncPlatformBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    MindsyncPlatform target;
    MindsyncPlatformHandler handler;

    function setUp() public {
        target = new MindsyncPlatform();
        handler = new MindsyncPlatformHandler(target);
        _vm().deal(address(handler), 100 ether);
        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));
    }

    function _run_basic_sequence() internal {
        handler.call_withdraw_balances_re_ent15();
        handler.call_bug_re_ent41();
        handler.call_transferOwnership(address(0x1001));
        handler.call_callme_re_ent42();
        handler.call_claimReward_re_ent39();
        handler.call_withdraw_balances_re_ent36();
        handler.call_receiveApproval(address(0x1001), 1, address(0x1001), hex"");
        handler.call_buyTicket_re_ent2();
        handler.call_fallback();
        handler.call_withdrawFunds_re_ent17(1);
        handler.call_callme_re_ent28();
        handler.call_bug_re_ent34();
        handler.call_callme_re_ent21();
        handler.call_withdrawFunds_re_ent10(1);
        handler.call_withdraw_balances_re_ent21();
        handler.call_withdrawBalance_re_ent12();
        handler.call_claimReward_re_ent11();
        handler.call_withdraw_balances_re_ent1();
        handler.call_callme_re_ent35();
        handler.call_withdrawBalance_re_ent40();
        handler.call_withdrawBalance_re_ent33();
        handler.call_bug_re_ent27();
        handler.call_withdrawFunds_re_ent31(1);
        handler.call_bug_re_ent13();
        handler.call_claimReward_re_ent32();
        handler.call_init(Token(address(0x1001)), address(0x1001), 1, 1, 1);
        handler.call_withdrawFunds_re_ent38(1);
        handler.call_changeVotingRules(Token(address(0x1001)), address(0x1001), 1, 1, 1);
        handler.call_claimReward_re_ent4();
        handler.call_newProposal(address(0x1001), 1, "", hex"");
        handler.call_callme_re_ent7();
        handler.call_buyTicket_re_ent23();
        handler.call_sign(1, false);
        handler.call_callme_re_ent14();
        handler.call_vote(1, false);
        handler.call_buyTicket_re_ent30();
        handler.call_executeProposal(1, hex"");
        handler.call_withdraw_balances_re_ent8();
    }
}

contract MindsyncPlatformStateTransitionPropertyTest is MindsyncPlatformBasePropertyTest {

    function test_transition_fn_not_called_re_ent41_bug_re_ent41() public {
        handler.call_bug_re_ent41();
    }

    function test_transition_fn_not_called_re_ent27_bug_re_ent27() public {
        handler.call_bug_re_ent27();
    }

    function test_transition_fn_initialized_init() public {
        handler.call_init(Token(address(0x1001)), address(0x1001), 1, 1, 1);
    }

    function test_transition_fn_not_called_re_ent13_bug_re_ent13() public {
        handler.call_bug_re_ent13();
    }

    function test_transition_fn_not_called_re_ent34_bug_re_ent34() public {
        handler.call_bug_re_ent34();
    }
}

contract MindsyncPlatformAccessPropertyTest is MindsyncPlatformBasePropertyTest {

    function test_property_access_bug_re_ent41() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent41()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_transferOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_bug_re_ent34() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent34()"));
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

    function test_property_access_init() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("init(contract,address,uint256,uint256,uint256)", Token(address(0x1001)), address(0x1001), 1, 1, 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}