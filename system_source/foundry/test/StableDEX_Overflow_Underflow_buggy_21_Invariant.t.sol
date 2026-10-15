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

    function call_increaseLockTime_intou13(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou13(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou13() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou13()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou11() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou11()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou1(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou1(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_ovrflow1() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_ovrflow1()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_undrflow2(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_undrflow2(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou17(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou17(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou17() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou17()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou7() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou7()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou37(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou37(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou37() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou37()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou3() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou3()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou9(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou9(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou9() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou9()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou25(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou25(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou25() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou25()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou19() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou19()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou26(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou26(address,uint256)", arg0,arg1));
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

    function call_bug_intou23() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou23()"));
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

    function call_transfer_intou14(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou14(address,uint256)", arg0,arg1));
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

    function call_transfer_intou30(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou30(address,uint256)", arg0,arg1));
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

    function call_bug_intou8(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou8(uint8)", arg0));
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

    function call_bug_intou39() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou39()"));
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

    function call_bug_intou36(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou36(uint8)", arg0));
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

    function call_bug_intou35() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou35()"));
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

    function call_bug_intou40(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou40(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou33(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou33(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou33() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou33()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou27() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou27()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou31() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou31()"));
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
        handler.call_increaseLockTime_intou13(1);
        handler.call_withdraw_intou13();
        handler.call_bug_intou11();
        handler.call_increaseLockTime_intou1(1);
        handler.call_withdraw_ovrflow1();
        handler.call_transfer_undrflow2(address(0x1001), 1);
        handler.call_increaseLockTime_intou17(1);
        handler.call_withdraw_intou17();
        handler.call_bug_intou7();
        handler.call_increaseLockTime_intou37(1);
        handler.call_withdraw_intou37();
        handler.call_bug_intou3();
        handler.call_increaseLockTime_intou9(1);
        handler.call_withdraw_intou9();
        handler.call_increaseLockTime_intou25(1);
        handler.call_withdraw_intou25();
        handler.call_bug_intou19();
        handler.call_transfer_intou26(address(0x1001), 1);
        handler.call_setDexStatus(false);
        handler.call_bug_intou23();
        handler.call_addToken(address(0x1001), "", 1);
        handler.call_transfer_intou14(address(0x1001), 1);
        handler.call_deposit();
        handler.call_transfer_intou30(address(0x1001), 1);
        handler.call_tokenDeposit(address(0x1001), 1);
        handler.call_bug_intou8(1);
        handler.call_withdraw(1, address(0x1001), 1);
        handler.call_bug_intou39();
        handler.call_adminProfitWithdraw(1, address(0x1001));
        handler.call_bug_intou36(1);
        handler.call_bug_intou35();
        handler.call_bug_intou40(1);
        handler.call_increaseLockTime_intou33(1);
        handler.call_withdraw_intou33();
        handler.call_bug_intou27();
        handler.call_bug_intou31();
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