// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "../lib/chainlink/contracts/src/v0.8/Chainlink.sol";
import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";

import "../lib/openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "../util/DataUtil.sol";
import "../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

error TransferFailed();
error NeedsMoreThanZero();
error LocationNotSupported();
error InsufficientStableCoin();
error InsufficientLink();
error InsufficientSpace();
error InvalidYears();
error InsufficientStaked();

contract QuakeVault is ChainlinkClient, Ownable, ReentrancyGuard{
    using Chainlink for Chainlink.Request;
    event Received(address, address, uint);

    //TODO make private, CAPITALIZE
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

    string constant private PATH_5Mw = "data.[0].yvalues.[8]"; //always exists
    string constant private PATH_6Mw = "data.[0].yvalues.[18]"; //path may not exist
    string constant private PATH_7Mw = "data.[0].yvalues.[28]"; //path may not exist

    string constant private PROB_SCALE = "100";

    //API events
    string constant usgsAPIevent = "https://earthquake.usgs.gov/fdsnws/event/1/count?format=geojson&eventtype=earthquake&minmmi=7";
    string constant startQueryStringEmpty = "&starttime=";
    string constant endQueryStringEmpty = "&endtime=";
    string constant minMag5 = "&minmag=5&minradiuskm=100";
    string constant minMag6 = "&minmag=6&minradiuskm=200";
    string constant minMag7 = "&minmag=7&minradiuskm=400";

    //ChainLink GET request and multiply for Uint256 oracle
    address private oracle = address(0x9904415Db0B70fDd242b6Fe835d2bBc155466e8e);
    bytes32 private jobId = "69cf5186b05a4497be74f85236e8ba34"; //TODO: change for mainnet before deploying
    uint256 private fee = 0.1 * 1e18;

    //Used by the callback functions AND ONLY BY THEM
    uint256 private prob5Mw;
    uint256 private prob6Mw;
    uint256 private prob7Mw;

    uint8 private ownerCut = 0.01 * 1e2; // in percents

    //Tokens used as settlement (stablecoins)
    //address constant DAI_ADDRESS = address(0x6B175474E89094C44Da98b954EedeAC495271d0F); //FTM: 0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E;
    address constant DAI_ADDRESS_RINKEBY = address(0x95b58a6Bff3D14B7DB2f5cb5F0Ad413DC2940658);
    address constant QVT_ADDRESS = address(0xdeadbeef); //TODO: change
    address constant LINK_ADDRESS_RINKEBY = address(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);

    IERC20 private immutable stableCoin;
    IERC20 private immutable QVT;

    struct Insurance {
        uint256 amount;
        uint256 start;
        uint256 end;
        int32 lat;
        int32 lon;
    }

    struct BuyInsurance {
        uint256 amount;
        uint8 nyears;
        int32 lat;
        int32 lon;
    }

    uint8 constant private MAX_INSURANCE_N = 10;
    uint8 constant private MIN_YEARS = 1;
    uint8 constant private MAX_YEARS = 10;
    uint256 constant private DELAY = 2 weeks; // delay of insurance buy or insurer withdrawal actions to prevent farming swarms of earthquakes
    //Bought insurance TODO: make secret with zokrates
    mapping(address => Insurance[]) private insurances;

    //provided insurance
    mapping(address => uint256) private insurers;
    mapping(address => uint256) private unstakePending;

    constructor() Ownable(){
        setChainlinkToken(LINK_ADDRESS_RINKEBY); //TODO: change for mainnet, etc. before deploying
        stableCoin = IERC20(DAI_ADDRESS_RINKEBY);
        QVT = IERC20(QVT_ADDRESS);
    }

    function setOwnerCut(uint8 _cut) public onlyOwner{
        ownerCut = _cut;
    }


    function buyInsurance(BuyInsurance calldata _ins)
        external
        nonReentrant
        moreThanZero(_ins.amount)
        supportedLocation(_ins.lat, _ins.lon)
        resetProbVars
        sufficientStableCoin(_ins.amount)
        sufficientLink(3)
        sufficientInsuranceSpace
        validYears(_ins.nyears)
    {
        //check location
        string memory regionQueryString;
        if (_ins.lat < ceusMinlongitude){
            //check API for western US
            regionQueryString = wusQueryString;
        }
        else {
            //check API for central and eastern US
            regionQueryString = ceusQueryString;
        }
        //request probabilities for 5Mw, 6Mw and 7Mw earthquakes in the surrounding areas
        string[3] memory queryDistanceStrings = [composeProbabilityQuery5Mw(regionQueryString, _ins.lat, _ins.lon, _ins.nyears),
                                                composeProbabilityQuery6Mw(regionQueryString,_ins.lat, _ins.lon, _ins.nyears),
                                                composeProbabilityQuery7Mw(regionQueryString,_ins.lat, _ins.lon, _ins.nyears)];
        Chainlink.Request[3] memory requests = [buildChainlinkRequest(jobId, address(this), this.fulfill5Mw.selector),
                                                buildChainlinkRequest(jobId, address(this), this.fulfill6Mw.selector),
                                                buildChainlinkRequest(jobId, address(this), this.fulfill7Mw.selector)];
        requests[0].add("get", queryDistanceStrings[0]);
        requests[1].add("get", queryDistanceStrings[1]);
        requests[2].add("get", queryDistanceStrings[2]);
        requests[0].add("path", PATH_5Mw);
        requests[1].add("path", PATH_6Mw);
        requests[2].add("path", PATH_7Mw);
        requests[0].add("times", PROB_SCALE);
        requests[1].add("times", PROB_SCALE);
        requests[2].add("times", PROB_SCALE);
        sendChainlinkRequestTo(oracle, requests[0], fee);
        sendChainlinkRequestTo(oracle, requests[1], fee); // fails silently in case value not present (this is OK, old values get cleaned by resetProbVars)
        sendChainlinkRequestTo(oracle, requests[2], fee);
        uint256 totalProb = prob5Mw + prob6Mw + prob7Mw;
        //transfer QVT
        QVT.transfer(address(this), totalProb);
        //transfer amount Dai
        stableCoin.transfer(address(this), _ins.amount);
        //register coordinates in mapping
        uint256 nYears = yearsToUint(_ins.nyears);
        insurances[msg.sender].push(Insurance(_ins.amount, block.timestamp + DELAY, block.timestamp + nYears + DELAY, _ins.lat, _ins.lon));
    }

    function getInsurances(address _addr) public view returns(Insurance[] memory){
        require(msg.sender == _addr); //TODO: use zokrates to actually make secret
        Insurance[] memory insArr = insurances[_addr];
        return insArr;
    }

    function insure(uint256 _amount) external
        nonReentrant
        moreThanZero(_amount)
        sufficientStableCoin(_amount) {
        //transfer Dai
        stableCoin.transfer(address(this), _amount);
        //register insurer
        insurers[msg.sender] += _amount;
    }

    function startUnstake(uint256 _amount) external
        nonReentrant
        moreThanZero(_amount)
        sufficientStaked(_amount) {

    }

    //function claimInsurance(){
        //TODO
        //only if strong enough EQ has happened in the radii during insured time and 2 weeks wait time have passed
    //}

    //function withdrawInsurance(){
        //TODO
        //anytime, user guarded
    //}

    modifier sufficientStaked(uint256 _amount) {
        if (insurers[msg.sender] < _amount){
            revert InsufficientStaked();
        }
        _;
    }

    modifier sufficientStableCoin(uint256 _amount){
        if (stableCoin.balanceOf(msg.sender) < _amount){
            revert InsufficientStableCoin();
        }
        _;
    }

    modifier sufficientLink(uint8 _nqueries){
        if (IERC20(chainlinkTokenAddress()).balanceOf(msg.sender) < _nqueries * fee){
            revert InsufficientLink();
        }
        _;
    }

    modifier sufficientInsuranceSpace(){
        if (insurances[msg.sender].length > MAX_INSURANCE_N) {
            revert InsufficientSpace();
        }
        _;
    }

    modifier validYears(uint8 _years){
        if (MIN_YEARS > _years && _years > MAX_YEARS){
            revert InvalidYears();
        }
        _;
    }

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

    function composeProbabilityQuery6Mw(string memory _regionQueryString, int32 _lat, int32 _lon, uint8 _timespan) public pure returns(string memory){
        return string(abi.encodePacked(usgsAPIProbability, _regionQueryString, latEmptyQueryString, DataUtil.intToStringDecimal(_lat, coordinateScalingFactorLog10),
            lonEmptyQueryString, DataUtil.intToStringDecimal(_lon, coordinateScalingFactorLog10),
            distance6Mw,
            timespanEmptyQueryString, Strings.toString(_timespan)));
    }

    function composeProbabilityQuery7Mw(string memory _regionQueryString, int32 _lat, int32 _lon, uint8 _timespan) public pure returns(string memory){
        return string(abi.encodePacked(usgsAPIProbability, _regionQueryString, latEmptyQueryString, DataUtil.intToStringDecimal(_lat, coordinateScalingFactorLog10),
            lonEmptyQueryString, DataUtil.intToStringDecimal(_lon, coordinateScalingFactorLog10),
            distance7Mw,
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

    function yearsToUint(uint8 _years) private pure returns(uint256){
        return _years *52* 7 * 24 *60*60;
    }

    function setOracle(address _oracle, bytes32 _jobId, uint256 _fee) public onlyOwner{
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
    }

    function fulfill5Mw(bytes32 _requestId, uint256 _prob) public recordChainlinkFulfillment(_requestId){
        prob5Mw = _prob;
    }

    function fulfill6Mw(bytes32 _requestId, uint256 _prob) public recordChainlinkFulfillment(_requestId){
        prob6Mw = _prob;
    }

    function fulfill7Mw(bytes32 _requestId, uint256 _prob) public recordChainlinkFulfillment(_requestId){
        prob7Mw = _prob;
    }

    modifier resetProbVars(){
        prob5Mw = 0;
        prob6Mw = 0;
        prob7Mw = 0;
        _;
    }
    /**
    receive() external payable{
        emit Received(msg.sender, 0x0, msg.value);
    }*/

}
