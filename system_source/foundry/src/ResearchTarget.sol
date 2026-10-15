pragma solidity ^0.8.0;

contract ResearchTarget {

    // ===============================
    // ① 会计模型
    // ===============================

    mapping(address => uint256) public balances;
    uint256 public totalSupply;

    // 故意留一个漏洞：mint 不更新 totalSupply

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        totalSupply += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        payable(msg.sender).transfer(amount);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        balances[to] += amount;
        // ❌ 漏洞：忘记更新 totalSupply
    }

    // ===============================
    // ② 权限模型
    // ===============================

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    // ===============================
    // ③ 状态机
    // ===============================

    enum Phase { Init, Active, Closed }
    Phase public phase;

    function activate() public onlyOwner {
        require(phase == Phase.Init);
        phase = Phase.Active;
    }

    function close() public onlyOwner {
        require(phase == Phase.Active);
        phase = Phase.Closed;
    }

    // ❌ 故意允许回退
    function reset() public onlyOwner {
        phase = Phase.Init;
    }

    constructor() {
        owner = msg.sender;
        phase = Phase.Init;
    }

    receive() external payable {
        deposit();
    }
}