// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


struct NFTInfo {
    uint256 minAmount;
    uint32 minCount;
    bool onlyTop1;  // only for certain fundings
    bool onlyTop2;  // only for certain fundings
    bool onlyTop3;  // only for certain fundings
    bool special;  // only for global achievements
}
