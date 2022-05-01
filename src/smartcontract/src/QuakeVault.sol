// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ChainlinkClient} from "../chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract QuakeVault is ChainlinkClient{
    address private owner;

    constructor() {
        owner = msg.sender;
    }


}
