// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/list_dos.sol";

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
contract GovernmentHandler is LegacyCheatcodes {
    Government public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Government _target) public {
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

    function call_Government() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("Government()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_lendGovernmentMoney(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("lendGovernmentMoney(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_totalDebt() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("totalDebt()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_totalPayedOut() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("totalPayedOut()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_investInTheSystem() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("investInTheSystem()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_inheritToNextGeneration(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("inheritToNextGeneration(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getCreditorAddresses() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("getCreditorAddresses()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_getCreditorAmounts() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("getCreditorAmounts()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract GovernmentLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    Government target;
    GovernmentHandler handler;

    function setUp() public {
        target = new Government();
        handler = new GovernmentHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_Government();
        handler.call_lendGovernmentMoney(address(0x1001));
        handler.call_totalDebt();
        handler.call_totalPayedOut();
        handler.call_investInTheSystem();
        handler.call_inheritToNextGeneration(address(0x1001));
        handler.call_getCreditorAddresses();
        handler.call_getCreditorAmounts();
    }
}
