// todo Funding.sol and Root.sol will inherit from Rewarder in order to mint NFT

//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.9;
//
//import "../structs/DonatorData.sol";
//import "../structs/NFTInfo.sol";
//import "../Achievements.sol";
//
//import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
//
//
//contract Rewarder {
//
//    address public _achievements;
//
//    constructor(address achievements) {
//        _achievements = achievements;
//    }
//
//    function _distributeRewards(
//        address donator,
//        DonatorData storage data,
//        NFTInfo[] storage nfts,
//        uint256 prevAmount,
//        uint32 prevCount
//    ) internal {
//        _mintCommonRewardNFTs(donator, data, nfts, prevAmount, prevCount);
//        _mintSpecialRewardNFTs(donator, nfts);
//    }
//
//    function _mintCommonRewardNFTs(
//        address donator,
//        DonatorData storage data,
//        NFTInfo[] storage nfts,
//        uint256 prevAmount,
//        uint32 prevCount
//    ) private {
//        uint256 amount = data.amount;
//        uint32 count = data.count;
//        uint256[] storage ids;
//        for (uint i = 0; i < nfts.length; i++) {
//            if (nfts[i].special) {
//                continue;
//            }
//            uint256 minAmount = nfts[i].minAmount;
//            uint32 minCount = nfts[i].minCount;
//            if (data.amount >= minAmount && data.count >= minCount &&
//                (prevAmount < minAmount || prevCount < minCount)
//            ) {
//                ids.push(i);
//            }
//        }
//        if (ids.length > 0) {
//            _mintNFTs(donator, ids);
//        }
//    }
//
//    function _mintSpecialRewardNFTs(address donator, NFTInfo[] storage nfts) internal virtual {}
//
//    function _mintNFTs(address donator, uint256[] memory ids) private {
//        Achievements(_achievements).mintBatchSingle(donator, ids);
//    }
//
//}
