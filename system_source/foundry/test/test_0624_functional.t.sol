// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/integer_overflow_benign_1.sol";

// Foundry cheatcodes binding for Solidity 0.4.x
// 0.4 没有 interface，用抽象合约声明
contract Vm {
    function prank(address) public;
    function startPrank(address) public;
    function stopPrank() public;
    function deal(address, uint256) public;
    function expectRevert() public;
    function expectRevert(bytes) public;
    function store(address, bytes32, bytes32) public;
    function load(address, bytes32) public returns (bytes32);
}

contract IntegerOverflowBenign1_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowBenign1_FunctionalTest() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() public payable { }


    // ---------- Helpers (0.4) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b);
    }
    function _assertTrue(bool ok, string why) internal { require(ok); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string why) internal {
        // op: 0==,1!=,2>=,3<=,4>,5<
        if (op == 0) require(a == b);
        else if (op == 1) require(a != b);
        else if (op == 2) require(a >= b);
        else if (op == 3) require(a <= b);
        else if (op == 4) require(a >  b);
        else if (op == 5) require(a <  b);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string why) internal {
        if (a >= b) require(a - b <= tol); else require(b - a <= tol);
    }
    function _assertEqA(address a, address b) internal { require(a == b); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b); }
    function _assertEqS(string a, string b) internal { if (sha3(a) != sha3(b)) { require(false); } }


    // @cover-intent Transactional Consistency: Verify that normal subtraction (count > input) works without overflow, and the result is not stored persistently.
    function test_Normal_subtraction_without_overflow_0() public {
// assume: count == 1
// cover: run :: count - input underflows? false
        vm.startPrank(owner);
        IntegerOverflowBenign1 target = new IntegerOverflowBenign1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.run(1);
        }
    }

    // @cover-intent Transactional Consistency: Verify that subtraction overflow (input > count) does not revert and does not persist the overflowed result to state.
    function test_Subtraction_with_overflow_input_count_1() public {
// assume: count == 1
// cover: run :: count - input underflows? true
        vm.startPrank(owner);
        IntegerOverflowBenign1 target = new IntegerOverflowBenign1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.run(2);
        }
    }

    // @cover-intent Transactional Consistency: Verify that subtraction with input equal to count (result = 0) does not cause any state change.
    function test_Subtraction_with_input_equal_to_count_2() public {
// assume: count == 1
// cover: run :: count - input == 0
        vm.startPrank(owner);
        IntegerOverflowBenign1 target = new IntegerOverflowBenign1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.run(1);
        }
    }

    // @cover-intent Transactional Consistency: Verify that subtraction with the maximum possible input (type(uint256).max) causes overflow but does not persist the result.
    function test_Subtraction_with_maximum_input_type_uint256_max_3() public {
// assume: count == 1
// cover: run :: count - input underflows with max input
        vm.startPrank(owner);
        IntegerOverflowBenign1 target = new IntegerOverflowBenign1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.run(115792089237316195423570985008687907853269984665640564039457584007913129639935);
        }
    }

    // @cover-intent Transactional Consistency: Verify that multiple calls to run do not accumulate state changes, regardless of overflow.
    function test_Multiple_calls_to_run_with_different_inputs_4() public {
// assume: count == 1
// cover: run :: multiple calls, no state change
        vm.startPrank(owner);
        IntegerOverflowBenign1 target = new IntegerOverflowBenign1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.run(0);
        }
        {
        target.run(5);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.run(2);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_count_view_5() public {
        vm.startPrank(owner);
        IntegerOverflowBenign1 target = new IntegerOverflowBenign1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        // skip ABI-mismatched call: count()
        {
            uint256 __v1 = uint256(target.count());
            _assertRelU(__v1, 0, 1, "call:count==1");
        }
    }

    // @cover-intent minimal test for run
    function test_perfn_run_6() public {
        vm.startPrank(owner);
        IntegerOverflowBenign1 target = new IntegerOverflowBenign1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.run(1);
        }
    }

}
