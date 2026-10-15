// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
    ======================================
    Base Context (类似 OpenZeppelin)
    ======================================
*/

contract Context {

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

}

/*
    ======================================
    Ownable
    ======================================
*/

contract Ownable is Context {

    address internal _owner;

    modifier onlyOwner() {
        require(_msgSender() == _owner, "not owner");
        _;
    }

    constructor() {
        _owner = _msgSender();
    }

    function owner() public view returns(address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
}

/*
    ======================================
    Pausable
    ======================================
*/

contract Pausable is Context {

    bool internal _paused;

    modifier whenNotPaused() {
        require(!_paused, "paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "not paused");
        _;
    }

    function paused() public view returns(bool) {
        return _paused;
    }

    function _pause() internal {
        _paused = true;
    }

    function _unpause() internal {
        _paused = false;
    }
}

/*
    ======================================
    Simple ERC20-like accounting
    ======================================
*/

contract SimpleERC20 is Context {

    mapping(address => uint256) internal _balances;

    uint256 internal _totalSupply;

    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }

    function balanceOf(address user) public view returns(uint256) {
        return _balances[user];
    }

    function _mint(address to, uint256 amount) internal {

        _balances[to] += amount;
        _totalSupply += amount;

    }

    function _burn(address from, uint256 amount) internal {

        require(_balances[from] >= amount);

        _balances[from] -= amount;
        _totalSupply -= amount;

    }

    function _transfer(address from, address to, uint256 amount) internal {

        require(_balances[from] >= amount);

        _balances[from] -= amount;
        _balances[to] += amount;

    }
}

/*
    ======================================
    State machine contract
    ======================================
*/

contract StateMachine {

    enum Phase {
        Init,
        Active,
        Closed
    }

    Phase public phase;

    uint256 public stage;

    constructor() {
        phase = Phase.Init;
        stage = 0;
    }

    function _activate() internal {

        require(phase == Phase.Init);

        phase = Phase.Active;

    }

    function _close() internal {

        require(phase == Phase.Active);

        phase = Phase.Closed;

    }

    function _advanceStage() internal {

        stage += 1;

    }
}

/*
    ======================================
    Final Test Contract
    ======================================
*/

contract TestSystem is
    Ownable,
    Pausable,
    SimpleERC20,
    StateMachine
{

    /*
        ======================================
        Wrapper functions
        用于验证 internal summary propagation
        ======================================
    */

    function mint(address to, uint256 amount)
        public
        onlyOwner
    {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount)
        public
        onlyOwner
    {
        _burn(from, amount);
    }

    function transfer(address to, uint256 amount)
        public
        whenNotPaused
    {
        _transfer(msg.sender, to, amount);
    }

    /*
        ======================================
        Pause control
        ======================================
    */

    function pause() public onlyOwner {

        _pause();

    }

    function unpause() public onlyOwner {

        _unpause();

    }

    /*
        ======================================
        State transitions
        ======================================
    */

    function activate() public onlyOwner {

        _activate();

    }

    function close() public onlyOwner {

        _close();

    }

    /*
        ======================================
        Monotonic stage update
        ======================================
    */

    function nextStage() public {

        _advanceStage();

    }

}