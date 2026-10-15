// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/incorrect_constructor_name2.sol";

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
contract MissingHandler is LegacyCheatcodes {
    Missing public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Missing _target) public {
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

    function call_missing() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("missing()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdraw() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract MissingLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    Missing target;
    MissingHandler handler;

    function setUp() public {
        target = new Missing();
        handler = new MissingHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_missing();
        handler.call_withdraw();
    }
}