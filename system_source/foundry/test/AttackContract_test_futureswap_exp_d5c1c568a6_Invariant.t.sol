// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/futureswap_exp.sol";
contract AttackContractHandler {
    AttackContract public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking
    uint256 public prev_opener;
    uint256 public curr_opener;
    bool public seen_opener;
    bool public entered_terminal_opener;

    constructor(AttackContract _target, Vm _vm) {
        target = _target;
        vm = _vm;

        actors.push(address(0x100));
        actors.push(address(0x200));
        actors.push(address(0x300));
        actors.push(address(0x400));
        actors.push(address(this));

        for(uint i=0;i<actors.length;i++){
            vm.deal(actors[i],100 ether);
        }
    }

    function actorCount() public view returns(uint){
        return actors.length;
    }

    function actor(uint i) public view returns(address){
        return actors[i];
    }

    function _snapshot_before_opener() internal {
        if(seen_opener) {
            prev_opener = curr_opener;
        } else {
            prev_opener = uint(target.opener());
            seen_opener = true;
        }
        curr_opener = uint(target.opener());
    }

    function _snapshot_after_opener() internal {
        curr_opener = uint(target.opener());
    }

    function call_executeOperation(address arg0,uint256 arg1,uint256 arg2,address arg3,bytes memory arg4) public {
        nonce++;
        address sender = address(this);
        callCount[sender]++;
        _snapshot_before_opener();
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        arg1 = uint256(uint256(arg1) % 1000);
        arg2 = uint256(uint256(arg2) % 1000);
        arg3 = actors[uint256(keccak256(abi.encodePacked(arg3))) % actors.length];
        try target.executeOperation(arg0,arg1,arg2,arg3,arg4) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_opener();
    }

    function call_start(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_opener();
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.start(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_opener();
    }
}

contract AttackContractBaseTest is Test {
    AttackContract target;
    AttackContractHandler handler;

    function setUp() public virtual {
        target = new AttackContract(address(0x1001), address(0x1001), address(0x1001), address(0x1001));
        handler = new AttackContractHandler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = handler.call_executeOperation.selector;
        selectors[1] = handler.call_start.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract AttackContractAccountingInvariantTest is AttackContractBaseTest {
}

contract AttackContractStateInvariantTest is AttackContractBaseTest {
}

contract AttackContractStateTransitionPropertyTest is AttackContractBaseTest {

    function test_property_transition_opener_executeOperation() public {
        uint256 beforeV = uint256(target.opener());
        handler.call_executeOperation(address(0x1001), 1, 1, address(0x1001), hex"");
        uint256 afterV = uint256(target.opener());
    }
}

contract AttackContractAccessInvariantTest is AttackContractBaseTest {

    function invariant_access_executeOperation() public {
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("executeOperation(address,uint256,uint256,address,bytes)", address(0x1001), 1, 1, address(0x1001), hex""));
        assertTrue(!ok);
    }
}
// replay helper
contract ReplayHelper is Test {
    AttackContract target;
    constructor(address t) {
        target = AttackContract(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}

// ===============================
// L3 supplemental semantic invariants
// ===============================
// Supplemental semantic-invariant tests generated separately from the main invariant file.
// These contracts are safe to edit, run, or disable without changing the baseline invariant tests.

abstract contract AttackContractSemanticSupplementBase is AttackContractBaseTest {
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

contract AttackContractAccessNoninterferenceSupplementTest is AttackContractSemanticSupplementBase {

    function test_supplement_access_noninterference_0_executeOperation() public {
        // invariant: I2.authorization.access_noninterference
        (bool okPre_owner, address pre_owner) = _readAddress0("owner()");
        address attacker = address(0xdead);
        vm.prank(attacker);
        (bool ok,) = address(target).call(abi.encodeWithSignature("executeOperation(address,uint256,uint256,address,bytes)", address(0x1001), 1, 1, address(0x1001), hex""));
        ok;
        (bool okPost_owner, address post_owner) = _readAddress0("owner()");
        if(okPre_owner && okPost_owner) assertEq(post_owner, pre_owner);
    }
}
