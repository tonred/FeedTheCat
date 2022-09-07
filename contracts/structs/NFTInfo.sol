// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


struct NFTInfo {
    uint256 minAmount;
    uint32 minCount;
    uint32 forPlace;  // only for certain fundings, set 0 to ignore
    bool special;  // only for global achievements
}
