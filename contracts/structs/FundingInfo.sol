// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


struct FundingInfo {
    string title;
    string description;
    uint256 target;
    address spender;
    uint32 duration;
}
