// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../structs/NFTInfo.sol";
import "./Collection.sol";

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


library RewarderLibrary {

    // todo ???
    function deploy(address owner, string memory uri) public returns (Collection) {
        return new Collection(owner, uri);
    }

    function isNonCommonNFT(NFTInfo storage nft) public view returns (bool) {
        return nft.special || nft.onlyTop1 || nft.onlyTop2 || nft.onlyTop3;
    }

}
