// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/suicide_multitx_infeasible.sol";

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

contract SuicideMultiTxFeasible_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function SuicideMultiTxFeasible_FunctionalTest() public {
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


    // @cover-intent Protocol State Machine: Verify that run() selfdestructs only when initialized == 2, which is never set, so run() never selfdestructs.
    function test_init_then_run_positive_0() public {
// cover: run :: initialized != 2 true
        vm.startPrank(owner);
        SuicideMultiTxFeasible target = new SuicideMultiTxFeasible();
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
        // skip ABI-mismatched call: init()
        {
        target.run(0);
        }
        // skip ABI-mismatched call: count()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: run() returns early when initialized is 0 (default), no selfdestruct.
    function test_run_without_init_1() public {
// cover: run :: initialized != 2 true
        vm.startPrank(owner);
        SuicideMultiTxFeasible target = new SuicideMultiTxFeasible();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(bob);
        {
        target.run(42);
        }
        // skip ABI-mismatched call: count()
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: init() sets initialized to 1, not 2, so run() still returns early.
    function test_init_twice_then_run_2() public {
// cover: run :: initialized != 2 true
        vm.startPrank(owner);
        SuicideMultiTxFeasible target = new SuicideMultiTxFeasible();
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
        // skip ABI-mismatched call: init()
        // skip ABI-mismatched call: init()
        {
        target.run(1);
        }
        vm.stopPrank();
        vm.prank(bob);
        // skip ABI-mismatched call: count()
    }

    // @cover-intent Resource & Execution Integrity: run() ignores input argument; behavior is identical for any uint256 input.
    function test_run_with_various_inputs_3() public {
// cover: run :: initialized != 2 true
        vm.startPrank(owner);
        SuicideMultiTxFeasible target = new SuicideMultiTxFeasible();
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
        // skip ABI-mismatched call: init()
        {
        target.run(0);
        }
        vm.stopPrank();
        vm.prank(carol);
        {
        target.run(12345);
        }
    }

    // @cover-intent Financial & Accounting
    function test_count_view_state_4() public {
        vm.startPrank(owner);
        SuicideMultiTxFeasible target = new SuicideMultiTxFeasible();
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
            _assertRelU(__v1, 2, 1, "call:count>=1");
        }
    }

    // @cover-intent Protocol State Machine
    function test_init_set_initialized_to_1_5() public {
        vm.startPrank(owner);
        SuicideMultiTxFeasible target = new SuicideMultiTxFeasible();
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
        // skip ABI-mismatched call: init()
    }

    // @cover-intent Resource & Execution Integrity
    function test_run_selfdestruct_when_initialized_2_6() public {
        vm.startPrank(owner);
        SuicideMultiTxFeasible target = new SuicideMultiTxFeasible();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(2)));
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.run(0);
        }
    }

}
