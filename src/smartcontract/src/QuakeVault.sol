// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ChainlinkClient} from "../chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import {Chainlink} from "../chainlink/contracts/src/v0.8/Chainlink.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import {DataUtil} from "../util/DataUtil.sol";
import {Strings} from "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

error TransferFailed();
error NeedsMoreThanZero();
error LocationNotSupported();

contract QuakeVault is ChainlinkClient, Ownable, ReentrancyGuard{
    using Chainlink for Chainlink.Request;
    event Received(address, address, uint);

    uint32 constant coordinateScalingFactor = 1e3;
    uint8 constant coordinateScalingFactorLog10 = 3;
    //// regions
    // Alaska
    /**
    uint8 constant akId = 0;
    int32 constant akMinlatitude = 48 * 1e3; // in degrees * 1000
    int32 constant akMaxlatitude = 72 * 1e3;
    int32 constant akMinlongitude = -200 * 1e3;
    int32 constant akMaxlongitude = -125 * 1e3;*/
    // Conterminous US
    /*
    uint8 constant cousId = 1;
    int32 constant cousMinlatitude = 24.6 * 1e3;
    int32 constant cousMaxlatitude = 50 * 1e3;
    int32 constant cousMinlongitude = -125 * 1e3;
    int32 constant cousMaxlongitude = -65 * 1e3;
    */
    // Central & Eastern US
    uint8 constant ceusId = 2;
    int32 constant ceusMinlatitude = 24.6 * 1e3;
    int32 constant ceusMaxlatitude = 50 * 1e3;
    int32 constant ceusMinlongitude = -115 * 1e3;
    int32 constant ceusMaxlongitude = -65 * 1e3;
    string constant ceusQueryString = "&region=CEUS";
    // Hawaii
    /*
    uint8 constant hiId = 3;
    int32 constant hiMinlatitude = 18 * 1e3;
    int32 constant hiMaxlatitude = 23 * 1e3;
    int32 constant hiMinlongitude = -161 * 1e3;
    int32 constant hiMaxlongitude = -154 * 1e3;*/
    // Western US
    uint8 constant wusId = 4;
    int32 constant wusMinlatitude = 24.6 * 1e3;
    int32 constant wusMaxlatitude = 50 * 1e3;
    int32 constant wusMinlongitude = -125 * 1e3;
    int32 constant wusMaxlongitude = -100 * 1e3;
    string constant wusQueryString = "&region=WUS";

    //API probability
    string constant usgsAPIProbability = "https://earthquake.usgs.gov/nshmp-haz-ws/probability?edition=E2014";
    string constant distance5Mw = "&distance=100";
    string constant distance6Mw = "&distance=200";
    string constant distance7Mw = "&distance=400";

    string constant lonEmptyQueryString = "&longitude=";
    string constant latEmptyQueryString = "&latitude=";
    string constant timespanEmptyQueryString = "&timespan=";

    //API events
    //TODO:
    string constant usgsAPIevent = "https://earthquake.usgs.gov/fdsnws/event/1/count?format=geojson&eventtype=earthquake&minmmi=7";
    string constant startQueryStringEmpty = "&starttime=";
    string constant endQueryStringEmpty = "&endtime=";
    string constant minMag5 = "&minmag=5&minradiuskm=100";
    string constant minMag6 = "&minmag=6&minradiuskm=200";
    string constant minMag7 = "&minmag=7&minradiuskm=400";

    //ChainLink GET request and multiply for Uint256 oracle
    address constant oracle = 0x240BaE5A27233Fd3aC5440B5a598467725F7D1cd;
    bytes32 constant jobId = "1bc4f827ff5942eaaa7540b7dd1e20b9";
    uint256 constant fee = 0.1 * 1e18;


    uint8 private ownerCut = 0.01 * 1e2; // in percents

    //Tokens used as settlement (stablecoins)
    address constant daiAddress = 0x6B175474E89094C44Da98b954EedeAC495271d0F; //FTM: 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;

    IERC20[] private acceptedTokens = new IERC20[](1);

    mapping (address => uint256) private riskPoolMediumUSA;

    constructor() Ownable(){
        //setPublicChainlinkToken(); TODO
        addAcceptedToken(daiAddress);
    }

    function setOwnerCut(uint8 _cut) public onlyOwner{
        ownerCut = _cut;
    }

    function addAcceptedToken(address _tokenAddress) public onlyOwner{
        acceptedTokens.push(IERC20(_tokenAddress));
    }

    function buyInsurance(uint256 _amount, uint8 _years, int32 _lat,int32 _lon)
        external
        nonReentrant
        moreThanZero(_amount)
        supportedLocation(_lat, _lon)
        //TODO: sufficientLink(msg.sender, nqueries)
    {
        //check location
        string memory regionQueryString;
        if (_lat < ceusMinlongitude){
            //check API for western US
            regionQueryString = wusQueryString;
        }
        else {
            //check API for central and eastern US
            regionQueryString = ceusQueryString;
        }
        //depending on probabilities, buy insurance for riskPoolLow or riskPoolMedium
        //Chainlink.Request memory requestDistance5Mw = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        string memory queryDistance5Mw = composeProbabilityQuery5Mw(regionQueryString, _lat, _lon, _years);
        //string constant queryDistance6Mw =
        //string constant queryDistance7Mw =
        //request.add("get", )
    }

    //function claimInsurance(){
        //TODO
        //only if strong enough EQ has happened in the radii during insured time and 2 weeks wait time have passed
    //}

    //function withdrawInsurance(){
        //TODO
        //anytime, user guarded
    //}

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }

    modifier supportedLocation(int32 _lat, int32 _lon){
        if (!validLocation(_lat, _lon)){
            revert LocationNotSupported();
        }
        _;
    }

    function composeProbabilityQuery5Mw(string memory _regionQueryString, int32 _lat, int32 _lon, uint8 _timespan) public pure returns(string memory){
        return string(abi.encodePacked(usgsAPIProbability, _regionQueryString, latEmptyQueryString, DataUtil.intToStringDecimal(_lat, coordinateScalingFactorLog10),
            lonEmptyQueryString, DataUtil.intToStringDecimal(_lon, coordinateScalingFactorLog10),
            distance5Mw,
            timespanEmptyQueryString, Strings.toString(_timespan)));
    }

    function validLocation(int32 _lat, int32 _lon) public pure returns(bool){
        return inBox(_lat, _lon, ceusMinlatitude, ceusMinlongitude, ceusMaxlatitude, ceusMaxlongitude)
            || inBox(_lat, _lon, wusMinlatitude, wusMinlongitude, wusMaxlatitude, wusMaxlongitude);
    }

    function inRange(int32 _x, int32 _min, int32 _max) public pure returns(bool){
        return _min <= _x && _x <= _max;
    }

    function inBox(int32 _xLat, int32 _xLon, int32 _minLat, int32 _minLon, int32 _maxLat, int32 _maxLon) public pure returns(bool){
        return inRange(_xLat, _minLat, _maxLat) && inRange(_xLon, _minLon, _maxLon);
    }

    /**
    receive() external payable{
        emit Received(msg.sender, 0x0, msg.value);
    }*/

}
