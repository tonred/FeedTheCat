// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../interfaces/IRoot.sol";


contract TestDao {

    function testAccept(address root, uint32 fundingID) public {
        IRoot(root).acceptFunding(fundingID);
    }

}
