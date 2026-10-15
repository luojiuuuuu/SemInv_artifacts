// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/overflow_single_tx.sol";

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
    function _assertTrue(bool x) internal pure { require(x); }
    function _assertEq(uint256 a, uint256 b) internal pure { require(a == b); }
}
contract IntegerOverflowSingleTransactionHandler is LegacyCheatcodes {
    IntegerOverflowSingleTransaction public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(IntegerOverflowSingleTransaction _target) public {
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

    function call_overflowaddtostate(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("overflowaddtostate(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_overflowmultostate(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("overflowmultostate(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_underflowtostate(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("underflowtostate(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_overflowlocalonly(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("overflowlocalonly(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_overflowmulocalonly(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("overflowmulocalonly(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_underflowlocalonly(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("underflowlocalonly(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract IntegerOverflowSingleTransactionLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    IntegerOverflowSingleTransaction target;
    IntegerOverflowSingleTransactionHandler handler;

    function setUp() public {
        target = new IntegerOverflowSingleTransaction();
        handler = new IntegerOverflowSingleTransactionHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_overflowaddtostate(1);
        handler.call_overflowmultostate(1);
        handler.call_underflowtostate(1);
        handler.call_overflowlocalonly(1);
        handler.call_overflowmulocalonly(1);
        handler.call_underflowlocalonly(1);
    }
}
