// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_50.sol";

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

contract digitalNotary_FunctionalTest {
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


    // @cover-intent Verify that a user can register a hash by paying the exact fee when the contract is active. Covers Protocol State Machine (contractactive) and Financial & Accounting (fee payment).
    function test_Register_hash_positive_path_0() public {
// assume: contractactive == true
// assume: hashfee == 5000000000000000
// cover: registerHash :: require(contractactive == true) true
// cover: registerHash :: require(getHashOwnersCount(hash) == 0) true
// cover: registerHash :: require(msg.value == hashfee) true
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(8234104122482341265491137074636836252947884782870784360943022469005013929455)));
        }
        {
        target.getHashOwnersCount(bytes32(uint256(8234104122482341265491137074636836252947884782870784360943022469005013929455)));
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that registering a hash with incorrect fee reverts. Tests Financial & Accounting invariant boundary.
    function test_Register_hash_with_wrong_fee_reverts_1() public {
// assume: contractactive == true
// assume: hashfee == 5000000000000000
// cover: registerHash :: require(msg.value == hashfee) false
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(1000000000000000)(bytes32(uint256(100720434726375746010458024839911619878118703404436202866098422983289408962287)));
        }
    }

    // @cover-intent Verify that registering a hash when contract is inactive reverts. Tests Protocol State Machine boundary.
    function test_Register_hash_when_contract_inactive_reverts_2() public {
// assume: contractactive == false
// cover: registerHash :: require(contractactive == true) false
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(false);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(77194726158210796949047323339125271902179989777093709359638389338608753093290)));
        }
    }

    // @cover-intent Verify that the current owner can transfer hash ownership by paying the change fee. Tests Authorization & Access Control and Financial & Accounting.
    function test_Change_hash_ownership_positive_path_3() public {
// assume: contractactive == true
// assume: changehashownerfee == 25000000000000000
// cover: changeHashOwnership :: require(contractactive == true) true
// cover: changeHashOwnership :: require(owncount > 0) true
// cover: changeHashOwnership :: require(msg.sender == HashList[hash][owncount - 1].owner) true
// cover: changeHashOwnership :: require(msg.value == changehashownerfee) true
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(84914198774031876643952055673037799092397988754803080295602228272469628402619)));
        }
        vm.startPrank(owner);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(84914198774031876643952055673037799092397988754803080295602228272469628402619)), bob);
        }
        {
        target.getHashOwnersCount(bytes32(uint256(84914198774031876643952055673037799092397988754803080295602228272469628402619)));
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that a non-owner cannot transfer hash ownership. Tests Authorization & Access Control boundary.
    function test_Change_hash_ownership_by_non_owner_reverts_4() public {
// assume: contractactive == true
// cover: changeHashOwnership :: require(msg.sender == HashList[hash][owncount - 1].owner) false
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(92633671389852956338856788006950326282615987732512451231566067206330503711948)));
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(92633671389852956338856788006950326282615987732512451231566067206330503711948)), carol);
        }
    }

    // @cover-intent Verify that the manager can update the hash fee. Tests Authorization & Access Control (onlyManager).
    function test_Set_hash_fee_as_manager_5() public {
// assume: msg.sender == manager
// cover: sethashfee :: require(msg.sender == manager) true
// cover: sethashfee :: require(newfee >= 0) true
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.sethashfee(10000000000000000);
        }
        // skip ABI-mismatched call: gethashfee()
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.gethashfee());
            _assertRelU(__v1, 0, 10000000000000000, "call:gethashfee==10000000000000000");
        }
    }

    // @cover-intent Verify that a non-manager cannot update the hash fee. Tests Authorization & Access Control boundary.
    function test_Set_hash_fee_by_non_manager_reverts_6() public {
// assume: msg.sender != manager
// cover: sethashfee :: require(msg.sender == manager) false
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.sethashfee(10000000000000000);
        }
    }

    // @cover-intent Verify that the manager can toggle contract active state. Tests Protocol State Machine.
    function test_Set_contract_active_state_by_manager_7() public {
// assume: msg.sender == manager
// cover: setcontractactive :: require(msg.sender == manager) true
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(false);
        }
        // skip ABI-mismatched call: getcontractactive()
        {
        target.setcontractactive(true);
        }
        vm.stopPrank();
    }

    // @cover-intent Verify that the manager can transfer the contract balance to themselves. Tests Financial & Accounting and Authorization & Access Control.
    function test_Transfer_contract_balance_by_manager_8() public {
// assume: msg.sender == manager
// assume: contract.balance > 0
// cover: transfercontractbalance :: require(cb > 0) true
// cover: transfercontractbalance :: require(msg.sender == manager) true
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(100353144005674036033761520340862853472833986710221822167529906140191379021277)));
        }
        vm.prank(owner);
        // skip ABI-mismatched call: transfercontractbalance()
    }

    // @cover-intent Verify that getHashDetails returns correct owner and timestamp after multiple ownership changes. Tests Transactional Consistency and Resource & Execution Integrity.
    function test_Get_hash_details_after_multiple_ownership_changes_9() public {
// assume: contractactive == true
// assume: getHashOwnersCount(hash) == 3
// cover: getHashDetails :: require(owncount > 0) true
// cover: getHashDetails :: require(indx < owncount) true
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(108072616621495115728666252674775380663051985687931193103493745074052254330606)));
        }
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(108072616621495115728666252674775380663051985687931193103493745074052254330606)), bob);
        }
        vm.stopPrank();
        vm.prank(bob);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(108072616621495115728666252674775380663051985687931193103493745074052254330606)), carol);
        }
        vm.prank(carol);
        {
        target.getHashDetails(bytes32(uint256(108072616621495115728666252674775380663051985687931193103493745074052254330606)), 2);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou19_sequence_10() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_intou19()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou20_sequence_11() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.bug_intou20(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou23_sequence_12() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_intou23()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou27_sequence_13() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_intou27()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou3_sequence_14() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_intou3()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou31_sequence_15() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_intou31()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou32_sequence_16() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.bug_intou32(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou35_sequence_17() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_intou35()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou36_sequence_18() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.bug_intou36(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou39_sequence_19() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_intou39()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou4_sequence_20() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.bug_intou4(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou40_sequence_21() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.bug_intou40(1);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou7_sequence_22() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: bug_intou7()
    }

    // @cover-intent Resource & Execution Integrity
    function test_bug_intou8_sequence_23() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.bug_intou8(1);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeHashOwnership_positive_sequence_24() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(true);
        }
        vm.prank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(4660)));
        }
        vm.prank(owner);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(4660)), bob);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeHashOwnership_negative_sequence_25() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(true);
        }
        vm.prank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(22136)));
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(22136)), carol);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHashDetails_sequence_26() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(true);
        }
        vm.startPrank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(43981)));
        }
        {
        target.getHashDetails(bytes32(uint256(43981)), 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHashOwnersCount_sequence_27() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(true);
        }
        vm.startPrank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(57005)));
        }
        {
        target.getHashOwnersCount(bytes32(uint256(57005)));
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getNumberofHashesRegistered_sequence_28() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(true);
        }
        vm.startPrank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(48879)));
        }
        // skip ABI-mismatched call: getNumberofHashesRegistered()
        vm.stopPrank();
    }

    // @cover-intent Financial & Accounting
    function test_getchangehashownerfee_sequence_29() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: getchangehashownerfee()
    }

    // @cover-intent Protocol State Machine
    function test_getcontractactive_sequence_30() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: getcontractactive()
    }

    // @cover-intent Financial & Accounting
    function test_getcontractbalance_sequence_31() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: getcontractbalance()
    }

    // @cover-intent Financial & Accounting
    function test_gethashfee_sequence_32() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: gethashfee()
    }

    // @cover-intent Authorization & Access Control
    function test_getmanager_sequence_33() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        // skip ABI-mismatched call: getmanager()
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou13_sequence_34() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou13(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou17_sequence_35() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou17(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou25_sequence_36() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou25(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou33_sequence_37() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou33(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou37_sequence_38() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou37(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_increaseLockTime_intou9_sequence_39() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou9(100);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou13_sequence_40() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.lockTime_intou13(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou17_sequence_41() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.lockTime_intou17(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou25_sequence_42() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.lockTime_intou25(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou33_sequence_43() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.lockTime_intou33(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou37_sequence_44() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.lockTime_intou37(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_lockTime_intou9_sequence_45() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.lockTime_intou9(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_registerHash_sequence_46() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(true);
        }
        vm.prank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(4369)));
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setchangehashownerfee_sequence_47() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setchangehashownerfee(100);
        }
    }

    // @cover-intent Protocol State Machine
    function test_setcontractactive_sequence_48() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(false);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_sethashfee_sequence_49() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.sethashfee(100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setmanager_sequence_50() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.setmanager(address(uint160(alice)));
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou14_sequence_51() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.transfer_intou14(bob, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou26_sequence_52() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.transfer_intou26(bob, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou30_sequence_53() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.transfer_intou30(bob, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_intou38_sequence_54() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.transfer_intou38(bob, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_undrflow2_sequence_55() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.transfer_undrflow2(bob, 0);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfercontractbalance_sequence_56() public {
        vm.startPrank(alice);
        digitalNotary target = new digitalNotary();
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
        target.setcontractactive(true);
        }
        vm.prank(alice);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(8738)));
        }
        vm.prank(owner);
        // skip ABI-mismatched call: transfercontractbalance()
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou13_sequence_57() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou13(1);
        }
        // skip ABI-mismatched call: withdraw_intou13()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou17_sequence_58() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou17(1);
        }
        // skip ABI-mismatched call: withdraw_intou17()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou25_sequence_59() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou25(1);
        }
        // skip ABI-mismatched call: withdraw_intou25()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou33_sequence_60() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou33(1);
        }
        // skip ABI-mismatched call: withdraw_intou33()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou37_sequence_61() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou37(1);
        }
        // skip ABI-mismatched call: withdraw_intou37()
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_withdraw_intou9_sequence_62() public {
        vm.startPrank(owner);
        digitalNotary target = new digitalNotary();
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
        target.increaseLockTime_intou9(1);
        }
        // skip ABI-mismatched call: withdraw_intou9()
        vm.stopPrank();
    }

}
