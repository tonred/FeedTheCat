// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract TestToken is ERC20 {

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function testMint(address account, uint256 amount) public {
        _mint(account, amount);
    }

}
