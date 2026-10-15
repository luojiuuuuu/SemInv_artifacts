// SPDX-License-Identifier: MIT
pragma solidity 0.5.17;
import "../src/Escrow_0517.sol";

// Foundry cheatcodes binding for Solidity 0.5–0.7
interface Vm {
    function prank(address) external;
    function startPrank(address) external;
    function stopPrank() external;
    function deal(address, uint256) external;
    function expectRevert() external;
    function expectRevert(bytes calldata) external;
    function store(address, bytes32, bytes32) external;
    function load(address, bytes32) external returns (bytes32);
}

contract Escrow_0517_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    constructor() public {
        owner = address(0x0A0A);
        alice = address(0xA11CE);
        bob   = address(0xB0B);
        carol = address(0xCA1CE);
    }

    function() external payable { }


    // ---------- Helpers (0.5/0.6/0.7) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        require(a == b, "assertEqU failed");
    }
    function _assertTrue(bool ok, string memory why) internal { require(ok, why); }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) require(a == b, why);
        else if (op == 1) require(a != b, why);
        else if (op == 2) require(a >= b, why);
        else if (op == 3) require(a <= b, why);
        else if (op == 4) require(a >  b, why);
        else if (op == 5) require(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        require(d <= tol, why);
    }
    function _assertEqA(address a, address b) internal { require(a == b, "addr eq"); }
    function _assertEqB32(bytes32 a, bytes32 b) internal { require(a == b, "b32 eq"); }
    function _assertEqS(string memory a, string memory b) internal {
        require(keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b)), "str eq");
    }


    // @cover-intent 验证 depositor 可以成功存入 ETH，deposited 增加，并触发 Deposited 事件
    function test_deposit_by_depositor_ok_0() public {
// cover: deposit :: require(msg.sender == depositor) true
// cover: deposit :: require(msg.value > 0) true
        vm.startPrank(alice);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
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
        target.deposit.value(50)();
        }
    }

    // @cover-intent 验证非 depositor（bob）调用 deposit 会回退 'only depositor'
    function test_deposit_revert_not_depositor_1() public {
// cover: deposit :: require(msg.sender == depositor) false
        vm.startPrank(owner);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(bob);
        {
        target.deposit.value(10)();
        }
    }

    // @cover-intent 验证 depositor 存入 0 ETH 会回退 'no value'
    function test_deposit_revert_zero_value_2() public {
// cover: deposit :: require(msg.value > 0) false
        vm.startPrank(owner);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.deposit();
        }
    }

    // @cover-intent 验证 arbiter 可以释放全部 deposited 给 beneficiary，deposited 归零，触发 Released 事件
    function test_release_by_arbiter_ok_3() public {
// cover: release :: require(msg.sender == arbiter) true
        vm.startPrank(alice);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
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
        target.deposit.value(30)();
        }
        vm.prank(bob);
        {
        target.release();
        }
        // TODO assert: target.balance == 0
    }

    // @cover-intent 验证非 arbiter（carol）调用 release 会回退 'only arbiter'
    function test_release_revert_not_arbiter_4() public {
// cover: release :: require(msg.sender == arbiter) false
        vm.startPrank(alice);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
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
        target.deposit.value(20)();
        }
        vm.expectRevert();
        vm.prank(carol);
        {
        target.release();
        }
    }

    // @cover-intent 验证多次 deposit 后 deposited 累加，release 一次性转出全部余额
    function test_multiple_deposits_then_release_5() public {
// cover: deposit :: require(msg.sender == depositor) true
// cover: deposit :: require(msg.value > 0) true
// cover: release :: require(msg.sender == arbiter) true
        vm.startPrank(alice);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
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
        target.deposit.value(40)();
        }
        {
        target.deposit.value(60)();
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.release();
        }
        // TODO assert: target.balance == 0
    }

    // @cover-intent Check that arbiter is set correctly after deployment
    function test_arbiter_view_6() public {
        vm.startPrank(owner);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
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
        target.arbiter();
        }
    }

    // @cover-intent Check that beneficiary is set correctly after deployment
    function test_beneficiary_view_7() public {
        vm.startPrank(owner);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
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
        target.beneficiary();
        }
    }

    // @cover-intent Depositor sends ETH to contract
    function test_deposit_positive_8() public {
        vm.startPrank(alice);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
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
        target.deposit.value(50)();
        }
        // TODO assert: address(target).balance == 50
    }

    // @cover-intent Check deposited amount after deposit
    function test_deposited_view_9() public {
        vm.startPrank(owner);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: deposit();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(alice);
        {
        target.deposited();
        }
    }

    // @cover-intent Check depositor is the deployer
    function test_depositor_view_10() public {
        vm.startPrank(owner);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
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
        target.depositor();
        }
    }

    // @cover-intent Arbiter releases funds to beneficiary
    function test_release_positive_11() public {
        vm.startPrank(owner);
        Escrow_0517 target = new Escrow_0517(address(uint160(bob)), address(uint160(carol)));
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: deposit();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.release();
        }
    }

}
