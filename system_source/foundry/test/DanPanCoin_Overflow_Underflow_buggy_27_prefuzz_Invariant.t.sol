// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/buggy_27.sol";

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
contract DanPanCoinHandler is LegacyCheatcodes {
    DanPanCoin public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(DanPanCoin _target) public {
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

    function call_transfer_intou10(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou10(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou22(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou22(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou12(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou12(uint8)", arg0));
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

    function call_transfer_intou34(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou34(address,uint256)", arg0,arg1));
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

    function call_increaseLockTime_intou21(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou21(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou21() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou21()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou18(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou18(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou29(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou29(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou29() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou29()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer_intou62(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou62(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou16(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou16(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou24(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou24(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_increaseLockTime_intou5(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("increaseLockTime_intou5(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw_intou5() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw_intou5()"));
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

    function call_bug_intou15() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou15()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou28(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou28(uint8)", arg0));
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

    function call_multiTransfer(address[] memory arg0,uint256[] memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("multiTransfer(address[],uint256[])", arg0,arg1));
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

    function call_bug_intou20(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou20(uint8)", arg0));
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

    function call_bug_intou32(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou32(uint8)", arg0));
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

    function call_transfer_intou38(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer_intou38(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_bug_intou4(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou4(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burn(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burn(uint256)", arg0));
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

    function call_bug_intou23() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou23()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burnFrom(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnFrom(address,uint256)", arg0,arg1));
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

    function call_NewDanPanAddress(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("NewDanPanAddress(address)", arg0));
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

    function call_NewDanPanPercent(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("NewDanPanPercent(uint256)", arg0));
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

    function call_bug_intou39() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("bug_intou39()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setWhitelistedTo(address arg0,bool arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("setWhitelistedTo(address,bool)", arg0,arg1));
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

    function call_setWhitelistedFrom(address arg0,bool arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("setWhitelistedFrom(address,bool)", arg0,arg1));
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
}

contract DanPanCoinBasePropertyTest is SimpleAssert, LegacyCheatcodes {
    DanPanCoin target;
    DanPanCoinHandler handler;

    function setUp() public {
        target = new DanPanCoin();
        handler = new DanPanCoinHandler(target);
        _vm().deal(address(handler), 100 ether);
        address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(handler)));
    }

    function _run_basic_sequence() internal {
        handler.call_transfer(address(0x1001), 1);
        handler.call_approve(address(0x1001), 1);
        handler.call_transferFrom(address(0x1001), address(0x1001), 1);
        handler.call_transfer_intou10(address(0x1001), 1);
        handler.call_transfer_intou22(address(0x1001), 1);
        handler.call_bug_intou12(1);
        handler.call_bug_intou11();
        handler.call_bug_intou40(1);
        handler.call_transfer_intou34(address(0x1001), 1);
        handler.call_transferOwnership(address(0x1001));
        handler.call_increaseLockTime_intou21(1);
        handler.call_withdraw_intou21();
        handler.call_transfer_intou18(address(0x1001), 1);
        handler.call_increaseLockTime_intou29(1);
        handler.call_withdraw_intou29();
        handler.call_transfer_intou62(address(0x1001), 1);
        handler.call_bug_intou16(1);
        handler.call_bug_intou24(1);
        handler.call_increaseLockTime_intou5(1);
        handler.call_withdraw_intou5();
        handler.call_increaseLockTime_intou33(1);
        handler.call_withdraw_intou33();
        handler.call_bug_intou27();
        handler.call_bug_intou31();
        handler.call_increaseLockTime_intou13(1);
        handler.call_withdraw_intou13();
        handler.call_bug_intou15();
        handler.call_bug_intou28(1);
        handler.call_increaseLockTime_intou1(1);
        handler.call_withdraw_ovrflow1();
        handler.call_transfer_undrflow2(address(0x1001), 1);
        handler.call_increaseLockTime_intou17(1);
        handler.call_withdraw_intou17();
        handler.call_increaseLockTime_intou37(1);
        handler.call_withdraw_intou37();
        handler.call_bug_intou3();
        handler.call_increaseLockTime_intou9(1);
        handler.call_withdraw_intou9();
        handler.call_increaseLockTime_intou25(1);
        handler.call_withdraw_intou25();
        handler.call_bug_intou19();
        handler.call_transfer_intou26(address(0x1001), 1);
        handler.call_bug_intou20(1);
        handler.call_increaseAllowance(address(0x1001), 1);
        handler.call_bug_intou32(1);
        handler.call_decreaseAllowance(address(0x1001), 1);
        handler.call_transfer_intou38(address(0x1001), 1);
        handler.call_bug_intou4(1);
        handler.call_burn(1);
        handler.call_bug_intou7();
        handler.call_bug_intou23();
        handler.call_burnFrom(address(0x1001), 1);
        handler.call_transfer_intou14(address(0x1001), 1);
        handler.call_NewDanPanAddress(address(0x1001));
        handler.call_transfer_intou30(address(0x1001), 1);
        handler.call_NewDanPanPercent(1);
        handler.call_bug_intou8(1);
        handler.call_bug_intou39();
        handler.call_setWhitelistedTo(address(0x1001), false);
        handler.call_bug_intou36(1);
        handler.call_setWhitelistedFrom(address(0x1001), false);
        handler.call_bug_intou35();
    }
}

contract DanPanCoinAccountingPropertyTest is DanPanCoinBasePropertyTest {

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

contract DanPanCoinAccessPropertyTest is DanPanCoinBasePropertyTest {

    function test_property_access_transferOwnership() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwnership(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_burnFrom() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnFrom(address,uint256)", address(0x1001), 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_setWhitelistedTo() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setWhitelistedTo(address,bool)", address(0x1001), false));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_setWhitelistedFrom() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setWhitelistedFrom(address,bool)", address(0x1001), false));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}