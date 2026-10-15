// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/0x0cbe050f75bc8f8c2d6c0d249fea125fd6e1acc9.sol";

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
contract CallerHandler is LegacyCheatcodes {
    Caller public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Caller _target) public {
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

    function call_callAddress(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("callAddress(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract CallerLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    Caller target;
    CallerHandler handler;

    function setUp() public {
        target = new Caller();
        handler = new CallerHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_callAddress(address(0x1001));
    }
}