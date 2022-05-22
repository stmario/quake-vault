// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/QuakeVault.sol";
import "../lib/forge-std/src/Test.sol";
import "../src/QuakeVaultToken.sol";

contract QuakeVaultTest is Test {
    QuakeVault public quakeVault;
    address constant LINK_ADDRESS_RINKEBY = address(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
    address constant QVT_ADDRESS = address(0xdeadbeef); //TODO: change
    QuakeVaultToken public QVT;

    function setUp() public {
        deal(address(LINK_ADDRESS_RINKEBY), address(msg.sender), uint256(1e5));
        QVT = new QuakeVaultToken(1e10);
        bytes memory code = address(QVT).code;
        vm.etch(QVT_ADDRESS, code);
        quakeVault = new QuakeVault();
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
