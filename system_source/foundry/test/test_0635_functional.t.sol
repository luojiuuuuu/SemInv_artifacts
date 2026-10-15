// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/integer_overflow_mapping_sym_1.sol";

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

contract IntegerOverflowMappingSym1_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function IntegerOverflowMappingSym1_FunctionalTest() public {
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


    // @cover-intent Financial & Accounting: Verify that init can be called with a value that does not cause overflow when subtracting from an uninitialized mapping slot (which defaults to 0). This tests the edge case of subtracting from zero.
    function test_Normal_initialization_with_zero_subtraction_0() public {
// cover: init :: map[k] -= v with v=0
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
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
        target.init(1, 0);
        }
    }

    // @cover-intent Financial & Accounting: Verify that init can be called with a positive value, subtracting from an uninitialized slot (0) causing an underflow (wrapping to a large number). This tests the vulnerable behavior at line 16.
    function test_Normal_initialization_with_positive_value_1() public {
// cover: init :: map[k] -= v with v>0 and map[k]==0
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(bob);
        {
        target.init(2, 1);
        }
    }

    // @cover-intent Financial & Accounting: Verify that init can be called twice on the same key, first setting a value via overflow (from 0), then subtracting again to test further underflow behavior.
    function test_Subtraction_from_previously_set_value_2() public {
// cover: init :: map[k] -= v with map[k] already set
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
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
        target.init(3, 5);
        }
        {
        target.init(3, 10);
        }
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting: Verify that init works independently for different keys, ensuring no cross-key interference.
    function test_Multiple_keys_independent_subtraction_3() public {
// cover: init :: map[5] -= 2
// cover: init :: map[6] -= 3
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
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
        target.init(5, 2);
        }
        vm.prank(bob);
        {
        target.init(6, 3);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_init_overflow_4() public {
        vm.startPrank(owner);
        IntegerOverflowMappingSym1 target = new IntegerOverflowMappingSym1();
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
        target.init(0, 1);
        }
    }

}
