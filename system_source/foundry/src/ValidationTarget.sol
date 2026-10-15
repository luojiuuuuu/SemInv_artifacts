// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address internal _owner;

    modifier onlyOwner() {
        require(_msgSender() == _owner, "not owner");
        _;
    }

    constructor() {
        _owner = _msgSender();
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "zero");
        _owner = newOwner;
    }
}

contract Pausable is Ownable {
    bool internal _paused;

    modifier whenNotPaused() {
        require(!_paused, "paused");
        _;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function _pause() internal {
        _paused = true;
    }

    function _unpause() internal {
        _paused = false;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
}

contract LedgerCore is Pausable {
    mapping(address => uint256) internal _balances;
    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address a) public view returns (uint256) {
        return _balances[a];
    }

    function _mint(address to, uint256 amount) internal {
        _balances[to] += amount;
        _totalSupply += amount;
    }

    function _burn(address from, uint256 amount) internal {
        require(_balances[from] >= amount, "insufficient");
        _balances[from] -= amount;
        _totalSupply -= amount;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(_balances[from] >= amount, "insufficient");
        _balances[from] -= amount;
        _balances[to] += amount;
    }

    // 用于验证 delete 类型写入（你后续若补 delete 提取可用）
    function _wipe(address user) internal {
        uint256 amt = _balances[user];
        _balances[user] = 0;
        _totalSupply -= amt;
    }
}

contract StageMachine is LedgerCore {
    enum Phase {
        Init,
        Active,
        Closed
    }

    Phase public phase;
    uint256 public stage;

    function _activate() internal {
        require(phase == Phase.Init, "bad phase");
        phase = Phase.Active;
    }

    function _close() internal {
        require(phase == Phase.Active, "bad phase");
        phase = Phase.Closed;
    }

    function _advanceStage() internal {
        stage += 1;
    }

    // 测试 assign(stage + 1) 场景
    function _advanceStageByAssign() internal {
        stage = stage + 1;
    }

    // 测试 unary ++ 场景
    function _advanceStageUnary() internal {
        ++stage;
    }

    // 测试 relative sub 场景
    function _rollbackStage() internal {
        require(stage > 0, "stage 0");
        stage -= 1;
    }
}

contract ValidationTarget is StageMachine {
    mapping(address => bool) internal whitelist;
    uint256 public bonusPool;

    // -------------------------
    // accounting: external -> internal
    // -------------------------
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }

    function transfer(address to, uint256 amount) public whenNotPaused {
        _transfer(_msgSender(), to, amount);
    }

    // -------------------------
    // state transitions
    // -------------------------
    function activate() public onlyOwner {
        _activate();
    }

    function close() public onlyOwner {
        _close();
    }

    function nextStage() public {
        _advanceStage();
    }

    function nextStageByAssign() public {
        _advanceStageByAssign();
    }

    function nextStageUnary() public {
        _advanceStageUnary();
    }

    function rollbackStage() public onlyOwner {
        _rollbackStage();
    }

    // -------------------------
    // bool state via internal helper
    // -------------------------
    function emergencyPause() public onlyOwner {
        _pause();
    }

    function resume() public onlyOwner {
        _unpause();
    }

    // -------------------------
    // access-sensitive config writes
    // -------------------------
    function addWhitelist(address user) public onlyOwner {
        whitelist[user] = true;
    }

    function removeWhitelist(address user) public onlyOwner {
        whitelist[user] = false;
    }

    // -------------------------
    // deliberately sensitive but unguarded
    // 你当前 access_anomaly 应该能抓到它
    // -------------------------
    function forceNextStage() public {
        stage += 1;
    }

    // -------------------------
    // more accounting / IR-like patterns
    // -------------------------
    function mintBonus(address to, uint256 amount) public onlyOwner {
        _balances[to] = _balances[to] + amount;
        _totalSupply = _totalSupply + amount;
    }

    function burnBonus(address from, uint256 amount) public onlyOwner {
        require(_balances[from] >= amount, "insufficient");
        _balances[from] = _balances[from] - amount;
        _totalSupply = _totalSupply - amount;
    }

    // transfer-like redistribution，不应被 accounting anomaly 误报
    function redistribute(address from, address to, uint256 amount) public onlyOwner {
        _transfer(from, to, amount);
    }

    // -------------------------
    // state assign with ternary-ish explicit absolute assignment
    // -------------------------
    function resetToInitForTest() public onlyOwner {
        phase = Phase.Init;
    }

    // -------------------------
    // extra scalar updates
    // -------------------------
    function increaseBonusPool(uint256 amount) public onlyOwner {
        bonusPool += amount;
    }

    function decreaseBonusPool(uint256 amount) public onlyOwner {
        require(bonusPool >= amount, "insufficient");
        bonusPool -= amount;
    }

    function rewriteBonusPool(uint256 x) public onlyOwner {
        bonusPool = x;
    }

    // -------------------------
    // wipe path
    // -------------------------
    function wipeAccount(address user) public onlyOwner {
        _wipe(user);
    }
}