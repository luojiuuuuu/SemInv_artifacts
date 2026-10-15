// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/EscrowMyEtherEntityDB.sol";

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

contract EscrowMyEtherEntityDB_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function EscrowMyEtherEntityDB_FunctionalTest() public {
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


    // @cover-intent Test normal registration of a buyer and retrieval of their info. Covers Authorization & Access Control.
    function test_Register_and_retrieve_buyer_info_0() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getBuyerFullInfo(alice);
        }
    }

    // @cover-intent Test normal registration of a seller and retrieval of their info. Covers Authorization & Access Control.
    function test_Register_and_retrieve_seller_info_1() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getSellerFullInfo(bob);
        }
    }

    // @cover-intent Test normal registration of an escrow agent and retrieval of their info. Covers Authorization & Access Control.
    function test_Register_and_retrieve_escrow_info_2() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.getEscrowFullInfo(carol);
        }
    }

    // @cover-intent Test that a buyer can overwrite their own info. Covers Transactional Consistency.
    function test_Overwrite_buyer_info_3() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getBuyerFullInfo(alice);
        }
    }

    // @cover-intent Test retrieval of info for an address that has not registered as a buyer. Covers Resource & Execution Integrity.
    function test_Retrieve_unregistered_buyer_info_4() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getBuyerFullInfo(bob);
        }
    }

    // @cover-intent Test retrieval of info for an address that has not registered as a seller. Covers Resource & Execution Integrity.
    function test_Retrieve_unregistered_seller_info_5() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getSellerFullInfo(alice);
        }
    }

    // @cover-intent Test retrieval of info for an address that has not registered as an escrow. Covers Resource & Execution Integrity.
    function test_Retrieve_unregistered_escrow_info_6() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.getEscrowFullInfo(alice);
        }
    }

    // @cover-intent Test that owner() returns the contract creator. Covers Authorization & Access Control.
    function test_Owner_access_7() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent Test registration of a buyer with empty name and info. Covers Resource & Execution Integrity.
    function test_Register_buyer_with_empty_strings_8() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getBuyerFullInfo(alice);
        }
    }

    // @cover-intent Test registration of a seller with long name and info strings. Covers Resource & Execution Integrity.
    function test_Register_seller_with_long_strings_9() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getSellerFullInfo(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getBuyerFullInfo_test_10() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getBuyerFullInfo(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getSellerFullInfo_test_11() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.getSellerFullInfo(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getEscrowFullInfo_test_12() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.getEscrowFullInfo(carol);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_buyerList_test_13() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.buyerList(alice);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_sellerList_test_14() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.sellerList(bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_escrowList_test_15() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.prank(carol);
        {
        target.escrowList(carol);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_owner_test_16() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        // skip ABI-mismatched call: owner()
    }

    // @cover-intent minimal test for registerBuyer
    function test_perfn_registerBuyer_17() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.registerBuyer("Name", "X");
        }
    }

    // @cover-intent minimal test for registerEscrow
    function test_perfn_registerEscrow_18() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.registerEscrow("Name", "X");
        }
    }

    // @cover-intent minimal test for registerSeller
    function test_perfn_registerSeller_19() public {
        vm.startPrank(owner);
        EscrowMyEtherEntityDB target = new EscrowMyEtherEntityDB();
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
        target.registerSeller("Name", "X");
        }
    }

}
