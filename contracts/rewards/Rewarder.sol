// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../structs/DonatorData.sol";
import "./RewarderLibrary.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


contract Rewarder {

    mapping(address => DonatorData) public _donates;
    Collection public _collection;
    NFTInfo[] public _nfts;

    constructor(string memory uri) {
        _collection = RewarderLibrary.deploy(msg.sender, uri);
    }

    function _mintCommonNFTs(address donator, DonatorData memory prevData) internal {
        DonatorData storage data = _donates[donator];
        for (uint id = 0; id < _nfts.length; id++) {
            NFTInfo storage nft = _nfts[id];
            if (RewarderLibrary.isNonCommonNFT(nft)) {
                continue;
            }
            uint256 minAmount = nft.minAmount;
            uint32 minCount = nft.minCount;
            if (data.amount >= minAmount && data.count >= minCount &&
                (prevData.amount < minAmount || prevData.count < minCount)
            ) {
                _mintNFT(donator, id);
            }
        }
    }

    function _mintNFT(address donator, uint256 id) internal {
        _collection.mint(donator, id);
    }

}
