// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../lib/forge-std/src/Test.sol";
import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/QuakeVault.sol";
import "../mock/ChainlinkMock.sol";

contract QuakeVaultTest is Test {
    QuakeVault public quakeVault;
    ChainlinkMock public link;

    function setUp() public {
        quakeVault = new QuakeVault();
        link = new ChainlinkMock();
        //add some Chainlink
    }

    function testExample() public {
        assertTrue(true);
    }
}
