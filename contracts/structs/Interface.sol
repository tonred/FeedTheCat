// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./FundingState.sol";
import "./FundingInfo.sol";
import "./File.sol";
import "./NFTInfo.sol";
import "../Funding.sol";


struct FundingsDetails {
    uint32 id;
    address addr;
    address collection;
    FundingState state;
    string title;
    uint256 target;
    uint256 balance;
    uint256 finishTime;
}

struct FundingDetailsFull {
    FundingInfo info;
    File[] files;
    NFTInfo[] nfts;
    address collection;
    uint256 startTime;
    uint256 finishTime;
    uint256 balance;
    File[] reports;
    Rating top1;
    Rating top2;
    Rating top3;
    FundingState state;
    //        mapping(address => DonatorData) _donates;
}
