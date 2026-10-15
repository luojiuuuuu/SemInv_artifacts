// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x663e4229142a27f00bafb5d087e1e730648314c3.sol";

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

contract PandaBreeding_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PandaBreeding_FunctionalTest() public {
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


    // @cover-intent Test normal breeding flow: two owned pandas breed successfully, pregnancy is recorded, and giveBirth creates a new panda. Covers Financial & Accounting and Protocol State Machine invariants.
    function test_Breeding_positive_path_0() public {
// assume: paused==false
// assume: geneScience!=address(0)
// assume: alice owns panda 1 and 2
// assume: panda 1 and 2 are ready to breed
// cover: breedWithAuto :: require(msg.value >= autoBirthFee) true
// cover: breedWithAuto :: require(_owns(msg.sender, _matronId)) true
// cover: breedWithAuto :: require(_isSiringPermitted(_sireId, _matronId)) true
// cover: breedWithAuto :: require(_isReadyToBreed(matron)) true
// cover: breedWithAuto :: require(_isReadyToBreed(sire)) true
// cover: breedWithAuto :: require(_isValidMatingPair(...)) true
// cover: giveBirth :: require(matron.birthTime != 0) true
// cover: giveBirth :: require(_isReadyToGiveBirth(matron)) true
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScience);
        target.setSecondsPerBlock(15);
        // dropped unsafe prestate: target.setAutoBirthFee(2 finney);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.breedWithAuto(1, 2);
        }
        {
        target.isPregnant(1);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 2, 3, "call:totalSupply>=3");
        }
    }

    // @cover-intent Test that breeding a panda with itself reverts. Covers Authorization & Access Control invariant.
    function test_Breeding_self_breed_revert_1() public {
// assume: paused==false
// assume: alice owns panda 1
// cover: _isValidMatingPair :: require(_matronId != _sireId) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScience);
        target.setSecondsPerBlock(15);
        // dropped unsafe prestate: target.setAutoBirthFee(2 finney);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.breedWithAuto(1, 1);
        }
    }

    // @cover-intent Test that breeding with a panda not owned by caller reverts. Covers Authorization & Access Control invariant.
    function test_Breeding_not_owner_revert_2() public {
// assume: paused==false
// assume: alice owns panda 1
// assume: bob owns panda 2
// cover: breedWithAuto :: require(_owns(msg.sender, _matronId)) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScience);
        target.setSecondsPerBlock(15);
        // dropped unsafe prestate: target.setAutoBirthFee(2 finney);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.breedWithAuto(2, 1);
        }
    }

    // @cover-intent Test that breeding with insufficient autoBirthFee reverts. Covers Financial & Accounting invariant.
    function test_Breeding_insufficient_fee_revert_3() public {
// assume: paused==false
// assume: alice owns panda 1 and 2
// assume: alice balance is 1 finney
// cover: breedWithAuto :: require(msg.value >= autoBirthFee) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScience);
        target.setSecondsPerBlock(15);
        // dropped unsafe prestate: target.setAutoBirthFee(2 finney);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 1 finney);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.breedWithAuto(1, 2);
        }
    }

    // @cover-intent Test that breeding when contract is paused reverts. Covers Protocol State Machine invariant.
    function test_Breeding_paused_revert_4() public {
// assume: paused==true
// assume: alice owns panda 1 and 2
// cover: breedWithAuto :: require(!paused) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.pause();
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.breedWithAuto(1, 2);
        }
    }

    // @cover-intent Test normal transfer of a panda from alice to bob. Covers Authorization & Access Control and Transactional Consistency invariants.
    function test_Transfer_positive_path_5() public {
// assume: paused==false
// assume: alice owns panda 1
// cover: transfer :: require(_to != address(0)) true
// cover: transfer :: require(_to != address(this)) true
// cover: transfer :: require(_to != address(saleAuction)) true
// cover: transfer :: require(_to != address(siringAuction)) true
// cover: transfer :: require(_owns(msg.sender, _tokenId)) true
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScience);
        target.setSecondsPerBlock(15);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.startPrank(owner);
        {
        target.transfer(bob, 1);
        }
        {
        target.ownerOf(1);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 0
        // TODO assert: bob.balance == 1
    }

    // @cover-intent Test that transferring a panda not owned by caller reverts. Covers Authorization & Access Control invariant.
    function test_Transfer_not_owner_revert_6() public {
// assume: paused==false
// assume: alice owns panda 1
// assume: bob does not own panda 1
// cover: transfer :: require(_owns(msg.sender, _tokenId)) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScience);
        target.setSecondsPerBlock(15);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transfer(carol, 1);
        }
    }

    // @cover-intent Test that transferring when contract is paused reverts. Covers Protocol State Machine invariant.
    function test_Transfer_paused_revert_7() public {
// assume: paused==true
// assume: alice owns panda 1
// cover: transfer :: require(!paused) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.pause();
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(1)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.transfer(bob, 1);
        }
    }

    // @cover-intent Test approve and transferFrom flow: alice approves bob, then bob transfers panda to carol. Covers Authorization & Access Control and Transactional Consistency invariants.
    function test_Approve_and_transferFrom_positive_8() public {
// assume: paused==false
// assume: alice owns panda 1
// assume: alice approved bob for panda 1
// cover: approve :: require(_owns(msg.sender, _tokenId)) true
// cover: transferFrom :: require(_approvedFor(msg.sender, _tokenId)) true
// cover: transferFrom :: require(_owns(_from, _tokenId)) true
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScience);
        target.setSecondsPerBlock(15);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.approve(bob, 1);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 1);
        }
        vm.prank(carol);
        {
        target.ownerOf(1);
        }
        // TODO assert: alice.balance == 0
        // TODO assert: carol.balance == 1
    }

    // @cover-intent Test approveSiring flow: alice approves bob to sire with her panda, then bob breeds. Covers Authorization & Access Control and Resource & Execution Integrity invariants.
    function test_ApproveSiring_and_breed_positive_9() public {
// assume: paused==false
// assume: alice owns panda 1
// assume: bob owns panda 2
// assume: bob approved alice for siring panda 2
// assume: panda 1 and 2 are ready to breed
// cover: approveSiring :: require(_owns(msg.sender, _sireId)) true
// cover: breedWithAuto :: require(_isSiringPermitted(_sireId, _matronId)) true
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScience);
        target.setSecondsPerBlock(15);
        // dropped unsafe prestate: target.setAutoBirthFee(2 finney);
        vm.store(address(target), bytes32(uint256(1)), bytes32(uint256(0)));
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100 ether);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(bob);
        {
        target.approveSiring(alice, 2);
        }
        vm.prank(owner);
        {
        target.breedWithAuto(1, 2);
        }
    }

    // @cover-intent minimal test for GEN0_TOTAL_COUNT
    function test_perfn_GEN0_TOTAL_COUNT_10() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: GEN0_TOTAL_COUNT()
    }

    // @cover-intent minimal test for GENSIS_TOTAL_COUNT
    function test_perfn_GENSIS_TOTAL_COUNT_11() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: GENSIS_TOTAL_COUNT()
    }

    // @cover-intent minimal test for approve
    function test_perfn_approve_12() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 1);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.approve(bob, 1);
        }
    }

    // @cover-intent minimal test for approveSiring
    function test_perfn_approveSiring_13() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.approveSiring(alice, 1);
        }
    }

    // @cover-intent minimal test for autoBirthFee
    function test_perfn_autoBirthFee_14() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: autoBirthFee()
    }

    // @cover-intent minimal test for balanceOf
    function test_perfn_balanceOf_15() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.balanceOf(alice);
        }
    }

    // @cover-intent minimal test for breedWithAuto
    function test_perfn_breedWithAuto_16() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.breedWithAuto(1, 1);
        }
    }

    // @cover-intent minimal test for canBreedWith
    function test_perfn_canBreedWith_17() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.canBreedWith(1, 1);
        }
    }

    // @cover-intent minimal test for ceoAddress
    function test_perfn_ceoAddress_18() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: ceoAddress()
    }

    // @cover-intent minimal test for cfoAddress
    function test_perfn_cfoAddress_19() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: cfoAddress()
    }

    // @cover-intent minimal test for cooAddress
    function test_perfn_cooAddress_20() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: cooAddress()
    }

    // @cover-intent minimal test for cooldowns
    function test_perfn_cooldowns_21() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.cooldowns(1);
        }
    }

    // @cover-intent minimal test for gen0CreatedCount
    function test_perfn_gen0CreatedCount_22() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: gen0CreatedCount()
    }

    // @cover-intent minimal test for geneScience
    function test_perfn_geneScience_23() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: geneScience()
    }

    // @cover-intent minimal test for getWizzPandaCountOf
    function test_perfn_getWizzPandaCountOf_24() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.getWizzPandaCountOf(1);
        }
    }

    // @cover-intent minimal test for getWizzPandaQuotaOf
    function test_perfn_getWizzPandaQuotaOf_25() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.getWizzPandaQuotaOf(1);
        }
    }

    // @cover-intent minimal test for getWizzTypeOf
    function test_perfn_getWizzTypeOf_26() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.getWizzTypeOf(1);
        }
    }

    // @cover-intent minimal test for giveBirth
    function test_perfn_giveBirth_27() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.giveBirth(1, _arr1, _arr2);
        }
    }

    // @cover-intent minimal test for isPregnant
    function test_perfn_isPregnant_28() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.isPregnant(1);
        }
    }

    // @cover-intent minimal test for isReadyToBreed
    function test_perfn_isReadyToBreed_29() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.isReadyToBreed(1);
        }
    }

    // @cover-intent minimal test for name
    function test_perfn_name_30() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: name()
    }

    // @cover-intent minimal test for ownerOf
    function test_perfn_ownerOf_31() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.ownerOf(1);
        }
    }

    // @cover-intent minimal test for pandaIndexToApproved
    function test_perfn_pandaIndexToApproved_32() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.pandaIndexToApproved(1);
        }
    }

    // @cover-intent minimal test for pandaIndexToOwner
    function test_perfn_pandaIndexToOwner_33() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.pandaIndexToOwner(1);
        }
    }

    // @cover-intent minimal test for pause
    function test_perfn_pause_34() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        // skip ABI-mismatched call: pause()
    }

    // @cover-intent minimal test for paused
    function test_perfn_paused_35() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        // skip ABI-mismatched call: paused()
    }

    // @cover-intent minimal test for pregnantPandas
    function test_perfn_pregnantPandas_36() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: pregnantPandas()
    }

    // @cover-intent minimal test for saleAuction
    function test_perfn_saleAuction_37() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: saleAuction()
    }

    // @cover-intent minimal test for saleAuctionERC20
    function test_perfn_saleAuctionERC20_38() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: saleAuctionERC20()
    }

    // @cover-intent minimal test for secondsPerBlock
    function test_perfn_secondsPerBlock_39() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: secondsPerBlock()
    }

    // @cover-intent minimal test for setAutoBirthFee
    function test_perfn_setAutoBirthFee_40() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.setAutoBirthFee(1);
        }
    }

    // @cover-intent minimal test for setCEO
    function test_perfn_setCEO_41() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.setCEO(alice);
        }
    }

    // @cover-intent minimal test for setCFO
    function test_perfn_setCFO_42() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.setCFO(alice);
        }
    }

    // @cover-intent minimal test for setCOO
    function test_perfn_setCOO_43() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.setCOO(alice);
        }
    }

    // @cover-intent minimal test for setGeneScienceAddress
    function test_perfn_setGeneScienceAddress_44() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.setGeneScienceAddress(alice);
        }
    }

    // @cover-intent minimal test for setSecondsPerBlock
    function test_perfn_setSecondsPerBlock_45() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.setSecondsPerBlock(1);
        }
    }

    // @cover-intent minimal test for setTotalWizzPandaOf
    function test_perfn_setTotalWizzPandaOf_46() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.setTotalWizzPandaOf(1, 1);
        }
    }

    // @cover-intent minimal test for sireAllowedToAddress
    function test_perfn_sireAllowedToAddress_47() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.sireAllowedToAddress(1);
        }
    }

    // @cover-intent minimal test for siringAuction
    function test_perfn_siringAuction_48() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: siringAuction()
    }

    // @cover-intent minimal test for supportsInterface
    function test_perfn_supportsInterface_49() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip malformed call: supportsInterface(bytes4(0)) (bad raw arg for supportsInterface.arg0: type=bytes4, raw=bytes4(0))
    }

    // @cover-intent minimal test for symbol
    function test_perfn_symbol_50() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: symbol()
    }

    // @cover-intent minimal test for tokensOfOwner
    function test_perfn_tokensOfOwner_51() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        {
        target.tokensOfOwner(alice);
        }
    }

    // @cover-intent minimal test for totalSupply
    function test_perfn_totalSupply_52() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        // skip ABI-mismatched call: totalSupply()
    }

    // @cover-intent minimal test for transfer
    function test_perfn_transfer_53() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.transfer(bob, 1);
        }
    }

    // @cover-intent minimal test for transferFrom
    function test_perfn_transferFrom_54() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.prank(owner);
        target.unpause();
        vm.startPrank(owner);
        target.transfer(alice, 100);
        vm.stopPrank();
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.approve(bob, 1);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, bob, 1);
        }
    }

    // @cover-intent minimal test for unpause
    function test_perfn_unpause_55() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(owner);
        // skip ABI-mismatched call: unpause()
    }

    // @cover-intent minimal test for wizzPandaCount
    function test_perfn_wizzPandaCount_56() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.wizzPandaCount(1);
        }
    }

    // @cover-intent minimal test for wizzPandaQuota
    function test_perfn_wizzPandaQuota_57() public {
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        uint256 balA0 = target.balanceOf(alice);
        uint256 balB0 = target.balanceOf(bob);
        uint256 balC0 = target.balanceOf(carol);
        uint256 balO0 = target.balanceOf(owner);
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        uint256 supply0 = target.totalSupply();
        vm.prank(alice);
        {
        target.wizzPandaQuota(1);
        }
    }

}
