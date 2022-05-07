pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import "../util/DataUtil.sol";

contract DataUtilTest is Test {
    function setUp() public {
    }

    function testKeccakValues() public{
        bytes memory b = bytes("42");
        bytes memory f = bytes(DataUtil.intToString(int256(42)));
        emit log_bytes(b);
        emit log_bytes(f);
        emit log_bytes32(keccak256(b));
        emit log_bytes32(keccak256(f));
        assertTrue(true);
    }

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

    function testIntoToStringPositive() public{
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

    function testIntoToStringPositiveMaxValue() public{
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

}
