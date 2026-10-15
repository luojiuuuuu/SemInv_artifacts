// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/0x19cf8481ea15427a98ba3cdd6d9e14690011ab10.sol";

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
contract daoPOLSKAtokensHandler is LegacyCheatcodes {
    daoPOLSKAtokens public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(daoPOLSKAtokens _target) public {
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

    function call_daoPOLSKAtokens() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("daoPOLSKAtokens()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setSupply(uint256 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setSupply(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setotherchainstotalsupply(uint256 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setotherchainstotalsupply(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_approveAndCall(address arg0,uint256 arg1,bytes memory arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("approveAndCall(address,uint256,bytes)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burn(uint256 arg0) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burn(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_burnFrom(address arg0,uint256 arg1) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("burnFrom(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transfer(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transfer(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_transferFrom(address arg0,address arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("transferFrom(address,address,uint256)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_approve(address arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("approve(address,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setTokenInformation(string memory arg0,string memory arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setTokenInformation(string,string)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setChainsAddresses(address arg0,int256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = int256(int256(arg1) % int256(1000));
        (bool ok,) = address(target).call(abi.encodeWithSignature("setChainsAddresses(address,int256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_DAOPolskaTokenICOregulations() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("DAOPolskaTokenICOregulations()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_sendTokenAw(address arg0,address arg1,uint256 arg2) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = actors[uint256(keccak256(abi.encodePacked(arg1))) % actors.length];
        arg2 = uint256(uint256(arg2) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("sendTokenAw(address,address,uint256)", arg0,arg1,arg2));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_createDaoPOLSKAtokens(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        (bool ok,) = address(target).call.value(value)(abi.encodeWithSignature("createDaoPOLSKAtokens(address)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_setBonusCreationRate(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("setBonusCreationRate(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_FundsTransfer() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("FundsTransfer()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_PartialFundsTransfer(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("PartialFundsTransfer(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_turnrefund() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("turnrefund()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_fundingState() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("fundingState()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_turnmigrate() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("turnmigrate()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_finalize() public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("finalize()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_migrate(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("migrate(uint256)", arg0));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_refundTRA() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("refundTRA()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }

    function call_preICOregulations() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        (bool ok,) = address(target).call(abi.encodeWithSignature("preICOregulations()"));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract daoPOLSKAtokensLegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    daoPOLSKAtokens target;
    daoPOLSKAtokensHandler handler;

    function setUp() public {
        target = new daoPOLSKAtokens();
        handler = new daoPOLSKAtokensHandler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_daoPOLSKAtokens();
        handler.call_setSupply(1);
        handler.call_setotherchainstotalsupply(1);
        handler.call_approveAndCall(address(0x1001), 1, hex"");
        handler.call_burn(1);
        handler.call_burnFrom(address(0x1001), 1);
        handler.call_transfer(address(0x1001), 1);
        handler.call_transferFrom(address(0x1001), address(0x1001), 1);
        handler.call_approve(address(0x1001), 1);
        handler.call_setTokenInformation("", "");
        handler.call_setChainsAddresses(address(0x1001), 1);
        handler.call_DAOPolskaTokenICOregulations();
        handler.call_sendTokenAw(address(0x1001), address(0x1001), 1);
        handler.call_createDaoPOLSKAtokens(address(0x1001));
        handler.call_setBonusCreationRate(1);
        handler.call_FundsTransfer();
        handler.call_PartialFundsTransfer(1);
        handler.call_turnrefund();
        handler.call_fundingState();
        handler.call_turnmigrate();
        handler.call_finalize();
        handler.call_migrate(1);
        handler.call_refundTRA();
        handler.call_preICOregulations();
    }

    function test_property_access_setSupply() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("setSupply(uint256)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_setotherchainstotalsupply() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("setotherchainstotalsupply(uint256)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_burn() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("burn(uint256)", 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_burnFrom() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("burnFrom(address,uint256)", address(0x1001), 1));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_turnrefund() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("turnrefund()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_fundingState() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("fundingState()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_turnmigrate() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("turnmigrate()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }

    function test_property_access_finalize() public {
        address attacker = address(0xdead);
        _vm().startPrank(attacker);
        bool ok = address(target).call(abi.encodeWithSignature("finalize()"));
        _vm().stopPrank();
        _assertTrue(!ok);
    }
}