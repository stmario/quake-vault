// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ChainlinkClient} from "../chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {Chainlink} from "../chainlink/contracts/src/v0.8/Chainlink.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";

error TransferFailed();
error NeedsMoreThanZero();

contract QuakeVault is ChainlinkClient, Ownable, ReentrancyGuard{
    using Chainlink for Chainlink.Request;
    event Received(address, address, uint);

    //// regions
    // Alaska
    uint8 constant akId = 0;
    int32 constant akMinlatitude = 48 * 1000; // in degrees * 1000
    int32 constant akMaxlatitude = 72 * 1000;
    int32 constant akMinlongitude = -200 * 1000;
    int32 constant akMaxlongitude = -125 * 1000;
    // Conterminous US
    uint8 constant cousId = 1;
    int32 constant cousMinlatitude = 24.6 * 1000;
    int32 constant cousMaxlatitude = 50 * 1000;
    int32 constant cousMinlongitude = -125 * 1000;
    int32 constant cousMaxlongitude = -65 * 1000;
    // Central & Eastern US
    uint8 constant ceusId = 2;
    int32 constant ceusMinlatitude = 24.6 * 1000;
    int32 constant ceusMaxlatitude = 50 * 1000;
    int32 constant ceusMinlongitude = -115 * 1000;
    int32 constant ceusMaxlongitude = -65 * 1000;
    // Hawaii
    uint8 constant hiId = 3;
    int32 constant hiMinlatitude = 18 * 1000;
    int32 constant hiMaxlatitude = 23 * 1000;
    int32 constant hiMinlongitude = -161 * 1000;
    int32 constant hiMaxlongitude = -154 * 1000;
    // Western US
    uint8 constant wusId = 4;
    int32 constant wusMinlatitude = 24.6 * 1000;
    int32 constant wusMaxlatitude = 50 * 1000;
    int32 constant wusMinlongitude = -125 * 1000;
    int32 constant wusMaxlongitude = -100 * 1000;

    address constant daiAddress = 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;

    uint8 private ownerCut = 0.01 * 100; // in percents

    address[] private acceptedTokens = new address[](1);

    mapping (address => uint256) private riskPoolMediumUSA;

    constructor() Ownable(){
        addAcceptedToken(daiAddress);
    }

    function setOwnerCut(uint8 _cut) public onlyOwner{
        ownerCut = _cut;
    }

    function addAcceptedToken(address _tokenAddress) public onlyOwner{
        acceptedTokens.push(_tokenAddress);
    }

    function buyInsuranceMediumUSA(uint256 _amount,int32 _lat,int32 _lon)
        external
        nonReentrant
        moreThanZero(_amount){
        //TODO:
    }


    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    modifier validLocation(int32 lat, int32 _lon){
        //TODO
        _;
    }

    /**
    receive() external payable{
        emit Received(msg.sender, 0x0, msg.value);
    }*/

}
