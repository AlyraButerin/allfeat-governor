// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {MyGovernor} from "../../src/MyGovernor.sol";
import {Box} from "../../src/Box.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {GovToken} from "../../src/GovToken.sol";
import {HelperConfig} from "../HelperConfig.s.sol";

/*
 * @note owner is used to broadcast to have the same behavior in all scripts and cases
 */
contract DeployOnlyGovernor is Script {
    struct NetworkConfig {
        address deployerAddress;
        uint256 deployerKey;
        uint256 chainId;
    }

    GovToken public govToken;
    TimeLock public timeLock;
    MyGovernor public governor;
    Box public box;
    HelperConfig helperConfig;

    address[] public proposers;
    address[] public executors;

    address owner;

    uint256 public constant INITIAL_SUPPLY = 100 ether;
    uint256 public constant MIN_DELAY = 3600; // 1 hour, after a vote is passed
    uint256 public constant VOTING_DELAY = 1; // 1 block, blocks till a proposal is active
    uint256 public constant VOTING_PERIOD = 50400;

    function run() external returns (address, MyGovernor) {
        // uint256 gasLimit = block.gaslimit;
        // console.log("Gas limit / before deployment:", gasLimit);

        helperConfig = new HelperConfig();

        (address deployerAddress,, uint256 chainId) = helperConfig.activeNetworkConfig();
        owner = deployerAddress;
        console.log("Chain ID", chainId);
        console.log("Owner public address", owner);

        // get most recent deployments of Box, GovToken and TimeLock
        // address mostRectenlyDeployedBox = DevOpsTools.get_most_recent_deployment("Box", block.chainid);
        address mostRectenlyDeployedGovToken = DevOpsTools.get_most_recent_deployment("GovToken", block.chainid);
        address mostRectenlyDeployedTimeLock = DevOpsTools.get_most_recent_deployment("TimeLock", block.chainid);

        // box = Box(mostRectenlyDeployedBox);
        govToken = GovToken(mostRectenlyDeployedGovToken);
        address payable timeLockAdd = payable(mostRectenlyDeployedTimeLock);
        timeLock = TimeLock(timeLockAdd);

        //log addresses
        // console.log("Box address get from Governor deploy script :", mostRectenlyDeployedBox);
        // console.log("GovToken address get from Governor deploy script :", mostRectenlyDeployedGovToken);
        // console.log("TimeLock address get from Governor deploy script :", mostRectenlyDeployedTimeLock);
        // console.log("TimeLock payable address :", timeLockAdd);

        vm.startBroadcast(owner);

        governor = new MyGovernor(govToken, timeLock);

        vm.stopBroadcast();
        // uint256 gasLeftAfterDeploy = gasleft();
        // console.log("Gas left / after deployment:", gasLeftAfterDeploy);

        return (owner, governor);
    }
}
