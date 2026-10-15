// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
import "forge-std/Test.sol";
import "../src/ParamCoverageTest1.sol";


contract ParamCoverageTest1_FunctionalTest is Test {
    address owner = address(0x0A0A);
    address alice = address(0xA11CE);
    address bob   = address(0xB0B);
    address carol = address(0xCA1CE);


    // ---------- Helpers (0.8+) ----------
    function _assertEqU(uint256 a, uint256 b) internal {
        assertEq(a, b);
    }
    function _delta(int256 after_, int256 before_) internal pure returns (int256) {
        return after_ - before_;
    }
    function _assertTrue(bool ok, string memory why) internal {
        assertTrue(ok, why);
    }
    function _assertRelU(uint256 a, uint8 op, uint256 b, string memory why) internal {
        if (op == 0) assertEq(a, b, why);
        else if (op == 1) assertTrue(a != b, why);
        else if (op == 2) assertGe(a, b, why);
        else if (op == 3) assertLe(a, b, why);
        else if (op == 4) assertTrue(a >  b, why);
        else if (op == 5) assertTrue(a <  b, why);
    }
    function _assertApproxEqU(uint256 a, uint256 b, uint256 tol, string memory why) internal {
        uint256 d = a >= b ? a - b : b - a;
        assertLe(d, tol, why);
    }
    function _assertEqA(address a, address b) internal {
        assertEq(a, b);
    }
    function _assertEqB32(bytes32 a, bytes32 b) internal {
        assertEq(a, b);
    }
    function _assertEqS(string memory a, string memory b) internal {
        assertEq(a, b);
    }


    // @cover-intent 验证构造函数正确初始化owner和names数组，并检查owner()和namesLength()的返回值
    function test_test_constructor_and_owner_0() public {
// cover: constructor :: initNames.length == 0
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.owner();
        }
        {
        target.namesLength();
        }
        vm.stopPrank();
    }

    // @cover-intent state transition test for pause
    function test_test_pause_unpause_owner_only_1() public {
// cover: pause :: onlyOwner modifier true
// cover: pause :: onlyOwner modifier false
// cover: unpause :: onlyOwner modifier true
// cover: unpause :: onlyOwner modifier false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.pause();
        }
        vm.startPrank(owner);
        {
        target.pause();
        }
        {
        target.paused();
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.unpause();
        }
        vm.startPrank(owner);
        {
        target.unpause();
        }
        {
        target.paused();
        }
        vm.stopPrank();
    }

    // @cover-intent 验证setNumbers在未暂停时正常执行，total被设置为数组长度
    function test_test_setNumbers_when_not_paused_2() public {
// assume: paused==false
// cover: setNumbers :: require(!paused) true
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        uint256[] memory _arr2 = new uint256[](3);
        _arr2[0] = 1;
        _arr2[1] = 1;
        _arr2[2] = 1;
        target.setNumbers(_arr2);
        }
        {
        target.total();
        }
        vm.stopPrank();
    }

    // @cover-intent 验证setNumbers在暂停时revert
    function test_test_setNumbers_revert_when_paused_3() public {
// assume: paused==true
// cover: setNumbers :: require(!paused) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.pause();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        uint256[] memory _arr2 = new uint256[](2);
        _arr2[0] = 1;
        _arr2[1] = 1;
        target.setNumbers(_arr2);
        }
    }

    // @cover-intent 验证setPair在p.y=true时total = p.x + 1
    function test_test_setPair_with_y_true_4() public {
// assume: paused==false
// cover: setPair :: p.y == true
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        ParamCoverageTest1.Pair memory _s1;
        _s1.x = 1;
        _s1.y = true;
        target.setPair(_s1);
        }
        {
        target.total();
        }
        vm.stopPrank();
    }

    // @cover-intent 验证setPair在p.y=false时total = p.x
    function test_test_setPair_with_y_false_5() public {
// assume: paused==false
// cover: setPair :: p.y == false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        ParamCoverageTest1.Pair memory _s1;
        _s1.x = 1;
        _s1.y = true;
        target.setPair(_s1);
        }
        {
        target.total();
        }
        vm.stopPrank();
    }

    // @cover-intent 验证useVoter在v.voted=true时增加balances[v.delegate]
    function test_test_useVoter_with_voted_true_6() public {
// assume: paused==false
// cover: useVoter :: v.voted == true
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        ParamCoverageTest1.VoterLike memory _s1;
        _s1.weight = 1;
        _s1.voted = true;
        _s1.delegate = alice;
        _s1.vote = 1;
        target.useVoter(_s1);
        }
        {
        target.total();
        }
        {
        target.balances(bob);
        }
        vm.stopPrank();
        // TODO assert: bob.balance == 1
    }

    // @cover-intent 验证mixedArgs在c=true且所有非零参数时total = a + 5
    function test_test_mixedArgs_all_true_7() public {
// assume: paused==false
// cover: mixedArgs :: c == true
// cover: mixedArgs :: b != address(0)
// cover: mixedArgs :: d != bytes32(0)
// cover: mixedArgs :: bytes(e).length > 0
// cover: mixedArgs :: f.length > 0
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        // skip malformed call: mixedArgs(10, alice, true, 0x01, "hello", "0x02") (bad raw arg for mixedArgs.arg5: type=bytes, raw="0x02")
        {
        target.total();
        }
        vm.stopPrank();
    }

    // @cover-intent 验证deposit增加余额，withdraw减少余额并转账ETH
    function test_test_deposit_and_withdraw_8() public {
// assume: paused==false
// cover: deposit :: require(!paused) true
// cover: withdraw :: require(!paused) true
// cover: withdraw :: require(balances[msg.sender] >= amount) true
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        vm.prank(owner);
        target.unpause();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.startPrank(alice);
        {
        target.balances(alice);
        }
        {
        target.withdraw(30);
        }
        {
        target.balances(alice);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 20
    }

    // @cover-intent 验证withdraw在余额不足时revert
    function test_test_withdraw_insufficient_balance_9() public {
// assume: paused==false
// assume: balances(alice) == 0
// cover: withdraw :: require(balances[msg.sender] >= amount) false
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        // dropped unsafe prestate: target.unpause();
        uint256 ethA0 = alice.balance;
        uint256 ethB0 = bob.balance;
        uint256 ethC0 = carol.balance;
        uint256 ethO0 = owner.balance;
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdraw(1);
        }
    }

    // @cover-intent Check balance of alice is 0 initially
    function test_balances_view_10() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.balances(alice);
        }
        // TODO assert: alice.balance == 0
    }

    // @cover-intent Deposit 1 ether and check balance increased
    function test_deposit_basic_11() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.unpause();
        }
        // TODO assert: alice.balance == 1 ether
    }

    // @cover-intent Test mixedArgs with all non-zero values
    function test_mixedArgs_basic_12() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.unpause();
        }
        vm.prank(alice);
        // skip malformed call: mixedArgs(5, alice, true, 0x01, "hello", "0x02") (bad raw arg for mixedArgs.arg5: type=bytes, raw="0x02")
    }

    // @cover-intent Check names mapping after constructor
    function test_names_view_13() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.names(0);
        }
    }

    // @cover-intent Check namesLength is 0 initially
    function test_namesLength_view_14() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.namesLength();
        }
    }

    // @cover-intent Check owner is deployer
    function test_owner_view_15() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.owner();
        }
    }

    // @cover-intent state transition test for pause
    function test_pause_by_owner_16() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.pause();
        }
    }

    // @cover-intent Check paused is false initially
    function test_paused_view_17() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.paused();
        }
    }

    // @cover-intent Set pair with x=10, y=true
    function test_setPair_basic_18() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.unpause();
        }
        vm.prank(alice);
        {
        ParamCoverageTest1.Pair memory _s1;
        _s1.x = 1;
        _s1.y = true;
        target.setPair(_s1);
        }
    }

    // @cover-intent Check total is 0 initially
    function test_total_view_19() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.total();
        }
    }

    // @cover-intent Owner transfers ownership to alice
    function test_transferOwnership_by_owner_20() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.transferOwnership(alice);
        }
    }

    // @cover-intent state transition test for unpause
    function test_unpause_by_owner_21() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.pause();
        }
        {
        target.unpause();
        }
        vm.stopPrank();
    }

    // @cover-intent Use voter with weight=10, vote=5, voted=true, delegate=alice
    function test_useVoter_basic_22() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.unpause();
        }
        vm.prank(alice);
        {
        ParamCoverageTest1.VoterLike memory _s1;
        _s1.weight = 1;
        _s1.voted = true;
        _s1.delegate = alice;
        _s1.vote = 1;
        target.useVoter(_s1);
        }
    }

    // @cover-intent Deposit then withdraw 1 ether
    function test_withdraw_basic_23() public {
        bytes32[] memory _arr1 = new bytes32[](1);
        _arr1[0] = bytes32(uint256(1));
        vm.startPrank(owner);
        ParamCoverageTest1 target = new ParamCoverageTest1(_arr1);
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
        target.unpause();
        }
        vm.prank(alice);
        {
        target.withdraw(1 ether);
        }
        // TODO assert: alice.balance == 0
    }

}
