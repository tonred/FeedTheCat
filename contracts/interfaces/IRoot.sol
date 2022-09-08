// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../structs/File.sol";
import "../structs/FundingInfo.sol";
import "../structs/NFTInfo.sol";


interface IRoot {
    function createFunding(FundingInfo calldata info, File[] calldata files, NFTInfo[] calldata nfts) external;
    function acceptFunding(uint32 fundingID) external;
    function processDonation(uint32 fundingID, address donator, uint256 amount) external;
    function emergencyFinish(uint32 fundingID) external;
}
