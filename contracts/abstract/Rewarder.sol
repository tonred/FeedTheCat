// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../structs/DonatorData.sol";
import "../structs/NFTInfo.sol";
import "../Achievements.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


contract Rewarder {

    address public _achievements;

    constructor() {
        _achievements = address(0);  // todo deploy ERC1155
    }

    // todo global data, donators, nfts
    function _mintCommonAchievements(
        address donator,
        DonatorData storage data,
        NFTInfo[] storage nfts,
        DonatorData memory prevData
    ) internal {
        for (uint id = 0; id < nfts.length; id++) {
            NFTInfo storage nft = nfts[id];
            if (nft.special || nft.onlyTop1 || nft.onlyTop2 || nft.onlyTop3) {
                continue;
            }
            uint256 minAmount = nft.minAmount;
            uint32 minCount = nft.minCount;
            if (data.amount >= minAmount && data.count >= minCount &&
                (prevData.amount < minAmount || prevData.count < minCount)
            ) {
                _mintAchievement(donator, id);
            }
        }
    }

    function _mintAchievement(address donator, uint256 id) internal {
        Achievements(_achievements).mint(donator, id);
    }

}
