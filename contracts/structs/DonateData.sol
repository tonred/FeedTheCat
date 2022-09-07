// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


struct DonateData {
    uint256 amount;
    uint32 count;
    mapping(uint32 => bool) isParticipate;
}
