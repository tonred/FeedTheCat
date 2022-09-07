// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


interface IRoot {

    function processDonation(uint32 fundingID, address donator, uint256 amount) external;

}
