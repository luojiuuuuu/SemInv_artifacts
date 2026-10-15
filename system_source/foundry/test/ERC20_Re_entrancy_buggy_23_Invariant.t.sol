// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_23.sol";

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
contract ERC20Handler is LegacyCheatcodes {
    ERC20 public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(ERC20 _target) public {
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

    function call_bug_re_ent20() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent20()"));
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

    function call_increaseAllowance(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseAllowance(address,uint256)", arg0,arg1));
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

    function call_decreaseAllowance(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("decreaseAllowance(address,uint256)", arg0,arg1));
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

    function call_callme_re_ent14() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("callme_re_ent14()"));
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
}

contract ERC20BasePropertyTest is SimpleAssert, LegacyCheatcodes {
    ERC20 target;
    ERC20Handler handler;

    function setUp() public {
        target = new ERC20();
        handler = new ERC20Handler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_transfer(address(0x1001), 1);
        handler.call_approve(address(0x1001), 1);
        handler.call_transferFrom(address(0x1001), address(0x1001), 1);
        handler.call_callme_re_ent42();
        handler.call_buyTicket_re_ent2();
        handler.call_withdrawFunds_re_ent17(1);
        handler.call_claimReward_re_ent25();
        handler.call_withdrawBalance_re_ent19();
        handler.call_withdrawBalance_re_ent26();
        handler.call_bug_re_ent20();
        handler.call_claimReward_re_ent32();
        handler.call_withdrawFunds_re_ent38(1);
        handler.call_increaseAllowance(address(0x1001), 1);
        handler.call_claimReward_re_ent4();
        handler.call_decreaseAllowance(address(0x1001), 1);
        handler.call_callme_re_ent7();
        handler.call_buyTicket_re_ent23();
        handler.call_callme_re_ent14();
        handler.call_buyTicket_re_ent30();
        handler.call_withdraw_balances_re_ent8();
        handler.call_claimReward_re_ent39();
    }
}

contract ERC20AccountingPropertyTest is ERC20BasePropertyTest {

    function test_property_accounting_0() public {
        _run_basic_sequence();
        uint256 sum = 0;
        uint256 n = handler.actorCount();
        for(uint256 i = 0; i < n; i++){
            address a = handler.actor(i);
            sum += target.balanceOf(a);
        }
        _assertTrue(sum <= target.totalSupply());
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
}

contract ERC20StateTransitionPropertyTest is ERC20BasePropertyTest {

    function test_transition_fn_not_called_re_ent20_bug_re_ent20() public {
        handler.call_bug_re_ent20();
    }
}

contract ERC20AccessPropertyTest is ERC20BasePropertyTest {

    function test_property_access_bug_re_ent20() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_re_ent20()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}