// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {TimeLock} from "../../src/TimeLock.sol";
import {HelperConfig} from "../HelperConfig.s.sol";

/*
 * @note owner is used to broadcast to have the same behavior in all scripts and cases
 */

contract DeployOnlyTimeLock is Script {
    struct NetworkConfig {
        address deployerAddress;
        uint256 deployerKey;
        uint256 chainId;
    }

    TimeLock public timeLock;
    HelperConfig helperConfig;

    address[] public proposers;
    address[] public executors;

    address owner;

    uint256 public constant MIN_DELAY = 3600; // 1 hour, after a vote is passed

    function run() external returns (address, TimeLock) {
        // uint256 gasLimit = block.gaslimit;
        // console.log("Gas limit / before deployment:", gasLimit);

        helperConfig = new HelperConfig();

        (address deployerAddress,, uint256 chainId) = helperConfig.activeNetworkConfig();
        owner = deployerAddress;
        console.log("Chain ID", chainId);
        console.log("Owner public address", owner);

        vm.startBroadcast(owner);

        timeLock = new TimeLock(MIN_DELAY, proposers, executors, owner); // everyone can propose and execute

        console.log("TimeLock address", address(timeLock));

        vm.stopBroadcast();
        // uint256 gasLeftAfterDeploy = gasleft();
        // console.log("Gas left / after deployment:", gasLeftAfterDeploy);

        return (owner, timeLock);
    }
}
