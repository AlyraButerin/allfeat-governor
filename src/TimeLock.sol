// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {TimelockController} from "@openzeppelin/contracts/governance/TimelockController.sol";

/**
 * @title TimeLock
 * @dev This contract is a TimelockController
 * @dev This is the master contract as it manages roles/delay and owns the target contract (Box)
 * @dev It is used to queue and execute operations
 * @dev It is used to allow people to leave the system if they disagree with a proposal
 */
contract TimeLock is TimelockController {
    /**
     * @param minDelay: minimum delay for a proposal to be executed
     * @param proposers: list of addresses that can propose a new operation
     * @param executors: list of addresses that can execute a proposal
     * @param admin: address that can change the proposers, executors and the delay
     */
    constructor(uint256 minDelay, address[] memory proposers, address[] memory executors, address admin)
        TimelockController(minDelay, proposers, executors, admin)
    {}
}
