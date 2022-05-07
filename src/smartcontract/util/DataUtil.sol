pragma solidity ^0.8.0;

library DataUtil {
    /**
     * @dev Converts a `int256` to its ASCII `string` decimal representation.
     */
    function intToString(int256 value) internal pure returns (string memory) {
        if (value == 0){
            return "0";
        }
        uint256 v = uint256(value < 0 ? -value: value);
        uint8 digits = nDigits(v);
        bytes memory buffer = new bytes(digits);
        while (v > 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(v % 10)));
            v /= 10;
        }
        if (value < 0) {
            return string(abi.encodePacked("-", string(buffer)));
        }
        else {
            return string(buffer);
        }
    }

    /**
    * Converts an int256 to its ASCII string decimal representation, after being divided by 10 ** ndecimals without losing
    * any numbers behind the point.
    */
    function intToStringDecimal(int256 value, int256 ndecimals) internal pure returns (string memory){
        //TODO
        return "";
    }

    /**
    * Counts the number of digits and returns that value as uint8.
    */
    function nDigits(uint256 value) internal pure returns (uint8){
        uint256 temp = value;
        uint8 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        return digits;
    }
}
