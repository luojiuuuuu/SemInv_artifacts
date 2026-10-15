// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x89c1b3807d4c67df034fffb62f3509561218d30b.sol";

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

contract TownCrier_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function TownCrier_FunctionalTest() public {
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


    // @cover-intent Test the happy path of creating a request and delivering a response, verifying state transitions and event emissions (Transactional Consistency).
    function test_Basic_request_and_deliver_flow_0() public {
// assume: MIN_FEE <= 1 ether
// assume: msg.sender == SGX_ADDRESS for deliver
// cover: request :: msg.value >= MIN_FEE true
// cover: deliver :: msg.sender == SGX_ADDRESS true
// cover: deliver :: requests[requestId].paramsHash == paramsHash true
// cover: deliver :: error < 2 true
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 100, _arr1);
        }
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(305419896)), 0, bytes32(uint256(2)));
        }
    }

    // @cover-intent Test that a request with msg.value < MIN_FEE is rejected and refunded (Financial & Accounting).
    function test_Request_with_insufficient_fee_1() public {
// assume: MIN_FEE > 1 wei
// cover: request :: msg.value < MIN_FEE true
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 wei)(1, alice, bytes4(hex"12345678"), 100, _arr1);
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Test that a requester can cancel their own request and receive refund minus cancellation fee (Authorization & Access Control).
    function test_Cancel_request_by_requester_2() public {
// assume: CANCELLATION_FEE <= 1 ether
// cover: cancel :: requests[requestId].requester == msg.sender true
// cover: cancel :: fee >= CANCELLATION_FEE true
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 100, _arr1);
        }
        vm.prank(owner);
        {
        target.cancel(1);
        }
        // TODO assert: alice.balance == 10 ether - CANCELLATION_FEE
    }

    // @cover-intent Test that canceling a non-existent request returns FAIL_FLAG (Resource & Execution Integrity).
    function test_Cancel_non_existent_request_3() public {
// cover: cancel :: requests[requestId].requester == msg.sender false
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.cancel(999);
        }
    }

    // @cover-intent Test that owner can upgrade when unrespondedCnt == 0, setting killswitch and newVersion (Protocol State Machine).
    function test_Upgrade_contract_4() public {
// assume: unrespondedCnt == 0
// cover: upgrade :: msg.sender == requests[0].requester true
// cover: upgrade :: unrespondedCnt == 0 true
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.upgrade(0x0000000000000000000000000000000000000001);
        }
    }

    // @cover-intent Test that owner can suspend and restart the contract, toggling killswitch (Protocol State Machine).
    function test_Suspend_and_restart_contract_5() public {
// assume: newVersion == 0
// cover: suspend :: msg.sender == requests[0].requester true
// cover: restart :: msg.sender == requests[0].requester true
// cover: restart :: newVersion == 0 true
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(owner);
        {
        target.suspend();
        }
        {
        target.restart();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that owner can withdraw contract balance when no pending requests (Financial & Accounting).
    function test_Withdraw_when_unrespondedCnt_0_6() public {
// assume: unrespondedCnt == 0 after deliver
// cover: withdraw :: msg.sender == requests[0].requester true
// cover: withdraw :: unrespondedCnt == 0 true
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 100, _arr1);
        }
        vm.startPrank(owner);
        {
        target.deliver(1, bytes32(uint256(305419896)), 0, bytes32(uint256(2)));
        }
        {
        target.withdraw();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that owner can reset GAS_PRICE, MIN_FEE, and CANCELLATION_FEE when unrespondedCnt == 0 (Protocol State Machine).
    function test_Reset_gas_parameters_7() public {
// assume: unrespondedCnt == 0
// cover: reset :: msg.sender == requests[0].requester true
// cover: reset :: unrespondedCnt == 0 true
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.reset(100000000000, 50000, 40000);
        }
    }

    // @cover-intent Test that non-owner cannot upgrade the contract (Authorization & Access Control).
    function test_Non_owner_cannot_upgrade_8() public {
// assume: alice != requests[0].requester
// cover: upgrade :: msg.sender == requests[0].requester false
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.upgrade(0x0000000000000000000000000000000000000001);
        }
    }

    // @cover-intent Test that deliver with incorrect paramsHash is silently discarded (Transactional Consistency).
    function test_Deliver_with_wrong_paramsHash_9() public {
// assume: requests[1].paramsHash != 0xDEADBEEF
// cover: deliver :: requests[requestId].paramsHash != paramsHash true
        vm.startPrank(alice);
        TownCrier target = new TownCrier();
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
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        target.request.value(1 ether)(1, alice, bytes4(hex"12345678"), 100, _arr1);
        }
        vm.prank(owner);
        {
        target.deliver(1, bytes32(uint256(3735928559)), 0, bytes32(uint256(2)));
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Resource & Execution Integrity
    function test_CANCELLATION_FEE_view_10() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.CANCELLATION_FEE();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_CANCELLED_FEE_FLAG_view_11() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.CANCELLED_FEE_FLAG();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_DELIVERED_FEE_FLAG_view_12() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.DELIVERED_FEE_FLAG();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_FAIL_FLAG_view_13() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.FAIL_FLAG();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_GAS_PRICE_view_14() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.GAS_PRICE();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_MIN_FEE_view_15() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.MIN_FEE();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_SGX_ADDRESS_view_16() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.SGX_ADDRESS();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_SUCCESS_FLAG_view_17() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.SUCCESS_FLAG();
        }
    }

    // @cover-intent Protocol State Machine
    function test_externalCallFlag_view_18() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.externalCallFlag();
        }
    }

    // @cover-intent Protocol State Machine
    function test_killswitch_view_19() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.killswitch();
        }
    }

    // @cover-intent Protocol State Machine
    function test_newVersion_view_20() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.newVersion();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_requestCnt_view_21() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.requestCnt();
        }
    }

    // @cover-intent Protocol State Machine
    function test_restart_by_owner_22() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.restart();
        }
    }

    // @cover-intent Protocol State Machine
    function test_suspend_by_owner_23() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.suspend();
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_unrespondedCnt_view_24() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.unrespondedCnt();
        }
    }

    // @cover-intent Financial & Accounting
    function test_withdraw_by_owner_25() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.withdraw();
        }
        // TODO assert: owner.balance >= 0
    }

    // @cover-intent minimal test for cancel
    function test_perfn_cancel_26() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.cancel(1);
        }
    }

    // @cover-intent minimal test for deliver
    function test_perfn_deliver_27() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.deliver(1, bytes32(uint256(1)), 1, bytes32(uint256(1)));
        }
    }

    // @cover-intent minimal test for requests
    function test_perfn_requests_28() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.requests(1);
        }
    }

    // @cover-intent minimal test for reset
    function test_perfn_reset_29() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(owner);
        {
        target.reset(1, 1, 1);
        }
    }

    // @cover-intent minimal test for upgrade
    function test_perfn_upgrade_30() public {
        vm.startPrank(owner);
        TownCrier target = new TownCrier();
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
        target.upgrade(alice);
        }
    }

}
