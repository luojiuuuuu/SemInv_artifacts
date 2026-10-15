// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;
import "forge-std/Test.sol";
import "../src/DutchAuction_076.sol";
contract DutchAuction_076Handler {
    DutchAuction_076 public target;
    Vm public vm;

    address[] internal actors;
    uint internal nonce;

    mapping(address=>uint256) public ethSent;
    mapping(address=>uint256) public callCount;
    bool public lastCallOk;

    // state snapshot tracking
    uint256 public prev_sold;
    uint256 public curr_sold;
    bool public seen_sold;
    bool public entered_terminal_sold;

    constructor(DutchAuction_076 _target, Vm _vm) {
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

    function _snapshot_before_sold() internal {
        if(seen_sold) {
            prev_sold = curr_sold;
        } else {
            prev_sold = target.sold() ? 1 : 0;
            seen_sold = true;
        }
        curr_sold = target.sold() ? 1 : 0;
    }

    function _snapshot_after_sold() internal {
        curr_sold = target.sold() ? 1 : 0;
        if(curr_sold == 1) entered_terminal_sold = true;
    }

    function call_buy() public {
        nonce++;
        address sender = actors[nonce % actors.length];
        callCount[sender]++;
        _snapshot_before_sold();
        vm.startPrank(sender);
        uint256 value = uint256(keccak256(abi.encodePacked(nonce))) % 1 ether;
        ethSent[sender] += value;
        try target.buy{value:value}() {
            lastCallOk = true;
        } catch {
            lastCallOk = false;
        }
        vm.stopPrank();
        _snapshot_after_sold();
    }
}

contract DutchAuction_076BaseTest is Test {
    DutchAuction_076 target;
    DutchAuction_076Handler handler;

    function setUp() public virtual {
        target = new DutchAuction_076(1, 1, 1);
        handler = new DutchAuction_076Handler(target, vm);
        vm.deal(address(handler),100 ether);
        targetContract(address(handler));

        bytes4[] memory selectors = new bytes4[](1);
        selectors[0] = handler.call_buy.selector;

        targetSelector(FuzzSelector({
            addr: address(handler),
            selectors: selectors
        }));
    }
}

contract DutchAuction_076AccountingInvariantTest is DutchAuction_076BaseTest {
}

contract DutchAuction_076StateInvariantTest is DutchAuction_076BaseTest {


    function invariant_sold_no_rollback_after_terminal() public view {
        if(handler.entered_terminal_sold()) {
            uint256 curr = handler.curr_sold();
            assertTrue(curr == 1);
        }
    }
}

contract DutchAuction_076StateTransitionPropertyTest is DutchAuction_076BaseTest {

    function test_property_transition_sold_buy() public {
        uint256 beforeV = target.sold() ? 1 : 0;
        handler.call_buy();
        uint256 afterV = target.sold() ? 1 : 0;
        if(beforeV == 0 && handler.lastCallOk()) {
            assertTrue(afterV == 1);
        }
    }
}

contract DutchAuction_076AccessInvariantTest is DutchAuction_076BaseTest {
}
// replay helper
contract ReplayHelper is Test {
    DutchAuction_076 target;
    constructor(address t) {
        target = DutchAuction_076(payable(t));
    }
    function replay(address sender,uint256 value,bytes memory data) public returns (bool) {
        vm.deal(sender, value);
        vm.startPrank(sender);
        (bool ok,) = address(target).call{value:value}(data);
        vm.stopPrank();
        return ok;
    }
}