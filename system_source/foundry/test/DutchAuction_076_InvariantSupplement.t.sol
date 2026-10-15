// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;
import "./DutchAuction_076_Invariant.t.sol";

// Supplemental semantic-invariant tests generated separately from the main invariant file.
// These contracts are safe to edit, run, or disable without changing the baseline invariant tests.

abstract contract DutchAuction_076SemanticSupplementBase is DutchAuction_076BaseTest {
    function _readUint0(string memory sig) internal view returns (bool, uint256) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig));
        if(!ok || data.length < 32) return (false, 0);
        return (true, abi.decode(data, (uint256)));
    }

    function _readAddress0(string memory sig) internal view returns (bool, address) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig));
        if(!ok || data.length < 32) return (false, address(0));
        return (true, abi.decode(data, (address)));
    }

    function _readUint1Addr(string memory sig, address a) internal view returns (bool, uint256) {
        (bool ok, bytes memory data) = address(target).staticcall(abi.encodeWithSignature(sig, a));
        if(!ok || data.length < 32) return (false, 0);
        return (true, abi.decode(data, (uint256)));
    }
}

contract DutchAuction_076TerminalSupplementTest is DutchAuction_076SemanticSupplementBase {

    function invariant_supplement_sold_terminal_absorbing() public view {
        // invariant: I3.state.terminal_absorbing
        if(handler.entered_terminal_sold()) {
            uint256 curr = handler.curr_sold();
            assertTrue(curr == 1);
        }
    }
}
