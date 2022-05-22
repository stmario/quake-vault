// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract QuakeVaultToken is ERC20 {
    constructor(uint256 _initialSupply) public ERC20("Quake Vault Token", "QVT") {
        _mint(msg.sender, _initialSupply);
    }
}
