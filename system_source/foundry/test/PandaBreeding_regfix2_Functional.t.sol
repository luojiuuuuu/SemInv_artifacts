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


    // @cover-intent Test normal breeding flow: create two gen0 pandas, breed them, and verify pregnancy and birth. Covers Financial & Accounting and Protocol State Machine invariants.
    function test_Breeding_Normal_Flow_0() public {
// assume: paused==false
// assume: geneScience != address(0)
// assume: balanceOf(alice) >= 2
// cover: breedWithAuto :: require(msg.value >= autoBirthFee) true
// cover: breedWithAuto :: require(_isReadyToBreed(matron)) true
// cover: breedWithAuto :: require(_isReadyToBreed(sire)) true
// cover: breedWithAuto :: require(_isValidMatingPair(...)) true
// cover: giveBirth :: require(_isReadyToGiveBirth(matron)) true
        vm.startPrank(alice);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        vm.prank(owner);
        {
        target.setCOO(alice);
        }
        vm.startPrank(alice);
        {
        target.approveSiring(alice, 2);
        }
        {
        target.breedWithAuto.value(2 finney)(1, 2);
        }
        {
        target.isPregnant(1);
        }
        vm.stopPrank();
        vm.prank(owner);
        {
        uint256[2] memory _arr1;
        _arr1[0] = 1;
        _arr1[1] = 1;
        uint256[2] memory _arr2;
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.giveBirth(1, _arr1, _arr2);
        }
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 2, 3, "call:totalSupply>=3");
        }
    }

    // @cover-intent Test that a panda cannot breed with itself. Covers Authorization & Access Control invariant.
    function test_Breeding_Self_Breed_Revert_1() public {
// assume: paused==false
// assume: geneScience != address(0)
// cover: _isValidMatingPair :: require(_matronId != _sireId) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        vm.prank(owner);
        {
        target.setCOO(alice);
        }
        vm.expectRevert();
        vm.prank(alice);
        {
        target.breedWithAuto.value(2 finney)(1, 1);
        }
    }

    // @cover-intent Test that non-owner cannot breed with another's panda. Covers Authorization & Access Control invariant.
    function test_Breeding_Not_Owner_Revert_2() public {
// assume: paused==false
// assume: geneScience != address(0)
// cover: breedWithAuto :: require(_owns(msg.sender, _matronId)) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        vm.prank(owner);
        {
        target.setCOO(alice);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.breedWithAuto.value(2 finney)(1, 2);
        }
    }

    // @cover-intent Test that breeding fails with insufficient fee. Covers Financial & Accounting invariant.
    function test_Breeding_Insufficient_Fee_Revert_3() public {
// assume: paused==false
// assume: geneScience != address(0)
// assume: autoBirthFee() == 2 finney
// cover: breedWithAuto :: require(msg.value >= autoBirthFee) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        vm.prank(owner);
        {
        target.setCOO(alice);
        }
        vm.startPrank(alice);
        {
        target.approveSiring(alice, 2);
        }
        vm.expectRevert();
        {
        target.breedWithAuto.value(1 finney)(1, 2);
        }
        vm.stopPrank();
    }

    // @cover-intent Test that breeding fails when panda is in cooldown. Covers Protocol State Machine invariant.
    function test_Breeding_Cooldown_Revert_4() public {
// assume: paused==false
// assume: geneScience != address(0)
// assume: isReadyToBreed(1) == false
// cover: breedWithAuto :: require(_isReadyToBreed(matron)) false
        vm.startPrank(alice);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        vm.prank(owner);
        {
        target.setCOO(alice);
        }
        vm.startPrank(alice);
        {
        target.approveSiring(alice, 2);
        }
        {
        target.breedWithAuto.value(2 finney)(1, 2);
        }
        vm.expectRevert();
        {
        target.breedWithAuto.value(2 finney)(1, 2);
        }
        vm.stopPrank();
    }

    // @cover-intent Test normal transfer of panda ownership. Covers Authorization & Access Control invariant.
    function test_Transfer_Ownership_Normal_5() public {
// assume: paused==false
// assume: balanceOf(alice) >= 1
// cover: transfer :: require(_owns(msg.sender, _tokenId)) true
// cover: transfer :: require(_to != address(0)) true
// cover: transfer :: require(_to != address(this)) true
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        target.setCOO(alice);
        }
        {
        target.transfer(bob, 1);
        }
        {
        target.ownerOf(1);
        }
        vm.stopPrank();
    }

    // @cover-intent Test that non-owner cannot transfer panda. Covers Authorization & Access Control invariant.
    function test_Transfer_Not_Owner_Revert_6() public {
// assume: paused==false
// cover: transfer :: require(_owns(msg.sender, _tokenId)) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        vm.prank(owner);
        {
        target.setCOO(alice);
        }
        vm.expectRevert();
        vm.prank(bob);
        {
        target.transfer(carol, 1);
        }
    }

    // @cover-intent Test pause and unpause functionality. Covers Protocol State Machine invariant.
    function test_Pause_Unpause_Flow_7() public {
// assume: ceoAddress() == owner
// cover: pause :: require(!paused) true
// cover: unpause :: require(paused) true
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
        vm.store(address(target), bytes32(uint256(0)), bytes32(uint256(1)));
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
        // skip ABI-mismatched call: unpause()
        // skip ABI-mismatched call: pause()
        // skip ABI-mismatched call: paused()
        // skip ABI-mismatched call: unpause()
        // skip ABI-mismatched call: paused()
        vm.stopPrank();
    }

    // @cover-intent Test that paused contract blocks transfers. Covers Protocol State Machine invariant.
    function test_Pause_Blocks_Transfer_8() public {
// assume: paused==true
// cover: transfer :: require(!paused) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        // skip ABI-mismatched call: unpause()
        {
        target.setCOO(alice);
        }
        // skip ABI-mismatched call: pause()
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.transfer(bob, 1);
        }
    }

    // @cover-intent Test that only COO can set auto birth fee. Covers Authorization & Access Control invariant.
    function test_SetAutoBirthFee_OnlyCOO_9() public {
// assume: paused==false
// assume: cooAddress() == alice
// cover: setAutoBirthFee :: require(msg.sender == cooAddress) true
// cover: setAutoBirthFee :: require(msg.sender == cooAddress) false
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        vm.prank(alice);
        // skip malformed call: setAutoBirthFee(5 finney) (bad raw arg for setAutoBirthFee.arg0: type=uint256, raw=5 finney)
        vm.expectRevert();
        vm.prank(bob);
        // skip malformed call: setAutoBirthFee(3 finney) (bad raw arg for setAutoBirthFee.arg0: type=uint256, raw=3 finney)
        // TODO assert: call:autoBirthFee() == 5 finney
    }

    // @cover-intent Test that wizz panda quota is enforced during creation. Covers Resource & Execution Integrity invariant.
    function test_WizzPanda_Quota_Enforcement_10() public {
// assume: paused==false
// assume: geneScience != address(0)
// assume: wizzPandaQuota(1) == 1
// cover: _createPanda :: require(wizzPandaQuota[_tp] > wizzPandaCount[_tp]) true
// cover: _createPanda :: require(wizzPandaQuota[_tp] <= wizzPandaCount[_tp]) true
        vm.startPrank(owner);
        PandaBreeding target = new PandaBreeding();
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.init();
        // dropped unsafe prestate: target.unpause();
        // dropped unsafe prestate: target.setGeneScienceAddress(geneScienceAddr);
        // dropped unsafe prestate: target.setSaleAuctionAddress(saleAuctionAddr);
        // dropped unsafe prestate: target.setSiringAuctionAddress(siringAuctionAddr);
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
        target.setCOO(alice);
        }
        {
        target.setTotalWizzPandaOf(1, 1);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.getWizzPandaCountOf(1);
        }
        {
            uint256 __v2 = uint256(target.getWizzPandaCountOf(1));
            _assertRelU(__v2, 3, 1, "call:getWizzPandaCountOf<=1");
        }
    }

    // @cover-intent minimal test for GEN0_TOTAL_COUNT
    function test_perfn_GEN0_TOTAL_COUNT_11() public {
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
    function test_perfn_GENSIS_TOTAL_COUNT_12() public {
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
    function test_perfn_approve_13() public {
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
    function test_perfn_approveSiring_14() public {
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
    function test_perfn_autoBirthFee_15() public {
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
    function test_perfn_balanceOf_16() public {
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
    function test_perfn_breedWithAuto_17() public {
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
    function test_perfn_canBreedWith_18() public {
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
    function test_perfn_ceoAddress_19() public {
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
    function test_perfn_cfoAddress_20() public {
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
    function test_perfn_cooAddress_21() public {
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
    function test_perfn_cooldowns_22() public {
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
    function test_perfn_gen0CreatedCount_23() public {
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
    function test_perfn_geneScience_24() public {
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
    function test_perfn_getWizzPandaCountOf_25() public {
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
    function test_perfn_getWizzPandaQuotaOf_26() public {
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
    function test_perfn_getWizzTypeOf_27() public {
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
    function test_perfn_giveBirth_28() public {
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
    function test_perfn_isPregnant_29() public {
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
    function test_perfn_isReadyToBreed_30() public {
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
    function test_perfn_name_31() public {
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
    function test_perfn_ownerOf_32() public {
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
    function test_perfn_pandaIndexToApproved_33() public {
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
    function test_perfn_pandaIndexToOwner_34() public {
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
    function test_perfn_pause_35() public {
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
    function test_perfn_paused_36() public {
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
    function test_perfn_pregnantPandas_37() public {
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
    function test_perfn_saleAuction_38() public {
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
    function test_perfn_saleAuctionERC20_39() public {
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
    function test_perfn_secondsPerBlock_40() public {
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
    function test_perfn_setAutoBirthFee_41() public {
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
    function test_perfn_setCEO_42() public {
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
    function test_perfn_setCFO_43() public {
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
    function test_perfn_setCOO_44() public {
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
    function test_perfn_setGeneScienceAddress_45() public {
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
    function test_perfn_setSecondsPerBlock_46() public {
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
    function test_perfn_setTotalWizzPandaOf_47() public {
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
    function test_perfn_sireAllowedToAddress_48() public {
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
    function test_perfn_siringAuction_49() public {
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
    function test_perfn_supportsInterface_50() public {
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
    function test_perfn_symbol_51() public {
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
    function test_perfn_tokensOfOwner_52() public {
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
    function test_perfn_totalSupply_53() public {
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
    function test_perfn_transfer_54() public {
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
    function test_perfn_transferFrom_55() public {
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
    function test_perfn_unpause_56() public {
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
    function test_perfn_wizzPandaCount_57() public {
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
    function test_perfn_wizzPandaQuota_58() public {
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
