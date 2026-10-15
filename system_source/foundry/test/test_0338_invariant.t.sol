// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/EscrowMyEtherEntityDB.sol";

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
contract EscrowMyEtherEntityDBHandler is LegacyCheatcodes {
    EscrowMyEtherEntityDB public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(EscrowMyEtherEntityDB _target) public {
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

    function call_EscrowMyEtherEntityDB() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("EscrowMyEtherEntityDB()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_registerBuyer(string memory arg0,string memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("registerBuyer(string,string)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_registerSeller(string memory arg0,string memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("registerSeller(string,string)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_registerEscrow(string memory arg0,string memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("registerEscrow(string,string)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract EscrowMyEtherEntityDBLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    EscrowMyEtherEntityDB target;
    EscrowMyEtherEntityDBHandler handler;

    function setUp() public {
        target = new EscrowMyEtherEntityDB();
        handler = new EscrowMyEtherEntityDBHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_EscrowMyEtherEntityDB();
        handler.call_registerBuyer("", "");
        handler.call_registerSeller("", "");
        handler.call_registerEscrow("", "");
    }
}