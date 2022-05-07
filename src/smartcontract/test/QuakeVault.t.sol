// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../lib/forge-std/src/Test.sol";
import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "../src/QuakeVault.sol";
import "../mock/ChainlinkMock.sol";

contract QuakeVaultTest is Test {
    QuakeVault public quakeVault;
    LinkMock public link;

    function setUp() public {
        quakeVault = new QuakeVault();
        link = new LinkMock();
        //add some Chainlink
    }


    function testComposeProbabilityQuery5Mw() public {
        string memory expected = "https://earthquake.usgs.gov/nshmp-haz-ws/probability?edition=E2014&region=CEUS&latitude=36.000&longitude=-89.000&distance=100&timespan=1";
        string memory actual = quakeVault.composeProbabilityQuery5Mw("&region=CEUS", 36 * 1e3, -89 * 1e3, 1);
        if (compareStrings(expected, actual)){
            assertTrue(true);
        }
        else{
            emit log_string(actual);
            emit log_string(string(abi.encodePacked(int32(-10))));
            fail();
        }
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
