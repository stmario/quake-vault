pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../util/DataUtil.sol";

contract DataUtilTest is Test {
    function setUp() public {
    }

    /**
    function testKeccakValues() public{
        bytes memory b = bytes("42");
        bytes memory f = bytes(DataUtil.intToString(int256(42)));
        emit log_bytes(b);
        emit log_bytes(f);
        emit log_bytes32(keccak256(b));
        emit log_bytes32(keccak256(f));
        assertTrue(true);
    }*/

    function testIntToStringNegative() public{
        string memory res = DataUtil.intToString(int256(-42));
        string memory hh = "-42";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }

    function testIntToStringNegativeMinVal() public{
        string memory res = DataUtil.intToString(type(int256).min + 1); //TODO: find out why min value gives under/overflow
        string memory hh = "-57896044618658097711785492504343953926634992332820282019728792003956564819967";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }

    function testIntToToStringPositive() public{
        string memory res = DataUtil.intToString(int256(42));
        string memory hh = "42";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }

    function testIntToToStringPositiveMaxValue() public{
        string memory res = DataUtil.intToString(type(int256).max);
        string memory hh = "57896044618658097711785492504343953926634992332820282019728792003956564819967";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }

    function testIntToToStringDecimalPositiveSmall() public{
        string memory res = DataUtil.intToStringDecimal(int256(42), 2);
        string memory hh = "0.42";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }

    function testIntToToStringDecimalPositiveMedium() public{
        string memory res = DataUtil.intToStringDecimal(int256(42), 1);
        string memory hh = "4.2";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }

    function testIntToToStringDecimalPositiveLarge() public{
        string memory res = DataUtil.intToStringDecimal(type(int256).max, 10);
        string memory hh = "5789604461865809771178549250434395392663499233282028201972879200395.6564819967";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }

    function testIntToToStringDecimalPositiveVerySmall() public{
        string memory res = DataUtil.intToStringDecimal(42, 3);
        string memory hh = "0.042";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }

    function testIntToToStringDecimalPositiveVerySmallExtreme() public{
        string memory res = DataUtil.intToStringDecimal(type(int256).max, 80);
        string memory hh = "0.00057896044618658097711785492504343953926634992332820282019728792003956564819967";
        if (keccak256(bytes(res)) == keccak256(bytes(hh))){
            assertTrue(true);
        }
        else {
            emit log_string(res);
            fail();
        }
    }
}
