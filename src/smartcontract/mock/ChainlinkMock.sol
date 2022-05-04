pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract LinkMock is ERC20 {
    constructor() ERC20("Link Mock", "MLINK"){
        _mint(msg.sender, 1000000e18);
    }
}
