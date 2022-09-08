// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract Collection is ERC1155 {

    address public _owner;

    modifier onlyOwner() {
        require(msg.sender == _owner, "Sender is not owner");
        _;
    }

    constructor(address owner, string memory uri) ERC1155(uri) {
        _owner = owner;
    }

    function mint(address to, uint256 id) public onlyOwner {
        _mint(to, id, 1, "");
    }

}
