// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0 <0.7.0;
import "../src/Splitter_0612.sol";

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
contract Splitter_0612Handler is LegacyCheatcodes {
    Splitter_0612 public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(Splitter_0612 _target) public {
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

    function call_receive() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)("");
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_fallback() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(hex"01");
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract Splitter_0612BasePropertyTest is SimpleAssert, LegacyCheatcodes {
    Splitter_0612 target;
    Splitter_0612Handler handler;

    function setUp() public {
        target = new Splitter_0612(address(0x1001), address(0x1001), IPinger(address(0x1001)));
        handler = new Splitter_0612Handler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_receive();
        handler.call_fallback();
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-property tests for legacy Solidity harnesses.
// This legacy subset avoids modern-only try/catch and low-level call tuple syntax.

contract Splitter_0612LegacyEthFlowSupplementTest is Splitter_0612BasePropertyTest {

    function test_supplement_receive_no_retained_eth() public {
        // invariant: I4.transaction.receive_no_retained_eth
        uint256 beforeBalance = address(target).balance;
        handler.call_receive();
        _assertTrue(address(target).balance <= beforeBalance);
    }
}
