// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_44.sol";

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
contract OperatedHandler is LegacyCheatcodes {
    Operated public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Operated _target) public {
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

    function call_withdrawBalance_re_ent33() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBalance_re_ent33()"));
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
}

contract OperatedBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    Operated target;
    OperatedHandler handler;

    function setUp() public {
        target = new Operated();
        handler = new OperatedHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_withdrawBalance_re_ent12();
        handler.call_claimReward_re_ent11();
        handler.call_withdrawBalance_re_ent33();
        handler.call_callme_re_ent42();
        handler.call_buyTicket_re_ent2();
        handler.call_withdrawFunds_re_ent17(1);
        handler.call_buyTicket_re_ent37();
        handler.call_withdrawFunds_re_ent3(1);
        handler.call_buyTicket_re_ent9();
        handler.call_claimReward_re_ent25();
        handler.call_withdrawBalance_re_ent19();
        handler.call_withdrawBalance_re_ent26();
    }
}

contract OperatedStateTransitionPropertyTest is OperatedBasePropertyTest {
}