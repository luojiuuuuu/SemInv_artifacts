// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

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
contract VaultProxyHandler is LegacyCheatcodes {
    VaultProxy public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(VaultProxy _target) public {
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

    function call_transferOwner(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferOwner(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_proxy(address arg0,bytes memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("proxy(address,bytes)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_Vault() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("Vault()"));
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

    function call_withdraw(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("withdraw(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract VaultProxyLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    VaultProxy target;
    VaultProxyHandler handler;

    function setUp() public {
        target = new VaultProxy();
        handler = new VaultProxyHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_transferOwner(address(0x1001));
        handler.call_proxy(address(0x1001), hex"");
        handler.call_Vault();
        handler.call_deposit();
        handler.call_withdraw(1);
    }

    function test_property_access_transferOwner() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("transferOwner(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_Vault() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("Vault()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}
