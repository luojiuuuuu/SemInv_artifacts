// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/eth_tx_order_dependence_minimal.sol";

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
contract EthTxOrderDependenceMinimalHandler is LegacyCheatcodes {
    EthTxOrderDependenceMinimal public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(EthTxOrderDependenceMinimal _target) public {
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

    function call_EthTxOrderDependenceMinimal() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("EthTxOrderDependenceMinimal()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setReward() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("setReward()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_claimReward(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("claimReward(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract EthTxOrderDependenceMinimalLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    EthTxOrderDependenceMinimal target;
    EthTxOrderDependenceMinimalHandler handler;

    function setUp() public {
        target = new EthTxOrderDependenceMinimal();
        handler = new EthTxOrderDependenceMinimalHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_EthTxOrderDependenceMinimal();
        handler.call_setReward();
        handler.call_claimReward(1);
    }
}