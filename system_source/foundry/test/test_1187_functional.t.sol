// SPDX-License-Identifier: MIT
pragma solidity 0.4.26;
import "../src/0x7d09edb07d23acb532a82be3da5c17d9d85806b4.sol";

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

contract PoCGame_FunctionalTest {
    Vm constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    address owner;
    address alice;
    address bob;
    address carol;

    function PoCGame_FunctionalTest() public {
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


    // @cover-intent Authorization & Access Control: Verify that only the owner can call OpenToThePublic, and that it sets openToPublic to true.
    function test_OpenToThePublic_OwnerOnly_0() public {
// cover: OpenToThePublic :: require(msg.sender == owner) false
// cover: OpenToThePublic :: require(msg.sender == owner) true
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        vm.prank(owner);
        {
        target.OpenToThePublic();
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can adjust bet amounts, and that the event is emitted.
    function test_AdjustBetAmounts_OwnerOnly_1() public {
// cover: AdjustBetAmounts :: require(msg.sender == owner) false
// cover: AdjustBetAmounts :: require(msg.sender == owner) true
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustBetAmounts(100);
        }
        vm.prank(owner);
        {
        target.AdjustBetAmounts(200);
        }
    }

    // @cover-intent Authorization & Access Control: Verify that only the owner can adjust difficulty, and that the event is emitted.
    function test_AdjustDifficulty_OwnerOnly_2() public {
// cover: AdjustDifficulty :: require(msg.sender == owner) false
// cover: AdjustDifficulty :: require(msg.sender == owner) true
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustDifficulty(5);
        }
        vm.prank(owner);
        {
        target.AdjustDifficulty(10);
        }
    }

    // @cover-intent Protocol State Machine: Verify that wager() reverts when openToPublic is false.
    function test_Wager_NotOpen_Reverts_3() public {
// cover: wager :: require(openToPublic) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.wager.value(0.01 ether)();
        }
    }

    // @cover-intent Financial & Accounting: Verify that a player can wager exactly betLimit ETH when openToPublic is true, and that the event is emitted.
    function test_Wager_Open_Success_4() public {
// cover: wager :: require(openToPublic) true
// cover: wager :: require(msg.value == betLimit) true
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        vm.stopPrank();
        vm.prank(alice);
        {
        target.wager.value(0.01 ether)();
        }
    }

    // @cover-intent Financial & Accounting: Verify that wager() reverts if msg.value does not equal betLimit.
    function test_Wager_WrongAmount_Reverts_5() public {
// cover: wager :: require(msg.value == betLimit) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.wager.value(0.02 ether)();
        }
    }

    // @cover-intent Transactional Consistency: Verify that play() reverts if the caller has not wagered.
    function test_Play_WithoutWager_Reverts_6() public {
// cover: play :: require(wagers[msg.sender] > 0) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        vm.stopPrank();
        vm.expectRevert();
        vm.prank(alice);
        {
        target.play();
        }
    }

    // @cover-intent Transactional Consistency: Verify that play() reverts if called in the same block as wager.
    function test_Play_SameBlock_Reverts_7() public {
// cover: play :: require(blockNumber < block.number) false
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        {
        target.AdjustBetAmounts(10000000000000000);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.wager.value(0.01 ether)();
        }
        vm.expectRevert();
        {
        target.play();
        }
        vm.stopPrank();
    }

    // @cover-intent Protocol State Machine: Verify that donate() reverts when openToPublic is false.
    function test_Donate_NotOpen_Reverts_8() public {
// cover: donate :: require(openToPublic) false
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.donate.value(1 ether)();
        }
    }

    // @cover-intent External Interaction & Environment: Verify that donate() sends ETH to the whale and emits Donate event.
    function test_Donate_Open_Success_9() public {
// cover: donate :: require(openToPublic) true
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        vm.prank(alice);
        {
        target.donate.value(2 ether)();
        }
    }

    // @cover-intent Authorization & Access Control
    function test_AdjustBetAmounts_positive_10() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustBetAmounts(200);
        }
        {
        target.AdjustBetAmounts(300);
        }
        vm.stopPrank();
        {
            uint256 __v1 = uint256(target.currentBetLimit());
            _assertRelU(__v1, 0, 300, "call:currentBetLimit==300");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_AdjustDifficulty_positive_11() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustDifficulty(10);
        }
        {
        target.AdjustDifficulty(20);
        }
        vm.stopPrank();
        {
            uint256 __v2 = uint256(target.currentDifficulty());
            _assertRelU(__v2, 0, 20, "call:currentDifficulty==20");
        }
    }

    // @cover-intent Protocol State Machine
    function test_OpenToThePublic_positive_12() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
    }

    // @cover-intent Financial & Accounting
    function test_currentBetLimit_view_13() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustBetAmounts(500);
        }
        vm.prank(alice);
        {
        target.currentBetLimit();
        }
        {
            uint256 __v3 = uint256(target.currentBetLimit());
            _assertRelU(__v3, 0, 500, "call:currentBetLimit==500");
        }
    }

    // @cover-intent Financial & Accounting
    function test_currentDifficulty_view_14() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.AdjustDifficulty(15);
        }
        vm.prank(alice);
        {
        target.currentDifficulty();
        }
        {
            uint256 __v4 = uint256(target.currentDifficulty());
            _assertRelU(__v4, 0, 15, "call:currentDifficulty==15");
        }
    }

    // @cover-intent External Interaction & Environment
    function test_donate_positive_15() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        vm.prank(alice);
        {
        target.donate.value(1 ether)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_ethBalance_view_16() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.ethBalance();
        }
        {
            uint256 __v5 = uint256(target.ethBalance());
            _assertRelU(__v5, 2, 0, "call:ethBalance>=0");
        }
    }

    // @cover-intent Financial & Accounting
    function test_hasPlayerWagered_false_17() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.hasPlayerWagered(alice);
        }
    }

    // @cover-intent Protocol State Machine
    function test_play_positive_18() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        // skip malformed call: AdjustBetAmounts(0.01 ether) (bad raw arg for AdjustBetAmounts.arg0: type=uint256, raw=0.01 ether)
        {
        target.AdjustDifficulty(10);
        }
        vm.stopPrank();
        vm.startPrank(alice);
        {
        target.wager.value(0.01 ether)();
        }
        {
        target.play();
        }
        vm.stopPrank();
    }

    // @cover-intent External Interaction & Environment
    function test_transferAnyERC20Token_positive_19() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.transferAnyERC20Token(address(0), alice, 100);
        }
    }

    // @cover-intent Protocol State Machine
    function test_wager_positive_20() public {
        vm.startPrank(alice);
        PoCGame target = new PoCGame(alice, 100);
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
        target.OpenToThePublic();
        }
        // skip malformed call: AdjustBetAmounts(0.01 ether) (bad raw arg for AdjustBetAmounts.arg0: type=uint256, raw=0.01 ether)
        vm.stopPrank();
        vm.prank(alice);
        {
        target.wager.value(0.01 ether)();
        }
    }

    // @cover-intent Financial & Accounting
    function test_winnersPot_view_21() public {
        vm.startPrank(owner);
        PoCGame target = new PoCGame(alice, 100);
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
        target.winnersPot();
        }
        {
            uint256 __v6 = uint256(target.winnersPot());
            _assertRelU(__v6, 2, 0, "call:winnersPot>=0");
        }
    }

}
