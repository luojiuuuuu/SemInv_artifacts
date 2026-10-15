// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/parity_wallet_bug_2.sol";

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
contract WalletLibraryHandler is LegacyCheatcodes {
    WalletLibrary public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(WalletLibrary _target) public {
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

    function call_initMultiowned(address[] memory arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("initMultiowned(address[],uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_revoke(bytes32 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("revoke(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_changeOwner(address arg0,address arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeOwner(address,address)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_addOwner(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("addOwner(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_removeOwner(address arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("removeOwner(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_changeRequirement(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("changeRequirement(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_initDaylimit(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("initDaylimit(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setDailyLimit(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setDailyLimit(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_resetSpentToday() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("resetSpentToday()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_initWallet(address[] memory arg0,uint256 arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("initWallet(address[],uint256,uint256)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_kill(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        (bool ok,) = address(target).call(abi.encodeWithSignature("kill(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_execute(address arg0,uint256 arg1,bytes memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("execute(address,uint256,bytes)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_confirm(bytes32 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("confirm(bytes32)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract WalletLibraryLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    WalletLibrary target;
    WalletLibraryHandler handler;

    function setUp() public {
        target = new WalletLibrary();
        handler = new WalletLibraryHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_revoke(bytes32(0));
        handler.call_changeOwner(address(0x1001), address(0x1001));
        handler.call_addOwner(address(0x1001));
        handler.call_removeOwner(address(0x1001));
        handler.call_changeRequirement(1);
        handler.call_initDaylimit(1);
        handler.call_setDailyLimit(1);
        handler.call_resetSpentToday();
        handler.call_kill(address(0x1001));
        handler.call_execute(address(0x1001), 1, hex"");
        handler.call_confirm(bytes32(0));
    }

    function test_property_access_initMultiowned() public {
        address[] memory acc_initMultiowned__owners = new address[](1);
        acc_initMultiowned__owners[0] = address(0x1001);
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("initMultiowned(address[],uint256)", acc_initMultiowned__owners, 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_revoke() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("revoke(bytes32)", bytes32(0)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_changeOwner() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("changeOwner(address,address)", address(0x1001), address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_addOwner() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("addOwner(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_removeOwner() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("removeOwner(address)", address(0x1001)));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}
