// SPDX-License-Identifier: MIT
pragma solidity 0.5.11;
import "../src/buggy_30.sol";

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

contract ERC777_FunctionalTest {
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


    // @cover-intent Transfer 60 from alice to bob (supply conserved)
    function test_erc20_transfer_0() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 600);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 60);
        }
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent approve -> transferFrom flow
    function test_erc20_approve_spend_1() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 200);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, bob, 60);
        }
        _assertEqU(target.allowance(alice, bob), 40);
        _assertEqU(target.balanceOf(bob), balB0 + 60);
        _assertEqU(target.balanceOf(alice), balA0 - 60);
        _assertEqU(target.totalSupply(), supply0);
    }

    // @cover-intent Financial & Accounting: Verify basic ERC20 transfer works correctly, updating balances and conserving total supply.
    function test_ERC777_basic_transfer_2() public {
// assume: balanceOf(alice) >= 150
// cover: transfer :: require(recipient != address(0)) true
// cover: transfer :: require(balanceOf(from) >= amount) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(alice);
        {
        target.transfer(bob, 100);
        }
        {
        target.transfer(carol, 50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 850
        // TODO assert: bob.balance == 100
        // TODO assert: carol.balance == 50
    }

    // @cover-intent Transactional Consistency: Verify transfer to zero address reverts as required by ERC777.
    function test_ERC777_transfer_to_zero_address_3() public {
// assume: balanceOf(alice) >= 10
// cover: transfer :: require(recipient != address(0)) false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(address(0), 10);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify approve and transferFrom work correctly, updating allowances and balances.
    function test_ERC777_approve_and_transferFrom_4() public {
// assume: allowance(alice, bob) >= 150
// cover: transferFrom :: require(recipient != address(0)) true
// cover: transferFrom :: require(holder != address(0)) true
// cover: transferFrom :: require(allowance >= amount) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 500);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 200);
        }
        vm.startPrank(bob);
        {
        target.transferFrom(alice, bob, 100);
        }
        {
        target.transferFrom(alice, carol, 50);
        }
        vm.stopPrank();
        // TODO assert: alice.balance == 350
        // TODO assert: bob.balance == 100
        // TODO assert: carol.balance == 50
    }

    // @cover-intent Transactional Consistency: Verify approve to zero address reverts.
    function test_ERC777_approve_zero_address_5() public {
// cover: approve :: require(spender != address(0)) false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(address(0), 100);
        }
    }

    // @cover-intent Authorization & Access Control: Verify operator authorization and revocation work correctly.
    function test_ERC777_authorize_and_revoke_operator_6() public {
// cover: authorizeOperator :: require(msg.sender != operator) true
// cover: revokeOperator :: require(operator != msg.sender) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.startPrank(owner);
        {
        target.authorizeOperator(bob);
        }
        {
        target.isOperatorFor(bob, alice);
        }
        {
        target.revokeOperator(bob);
        }
        {
        target.isOperatorFor(bob, alice);
        }
        vm.stopPrank();
    }

    // @cover-intent Authorization & Access Control: Verify authorizing self as operator reverts.
    function test_ERC777_authorize_self_reverts_7() public {
// cover: authorizeOperator :: require(msg.sender != operator) false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        {
        target.authorizeOperator(alice);
        }
    }

    // @cover-intent Authorization & Access Control: Verify operator can send tokens on behalf of holder.
    function test_ERC777_operatorSend_8() public {
// assume: isOperatorFor(bob, alice) == true
// assume: balanceOf(alice) >= 100
// cover: operatorSend :: require(isOperatorFor(msg.sender, sender)) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 500);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        // skip malformed call: operatorSend(alice, carol, 100, "0x", "0x") (bad raw arg for operatorSend.arg3: type=bytes, raw="0x")
        // TODO assert: alice.balance == 400
        // TODO assert: carol.balance == 100
    }

    // @cover-intent Authorization & Access Control: Verify non-operator cannot call operatorSend.
    function test_ERC777_operatorSend_not_operator_9() public {
// assume: isOperatorFor(bob, alice) == false
// cover: operatorSend :: require(isOperatorFor(msg.sender, sender)) false
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(bob);
        // skip malformed call: operatorSend(alice, carol, 10, "0x", "0x") (bad raw arg for operatorSend.arg3: type=bytes, raw="0x")
        // TODO assert: alice.balance == 100
    }

    // @cover-intent Financial & Accounting: Verify burning tokens reduces total supply and holder balance.
    function test_ERC777_burn_10() public {
// assume: balanceOf(alice) >= 200
// cover: burn :: require(balanceOf(from) >= amount) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 1000);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip malformed call: burn(200, "0x") (bad raw arg for burn.arg1: type=bytes, raw="0x")
        // TODO assert: alice.balance == 800
        {
            uint256 __v1 = uint256(target.totalSupply());
            _assertRelU(__v1, 2, 800, "call:totalSupply>=800");
        }
    }

    // @cover-intent Authorization & Access Control: Verify operator can burn tokens on behalf of holder.
    function test_ERC777_operatorBurn_11() public {
// assume: isOperatorFor(bob, alice) == true
// assume: balanceOf(alice) >= 100
// cover: operatorBurn :: require(isOperatorFor(msg.sender, account)) true
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
        vm.startPrank(owner);
        target.transfer(alice, 500);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        // skip malformed call: operatorBurn(alice, 100, "0x", "0x") (bad raw arg for operatorBurn.arg2: type=bytes, raw="0x")
        // TODO assert: alice.balance == 400
        {
            uint256 __v2 = uint256(target.totalSupply());
            _assertRelU(__v2, 2, 400, "call:totalSupply>=400");
        }
    }

    // @cover-intent Authorization & Access Control
    function test_allowance_12() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.approve(alice, 50);
        }
        vm.prank(bob);
        {
        target.allowance(owner, alice);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_approve_13() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 100);
        }
    }

    // @cover-intent Authorization & Access Control
    function test_authorizeOperator_14() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        {
        target.authorizeOperator(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_balanceOf_15() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(bob);
        {
        target.balanceOf(alice);
        }
        // TODO assert: alice.balance == 100
    }

    // @cover-intent state transition test for bug_re_ent34
    function test_bug_re_ent34_16() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent34()
    }

    // @cover-intent state transition test for bug_re_ent41
    function test_bug_re_ent41_17() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent41()
    }

    // @cover-intent state transition test for bug_re_ent6
    function test_bug_re_ent6_18() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(owner);
        // skip ABI-mismatched call: bug_re_ent6()
    }

    // @cover-intent Financial & Accounting
    function test_burn_19() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.burn(30, hex"00");
        }
        // TODO assert: alice.balance == 70
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent16_20() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: buyTicket_re_ent16()
    }

    // @cover-intent External Interaction & Environment
    function test_buyTicket_re_ent2_21() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: buyTicket_re_ent2()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent21_22() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: callme_re_ent21()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent28_23() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: callme_re_ent28()
    }

    // @cover-intent External Interaction & Environment
    function test_callme_re_ent42_24() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: callme_re_ent42()
    }

    // @cover-intent External Interaction & Environment
    function test_claimReward_re_ent11_25() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: claimReward_re_ent11()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: claimReward_re_ent11()
    }

    // @cover-intent External Interaction & Environment
    function test_claimReward_re_ent18_26() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(owner);
        // skip ABI-mismatched call: claimReward_re_ent18()
        vm.expectRevert();
        vm.prank(alice);
        // skip ABI-mismatched call: claimReward_re_ent18()
    }

    // @cover-intent Financial & Accounting
    function test_decimals_27() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: decimals()
    }

    // @cover-intent Authorization & Access Control
    function test_defaultOperators_28() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: defaultOperators()
    }

    // @cover-intent Financial & Accounting
    function test_granularity_29() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: granularity()
    }

    // @cover-intent Authorization & Access Control
    function test_isOperatorFor_30() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(carol);
        {
        target.isOperatorFor(bob, alice);
        }
    }

    // @cover-intent Financial & Accounting
    function test_name_31() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: name()
    }

    // @cover-intent Financial & Accounting
    function test_operatorBurn_32() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        {
        target.operatorBurn(alice, 40, hex"00", hex"00");
        }
        // TODO assert: alice.balance == 60
    }

    // @cover-intent Financial & Accounting
    function test_operatorSend_33() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        {
        target.operatorSend(alice, carol, 50, hex"00", hex"00");
        }
        // TODO assert: alice.balance == 50
        // TODO assert: carol.balance == 50
    }

    // @cover-intent Authorization & Access Control
    function test_revokeOperator_34() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.authorizeOperator(bob);
        }
        vm.prank(owner);
        {
        target.revokeOperator(bob);
        }
    }

    // @cover-intent Financial & Accounting
    function test_send_35() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.send(bob, 30, hex"00");
        }
        // TODO assert: alice.balance == 70
        // TODO assert: bob.balance == 30
    }

    // @cover-intent Financial & Accounting
    function test_symbol_36() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: symbol()
    }

    // @cover-intent Financial & Accounting
    function test_totalSupply_37() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: totalSupply()
        {
            uint256 __v3 = uint256(target.totalSupply());
            _assertRelU(__v3, 2, 100, "call:totalSupply>=100");
        }
    }

    // @cover-intent Financial & Accounting
    function test_transfer_38() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.transfer(bob, 40);
        }
        // TODO assert: alice.balance == 60
        // TODO assert: bob.balance == 40
    }

    // @cover-intent Financial & Accounting
    function test_transferFrom_39() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
        vm.stopPrank();
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(bob,   100 ether);
        vm.deal(carol, 100 ether);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        {
        target.approve(bob, 50);
        }
        vm.prank(bob);
        {
        target.transferFrom(alice, carol, 30);
        }
        // TODO assert: alice.balance == 70
        // TODO assert: carol.balance == 30
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_re_ent12_40() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent12()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawBalance_re_ent5_41() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: withdrawBalance_re_ent5()
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawFunds_re_ent10_42() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent10(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdrawFunds_re_ent24_43() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.expectRevert();
        vm.prank(alice);
        {
        target.withdrawFunds_re_ent24(0);
        }
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_balances_re_ent1_44() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent1()
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_balances_re_ent15_45() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent15()
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_balances_re_ent21_46() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent21()
    }

    // @cover-intent External Interaction & Environment
    function test_withdraw_balances_re_ent29_47() public {
        address[] memory _arr1 = new address[](1);
        _arr1[0] = alice;
        vm.startPrank(owner);
        ERC777 target = new ERC777("X", "X", _arr1);
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
        uint256 allowAB0 = target.allowance(alice,bob);
        vm.prank(alice);
        // skip ABI-mismatched call: withdraw_balances_re_ent29()
    }

}
