// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
import "forge-std/Test.sol";
import "../src/Ballot_0821.sol";
contract Ballot_0821Handler {
    Ballot_0821 public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking

    constructor(Ballot_0821 _target, Vm _vm) {
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

    function call_giveRightToVote(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.giveRightToVote(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_delegate(address arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = actors[uint256(keccak256(abi.encodePacked(arg0))) % actors.length];
        try target.delegate(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }

    function call_vote(uint256 arg0) public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        vm.startPrank(sender);
        arg0 = uint256(uint256(arg0) % 1000);
        try target.vote(arg0) {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
    }
}

contract Ballot_0821BaseTest is Test {
    Ballot_0821 target;
    Ballot_0821Handler handler;

    function setUp() public virtual {
        bytes32[] memory ctor_proposalNames = new bytes32[](1);
        ctor_proposalNames[0] = bytes32(0);
        target = new Ballot_0821(ctor_proposalNames);
        handler = new Ballot_0821Handler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](3);
        selectors[0] = handler.call_giveRightToVote.selector;
        selectors[1] = handler.call_delegate.selector;
        selectors[2] = handler.call_vote.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract Ballot_0821AccountingInvariantTest is Ballot_0821BaseTest {
}

contract Ballot_0821StateInvariantTest is Ballot_0821BaseTest {
}

contract Ballot_0821StateTransitionPropertyTest is Ballot_0821BaseTest {
}

contract Ballot_0821AccessInvariantTest is Ballot_0821BaseTest {
}
// replay helper
contract ReplayHelper is Test {
    Ballot_0821 target;
    constructor(address t) {
        target = Ballot_0821(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}