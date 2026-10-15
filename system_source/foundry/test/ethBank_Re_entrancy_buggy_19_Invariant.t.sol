// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_19.sol";

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
contract ethBankHandler is LegacyCheatcodes {
    ethBank public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(ethBank _target) public {
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

    function call_buyTicket_re_ent2() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("buyTicket_re_ent2()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawForUser(address payable arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawForUser(address,uint256)", arg0,arg1));
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

    function call_moveBrick(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("moveBrick(uint256)", arg0));
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

    function call_moveBrickContracts() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("moveBrickContracts()"));
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

    function call_moveBrickClear() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("moveBrickClear()"));
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

    function call_joinFlexible() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("joinFlexible()"));
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

    function call_joinFixed() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("joinFixed()"));
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

    function call_staticBonus() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("staticBonus()"));
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

    function call_activeBonus() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonus()"));
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

    function call_teamAddBonus() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("teamAddBonus()"));
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

    function call_staticBonusCacl() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("staticBonusCacl()"));
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

    function call_activeBonusCacl_1() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_1()"));
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

    function call_activeBonusCacl_2() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_2()"));
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

    function call_activeBonusCacl_3() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_3()"));
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

    function call_activeBonusCacl_4() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_4()"));
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

    function call_activeBonusCacl_5() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_5()"));
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

    function call_activeBonusCacl_6() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_6()"));
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

    function call_activeBonusCacl_7() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_7()"));
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

    function call_activeBonusCacl_8() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_8()"));
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

    function call_activeBonusCacl_9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("activeBonusCacl_9()"));
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

    function call_teamAddBonusCacl() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("teamAddBonusCacl()"));
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

    function call_caclTeamPerformance() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("caclTeamPerformance()"));
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

    function call_releaStaticBonus() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("releaStaticBonus()"));
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

    function call_releaActiveBonus() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("releaActiveBonus()"));
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

    function call_releaTeamAddBonus() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("releaTeamAddBonus()"));
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
}

contract ethBankBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    ethBank target;
    ethBankHandler handler;

    function setUp() public {
        target = new ethBank();
        handler = new ethBankHandler(target);
        _vm().deal(address(handler), 100 ether);
        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));
    }

    function _run_basic_sequence() internal {
        handler.call_withdraw_balances_re_ent1();
        handler.call_bug_re_ent41();
        handler.call_transferOwnership(address(0x1001));
        handler.call_callme_re_ent42();
        handler.call_fallback();
        handler.call_buyTicket_re_ent2();
        handler.call_withdrawForUser(address(0x1001), 1);
        handler.call_withdrawFunds_re_ent17(1);
        handler.call_moveBrick(1);
        handler.call_buyTicket_re_ent37();
        handler.call_moveBrickContracts();
        handler.call_withdrawFunds_re_ent3(1);
        handler.call_moveBrickClear();
        handler.call_buyTicket_re_ent9();
        handler.call_joinFlexible();
        handler.call_claimReward_re_ent25();
        handler.call_joinFixed();
        handler.call_withdrawBalance_re_ent19();
        handler.call_staticBonus();
        handler.call_withdrawBalance_re_ent26();
        handler.call_activeBonus();
        handler.call_bug_re_ent20();
        handler.call_teamAddBonus();
        handler.call_claimReward_re_ent32();
        handler.call_staticBonusCacl();
        handler.call_withdrawFunds_re_ent38(1);
        handler.call_activeBonusCacl_1();
        handler.call_claimReward_re_ent4();
        handler.call_activeBonusCacl_2();
        handler.call_callme_re_ent7();
        handler.call_activeBonusCacl_3();
        handler.call_buyTicket_re_ent23();
        handler.call_activeBonusCacl_4();
        handler.call_callme_re_ent14();
        handler.call_activeBonusCacl_5();
        handler.call_buyTicket_re_ent30();
        handler.call_activeBonusCacl_6();
        handler.call_withdraw_balances_re_ent8();
        handler.call_activeBonusCacl_7();
        handler.call_claimReward_re_ent39();
        handler.call_activeBonusCacl_8();
        handler.call_withdraw_balances_re_ent36();
        handler.call_activeBonusCacl_9();
        handler.call_callme_re_ent35();
        handler.call_teamAddBonusCacl();
        handler.call_withdrawBalance_re_ent40();
        handler.call_caclTeamPerformance();
        handler.call_withdrawBalance_re_ent33();
        handler.call_releaStaticBonus();
        handler.call_bug_re_ent27();
        handler.call_releaActiveBonus();
        handler.call_withdrawFunds_re_ent31(1);
        handler.call_releaTeamAddBonus();
        handler.call_bug_re_ent13();
    }
}

contract ethBankStateTransitionPropertyTest is ethBankBasePropertyTest {

    function test_transition_fn_not_called_re_ent20_bug_re_ent20() public {
        handler.call_bug_re_ent20();
    }

    function test_transition_fn_not_called_re_ent27_bug_re_ent27() public {
        handler.call_bug_re_ent27();
    }

    function test_transition_fn_not_called_re_ent13_bug_re_ent13() public {
        handler.call_bug_re_ent13();
    }

    function test_transition_fn_not_called_re_ent41_bug_re_ent41() public {
        handler.call_bug_re_ent41();
    }
}

contract ethBankAccessPropertyTest is ethBankBasePropertyTest {

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

    function test_property_access_bug_re_ent20() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent20()"));
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
}