// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract Achievements is ERC1155 {

    address public _owner;

    constructor(address owner, string memory uri) ERC1155(uri) {
        _owner = owner;
    }

    function mintBatchSingle(address to, uint256[] memory ids) public {
        require(msg.sender == _owner, "Sender is not owner");
        uint256[] memory amounts = new uint256[](ids.length);
        for (uint i = 0; i < ids.length; i++) {
            amounts[i] = 1;
        }
        _mintBatch(to, ids, amounts, "");
    }

}
