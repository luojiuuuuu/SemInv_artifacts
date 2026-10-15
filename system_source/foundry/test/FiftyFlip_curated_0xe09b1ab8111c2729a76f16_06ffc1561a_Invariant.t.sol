// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/0xe09b1ab8111c2729a76f16de96bc86a7af837928.sol";

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
contract FiftyFlipHandler is LegacyCheatcodes {
    FiftyFlip public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(FiftyFlip _target) public {
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

    function call_setBotAddress(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("setBotAddress(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setSecretSigner(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("setSecretSigner(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_wager(bool arg0,uint256 arg1,uint256 arg2,uint8 arg3,bytes32 arg4,bytes32 arg5) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = uint8(uint256(arg3) % 256);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("wager(bool,uint256,uint256,uint8,bytes32,bytes32)", arg0,arg1,arg2,arg3,arg4,arg5));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_play(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("play(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_donateForContractHealth() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("donateForContractHealth()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawDonation(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawDonation(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_refund(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("refund(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawDevFee(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawDevFee(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_withdrawBotFee(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdrawBotFee(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_kill() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("kill()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_clearStorage(uint256[] memory arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("clearStorage(uint256[])", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferAnyERC20Token(address arg0,address arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferAnyERC20Token(address,address,uint256)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract FiftyFlipLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    FiftyFlip target;
    FiftyFlipHandler handler;

    function setUp() public {
        target = new FiftyFlip(address(0x1001), address(0x1001), address(0x1001));
        handler = new FiftyFlipHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_setBotAddress(address(0x1001));
        handler.call_setSecretSigner(address(0x1001));
        handler.call_wager(false, 1, 1, 1, bytes32(0), bytes32(0));
        handler.call_play(1);
        handler.call_donateForContractHealth();
        handler.call_withdrawDonation(1);
        handler.call_refund(1);
        handler.call_withdrawDevFee(address(0x1001), 1);
        handler.call_withdrawBotFee(1);
        handler.call_kill();
        handler.call_transferAnyERC20Token(address(0x1001), address(0x1001), 1);
    }

    function test_property_access_withdrawDevFee() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("withdrawDevFee(address,uint256)", address(0x1001), 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}