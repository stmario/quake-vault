// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/QuakeVault.sol";
import "../lib/forge-std/src/Test.sol";
import "../src/QuakeVaultToken.sol";

contract QuakeVaultTest is Test {
    QuakeVault public quakeVault;
    address constant DAI_ADDRESS_RINKEBY = address(0x95b58a6Bff3D14B7DB2f5cb5F0Ad413DC2940658);
    address constant LINK_ADDRESS_RINKEBY = address(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
    address constant QVT_ADDRESS = address(0xdeadbeef); //TODO: change
    QuakeVaultToken public QVT;
    address constant ALICE = address(0xbadbeef);
    address constant OWNER_ADDR = address(0xdad);

    function setUp() public {
        vm.deal(ALICE, 1 << 128);
        vm.deal(OWNER_ADDR, 1 << 128);
        deal(address(LINK_ADDRESS_RINKEBY), ALICE, uint256(1e18 * 1e5));
        vm.startPrank(OWNER_ADDR);
        QVT = new QuakeVaultToken(1e10);
        bytes memory code = address(QVT).code;
        vm.etch(QVT_ADDRESS, code);
        vm.stopPrank();
        deal(DAI_ADDRESS_RINKEBY, ALICE, 1e18 * 1e5);
        deal(QVT_ADDRESS, ALICE, 1e18 * 1e5);
        vm.prank(OWNER_ADDR);
        quakeVault = new QuakeVault();
        vm.startPrank(ALICE);
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

    function testBuyInsuranceHappy() public {
        //TODO: mock oracle
        quakeVault.buyInsurance(QuakeVault.BuyInsurance(100, 5, 36 * 1e3, -89 * 1e3));
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
