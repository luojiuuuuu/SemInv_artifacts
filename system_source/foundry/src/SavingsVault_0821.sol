// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

error NotOwner();
error ZeroAmount();
error Insufficient();

contract SavingsVault_0821 {
    address public immutable owner;
    mapping(address => uint256) public balanceOf;

    event Deposit(address indexed from, uint256 amount);
    event Withdraw(address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        if (msg.value == 0) revert ZeroAmount();
        balanceOf[msg.sender] += msg.value; // 0.8 默认有溢出检查
        emit Deposit(msg.sender, msg.value);
    }

    function ownerSweep(address payable to, uint256 amount) external {
        if (msg.sender != owner) revert NotOwner();
        if (amount == 0) revert ZeroAmount();
        if (address(this).balance < amount) revert Insufficient();
        to.transfer(amount);
    }

    function batchCredit(address[] calldata users, uint256[] calldata amounts) external {
        if (msg.sender != owner) revert NotOwner();
        require(users.length == amounts.length, "len");
        // 演示 unchecked（在明确安全的场景下可省 gas）
        for (uint256 i = 0; i < users.length; ) {
            balanceOf[users[i]] += amounts[i];
            unchecked { i++; }
        }
    }

    function withdraw(uint256 amount) external {
        if (amount == 0) revert ZeroAmount();
        uint256 bal = balanceOf[msg.sender];
        if (bal < amount) revert Insufficient();
        balanceOf[msg.sender] = bal - amount; // 有检查
        payable(msg.sender).transfer(amount);
        emit Withdraw(msg.sender, amount);
    }
}
