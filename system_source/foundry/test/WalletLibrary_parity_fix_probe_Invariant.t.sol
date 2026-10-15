// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.5.0;
import "../src/parity_wallet_bug_1.sol";

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
    }
}
