// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/integer_overflow_mapping_sym_1.sol";

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
contract IntegerOverflowMappingSym1Handler is LegacyCheatcodes {
    IntegerOverflowMappingSym1 public target;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    constructor(IntegerOverflowMappingSym1 _target) public {
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

    function call_init(uint256 arg0,uint256 arg1) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _vm().startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        arg1 = uint256(uint256(arg1) % 1000);
        (bool ok,) = address(target).call(abi.encodeWithSignature("init(uint256,uint256)", arg0,arg1));
        lastCallOk = ok;
        _vm().stopPrank();
    }
}

contract IntegerOverflowMappingSym1LegacyPropertyTest is SimpleAssert, LegacyCheatcodes {
    IntegerOverflowMappingSym1 target;
    IntegerOverflowMappingSym1Handler handler;

    function setUp() public {
        target = new IntegerOverflowMappingSym1();
        handler = new IntegerOverflowMappingSym1Handler(target);
        _vm().deal(address(handler), 100 ether);
    }

    function _run_basic_sequence() internal {
        handler.call_init(1, 1);
    }
}