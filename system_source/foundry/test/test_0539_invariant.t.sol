// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/guess_the_random_number.sol";

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
contract GuessTheRandomNumberChallengeHandler is LegacyCheatcodes {
    GuessTheRandomNumberChallenge public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(GuessTheRandomNumberChallenge _target) public {
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

    function call_GuessTheRandomNumberChallenge() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("GuessTheRandomNumberChallenge()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_guess(uint8 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint8(uint256(arg0) % 256);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("guess(uint8)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract GuessTheRandomNumberChallengeLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    GuessTheRandomNumberChallenge target;
    GuessTheRandomNumberChallengeHandler handler;

    function setUp() public {
        target = new GuessTheRandomNumberChallenge();
        handler = new GuessTheRandomNumberChallengeHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_GuessTheRandomNumberChallenge();
        handler.call_guess(1);
    }
}