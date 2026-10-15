// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_33.sol";

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
contract StakingHandler is LegacyCheatcodes {
    Staking public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Staking _target) public {
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

    function call_buyTicket_re_ent2() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("buyTicket_re_ent2()"));
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

    function call_bug_re_ent27() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent27()"));
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

    function call_buyTicket_re_ent37() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("buyTicket_re_ent37()"));
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

    function call_claimReward_re_ent25() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward_re_ent25()"));
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

    function call_bug_re_ent20() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent20()"));
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

    function call_startStaking(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("startStaking(uint256)", arg0));
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

    function call_redeem() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("redeem()"));
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

    function call_changeStakeTokens(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeStakeTokens(uint256)", arg0));
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

    function call_changeStakeTime(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeStakeTime(uint256)", arg0));
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

    function call_changeStakingPercentage(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeStakingPercentage(uint256)", arg0));
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

    function call_lockWithdrawals() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("lockWithdrawals()"));
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
}

contract StakingBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    Staking target;
    StakingHandler handler;

    function setUp() public {
        target = new Staking(address(0x1001));
        handler = new StakingHandler(target);
        _vm().deal(address(handler), 100 ether);
        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));
    }

    function _run_basic_sequence() internal {
        handler.call_buyTicket_re_ent2();
        handler.call_withdrawFunds_re_ent17(1);
        handler.call_bug_re_ent27();
        handler.call_claimReward_re_ent32();
        handler.call_transferOwnership(address(0x1001));
        handler.call_withdrawFunds_re_ent38(1);
        handler.call_buyTicket_re_ent37();
        handler.call_withdrawFunds_re_ent3(1);
        handler.call_buyTicket_re_ent9();
        handler.call_claimReward_re_ent25();
        handler.call_withdrawBalance_re_ent19();
        handler.call_withdrawBalance_re_ent26();
        handler.call_withdrawFunds_re_ent31(1);
        handler.call_bug_re_ent13();
        handler.call_bug_re_ent20();
        handler.call_callme_re_ent14();
        handler.call_startStaking(1);
        handler.call_buyTicket_re_ent30();
        handler.call_redeem();
        handler.call_withdraw_balances_re_ent8();
        handler.call_changeStakeTokens(1);
        handler.call_claimReward_re_ent39();
        handler.call_changeStakeTime(1);
        handler.call_withdraw_balances_re_ent36();
        handler.call_changeStakingPercentage(1);
        handler.call_callme_re_ent35();
        handler.call_lockWithdrawals();
        handler.call_withdrawBalance_re_ent40();
        handler.call_withdrawBalance_re_ent33();
    }
}

contract StakingStateTransitionPropertyTest is StakingBasePropertyTest {

    function test_transition_fn_not_called_re_ent13_bug_re_ent13() public {
        handler.call_bug_re_ent13();
    }

    function test_transition_fn_lock_lockWithdrawals() public {
        handler.call_lockWithdrawals();
    }

    function test_transition_fn_not_called_re_ent20_bug_re_ent20() public {
        handler.call_bug_re_ent20();
    }

    function test_transition_fn_not_called_re_ent27_bug_re_ent27() public {
        handler.call_bug_re_ent27();
    }
}

contract StakingAccessPropertyTest is StakingBasePropertyTest {

    function test_property_access_bug_re_ent27() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent27()"));
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

    function test_property_access_lockWithdrawals() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("lockWithdrawals()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract StakingLegacyTerminalSupplementTest is StakingBasePropertyTest {

    function test_supplement_lock_terminal_absorbing() public {
        // invariant: I3.state.terminal_absorbing
        _run_basic_sequence();
        if(handler.entered_terminal_lock()) {
            uint256 curr = handler.curr_lock();
            _assertTrue(curr == 1);
        }
    }
}
