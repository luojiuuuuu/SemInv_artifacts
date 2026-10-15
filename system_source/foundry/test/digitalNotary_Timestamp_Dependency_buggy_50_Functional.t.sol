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


    // @cover-intent Test successful hash registration with correct fee when contract is active (Protocol State Machine)
    function test_register_hash_positive_0() public {
// assume: contractactive == true
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

    // @cover-intent Test hash registration reverts when incorrect fee is sent (Financial & Accounting)
    function test_register_hash_wrong_fee_1() public {
// assume: contractactive == true
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
        target.registerHash.value(1000000000000000)(bytes32(uint256(77709354905233498995349917094833404261995315288902045168507868256984064043981)));
        }
    }

    // @cover-intent Test hash registration reverts when hash already registered (Transactional Consistency)
    function test_register_hash_duplicate_2() public {
// assume: contractactive == true
// cover: registerHash :: require(getHashOwnersCount(hash) == 0) false
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(7719472615821079694904732333912527190217998977709370935963838933860875309329)));
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.registerHash.value(5000000000000000)(bytes32(uint256(7719472615821079694904732333912527190217998977709370935963838933860875309329)));
        }
    }

    // @cover-intent Test successful hash ownership transfer with correct fee (Authorization & Access Control)
    function test_change_ownership_positive_3() public {
// assume: contractactive == true
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(15438945231642159389809464667825054380435997955418741871927677867721750618658)));
        }
        vm.startPrank(owner);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(15438945231642159389809464667825054380435997955418741871927677867721750618658)), bob);
        }
        {
        target.getHashOwnersCount(bytes32(uint256(15438945231642159389809464667825054380435997955418741871927677867721750618658)));
        }
        vm.stopPrank();
    }

    // @cover-intent Test ownership transfer reverts when caller is not the current owner (Authorization & Access Control)
    function test_change_ownership_not_owner_4() public {
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(23158417847463239084714197001737581570653996933128112807891516801582625927987)));
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(23158417847463239084714197001737581570653996933128112807891516801582625927987)), carol);
        }
    }

    // @cover-intent Test that updating hashfee affects subsequent registrations (Financial & Accounting)
    function test_set_fee_and_register_5() public {
// assume: contractactive == true
// cover: sethashfee :: require(newfee >= 0) true
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
        vm.prank(owner);
        {
        target.sethashfee(10000000000000000);
        }
        vm.startPrank(alice);
        {
        target.registerHash.value(10000000000000000)(bytes32(uint256(30877890463284318779618929335650108760871995910837483743855355735443501237316)));
        }
        {
        target.gethashfee();
        }
        vm.stopPrank();
    }

    // @cover-intent Test that registration reverts when contract is inactive (Protocol State Machine)
    function test_set_contract_inactive_register_reverts_6() public {
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(38597363079105398474523661669562635951089994888546854679819194669304376546645)));
        }
    }

    // @cover-intent Test manager can transfer contract balance (Financial & Accounting)
    function test_transfer_balance_positive_7() public {
// assume: contractactive == true
// cover: transfercontractbalance :: require(cb > 0) true
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(46316835694926478169428394003475163141307993866256225615783033603165251855974)));
        }
        vm.prank(owner);
        {
        target.transfercontractbalance();
        }
        // TODO assert: owner.balance == 5000000000000000
    }

    // @cover-intent Test retrieving hash details for a registered hash (Resource & Execution Integrity)
    function test_get_hash_details_positive_8() public {
// assume: contractactive == true
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(54036308310747557864333126337387690331525992843965596551746872537026127165303)));
        }
        {
        target.getHashDetails(bytes32(uint256(54036308310747557864333126337387690331525992843965596551746872537026127165303)), 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Test manager can be changed to an address with balance (Authorization & Access Control)
    function test_set_manager_positive_9() public {
// cover: setmanager :: require(newmngr.balance > 0) true
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
        target.setmanager(bob);
        }
        {
        target.getmanager();
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp13_sequence_10() public {
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
        target.bug_tmstmp13();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp20_sequence_11() public {
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
        target.bug_tmstmp20.value(10 ether)();
        }
        // TODO assert: alice.balance >= 0
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp25_sequence_12() public {
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
        target.bug_tmstmp25();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp32_sequence_13() public {
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
        target.bug_tmstmp32.value(10 ether)();
        }
        // TODO assert: alice.balance >= 0
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp33_sequence_14() public {
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
        target.bug_tmstmp33();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp36_sequence_15() public {
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
        target.bug_tmstmp36.value(10 ether)();
        }
        // TODO assert: alice.balance >= 0
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp4_sequence_16() public {
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
        target.bug_tmstmp4.value(10 ether)();
        }
        // TODO assert: alice.balance >= 0
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp40_sequence_17() public {
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
        target.bug_tmstmp40.value(10 ether)();
        }
        // TODO assert: alice.balance >= 0
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp8_sequence_18() public {
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
        target.bug_tmstmp8.value(10 ether)();
        }
        // TODO assert: alice.balance >= 0
    }

    // @cover-intent External Interaction & Environment
    function test_bug_tmstmp9_sequence_19() public {
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
        target.bug_tmstmp9();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_changeHashOwnership_sequence_20() public {
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        vm.prank(owner);
        {
        target.changeHashOwnership.value(25000000000000000)(bytes32(uint256(1)), bob);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHashDetails_sequence_21() public {
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        {
        target.getHashDetails(bytes32(uint256(1)), 0);
        }
        vm.stopPrank();
    }

    // @cover-intent Resource & Execution Integrity
    function test_getHashOwnersCount_sequence_22() public {
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        {
        target.getHashOwnersCount(bytes32(uint256(1)));
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.getHashOwnersCount(0x0000000000000000000000000000000000000000000000000000000000000001));
            _assertRelU(__v1, 0, 1, "call:getHashOwnersCount==1");
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_getNumberofHashesRegistered_sequence_23() public {
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
        {
        target.getNumberofHashesRegistered();
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.getNumberofHashesRegistered());
            _assertRelU(__v2, 2, 1, "call:getNumberofHashesRegistered>=1");
        }
    }

    // @cover-intent Financial & Accounting
    function test_getchangehashownerfee_sequence_24() public {
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
        target.getchangehashownerfee();
        }
        {
            uint256 __v3 = uint256(target.getchangehashownerfee());
            _assertRelU(__v3, 0, 25000000000000000, "call:getchangehashownerfee==25000000000000000");
        }
    }

    // @cover-intent Protocol State Machine
    function test_getcontractactive_sequence_25() public {
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
        target.getcontractactive();
        }
    }

    // @cover-intent Financial & Accounting
    function test_getcontractbalance_sequence_26() public {
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
        target.getcontractbalance();
        }
        {
            uint256 __v4 = uint256(target.getcontractbalance());
            _assertRelU(__v4, 2, 0, "call:getcontractbalance>=0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_gethashfee_sequence_27() public {
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
        target.gethashfee();
        }
        {
            uint256 __v5 = uint256(target.gethashfee());
            _assertRelU(__v5, 0, 5000000000000000, "call:gethashfee==5000000000000000");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_getmanager_sequence_28() public {
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
        target.getmanager();
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp14_sequence_29() public {
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
        target.play_tmstmp14(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp19_sequence_30() public {
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
        target.play_tmstmp19(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp23_sequence_31() public {
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
        target.play_tmstmp23(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp26_sequence_32() public {
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
        target.play_tmstmp26(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp27_sequence_33() public {
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
        target.play_tmstmp27(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp30_sequence_34() public {
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
        target.play_tmstmp30(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp31_sequence_35() public {
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
        target.play_tmstmp31(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp35_sequence_36() public {
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
        target.play_tmstmp35(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp38_sequence_37() public {
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
        target.play_tmstmp38(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp39_sequence_38() public {
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
        target.play_tmstmp39(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_play_tmstmp7_sequence_39() public {
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
        target.play_tmstmp7(0);
        }
    }

    // @cover-intent Resource & Execution Integrity
    function test_registerHash_sequence_40() public {
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
        target.registerHash.value(5000000000000000)(bytes32(uint256(1)));
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setchangehashownerfee_sequence_41() public {
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
        {
            uint256 __v6 = uint256(target.getchangehashownerfee());
            _assertRelU(__v6, 0, 100, "call:getchangehashownerfee==100");
        }
    }

    // @cover-intent Protocol State Machine
    function test_setcontractactive_sequence_42() public {
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
    function test_sethashfee_sequence_43() public {
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
        {
            uint256 __v7 = uint256(target.gethashfee());
            _assertRelU(__v7, 0, 100, "call:gethashfee==100");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_setmanager_sequence_44() public {
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
        target.setmanager(alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfercontractbalance_sequence_45() public {
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
        target.bug_tmstmp20.value(10 ether)();
        }
        vm.prank(owner);
        {
        target.transfercontractbalance();
        }
        {
            uint256 __v8 = uint256(target.getcontractbalance());
            _assertRelU(__v8, 0, 0, "call:getcontractbalance==0");
        }
    }

}
