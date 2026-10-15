// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

contract ParamCoverageTest1 {
    struct Pair {
        uint256 x;
        bool y;
    }

    struct VoterLike {
        uint256 weight;
        bool voted;
        address delegate;
        uint256 vote;
    }

    address public owner;
    uint256 public total;
    bool public paused;

    bytes32[] public names;
    mapping(address => uint256) public balances;

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    constructor(bytes32[] memory initNames) {
        owner = msg.sender;
        for (uint256 i = 0; i < initNames.length; i++) {
            names.push(initNames[i]);
        }
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "zero owner");
        owner = newOwner;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }

    function setNumbers(uint256[] memory nums) external {
        require(!paused, "paused");
        total = nums.length;
    }

    function setAddresses(address[] memory users) external {
        require(!paused, "paused");
        total = users.length;
    }

    function setNames(bytes32[] memory newNames) external onlyOwner {
        delete names;
        for (uint256 i = 0; i < newNames.length; i++) {
            names.push(newNames[i]);
        }
        total = newNames.length;
    }

    function setPair(Pair memory p) external {
        require(!paused, "paused");
        total = p.x;
        if (p.y) {
            total += 1;
        }
    }

    function setPairs(Pair[] memory ps) external {
        require(!paused, "paused");
        total = ps.length;
        for (uint256 i = 0; i < ps.length; i++) {
            total += ps[i].x;
        }
    }

    function useVoter(VoterLike memory v) external {
        require(!paused, "paused");
        total = v.weight + v.vote;
        if (v.voted) {
            balances[v.delegate] += 1;
        }
    }

    function mixedArgs(
        uint256 a,
        address b,
        bool c,
        bytes32 d,
        string memory e,
        bytes memory f
    ) external {
        require(!paused, "paused");
        total = a;
        if (c) {
            total += 1;
        }
        if (b != address(0)) {
            total += 1;
        }
        if (d != bytes32(0)) {
            total += 1;
        }
        if (bytes(e).length > 0) {
            total += 1;
        }
        if (f.length > 0) {
            total += 1;
        }
    }

    function arrayAndStruct(
        uint256[] memory nums,
        Pair memory p
    ) external {
        require(!paused, "paused");
        total = nums.length + p.x;
        if (p.y) {
            total += 1;
        }
    }

    function arrayOfStructsAndScalar(
        Pair[] memory ps,
        uint256 z
    ) external {
        require(!paused, "paused");
        total = z;
        for (uint256 i = 0; i < ps.length; i++) {
            total += ps[i].x;
        }
    }

    function deposit() external payable {
        require(!paused, "paused");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(!paused, "paused");
        require(balances[msg.sender] >= amount, "insufficient");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function namesLength() external view returns (uint256) {
        return names.length;
    }
}