// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {MyGovernor} from "../../src/MyGovernor.sol";
import {Box} from "../../src/Box.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {GovToken} from "../../src/GovToken.sol";
import {HelperConfig} from "../HelperConfig.s.sol";

contract SetupDAO is Script {
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

    address owner;

    function run() external returns (address, GovToken, TimeLock, MyGovernor, Box) {
        // uint256 gasLimit = block.gaslimit;
        // console.log("Gas limit / before deployment:", gasLimit);

        helperConfig = new HelperConfig();

        (address deployerAddress,, uint256 chainId) = helperConfig.activeNetworkConfig();
        owner = deployerAddress;
        console.log("Chain ID", chainId);
        console.log("Owner public address", owner);

        address mostRectenlyDeployedBox = DevOpsTools.get_most_recent_deployment("Box", block.chainid);
        address mostRectenlyDeployedGovToken = DevOpsTools.get_most_recent_deployment("GovToken", block.chainid);
        address mostRectenlyDeployedTimeLock = DevOpsTools.get_most_recent_deployment("TimeLock", block.chainid);
        address mostRecentlyDeployedGovernor = DevOpsTools.get_most_recent_deployment("MyGovernor", block.chainid);

        box = Box(mostRectenlyDeployedBox);
        govToken = GovToken(mostRectenlyDeployedGovToken);
        address payable timeLockAdd = payable(mostRectenlyDeployedTimeLock);
        timeLock = TimeLock(timeLockAdd);
        address payable governorAdd = payable(mostRecentlyDeployedGovernor);
        governor = MyGovernor(governorAdd);

        //log addresses
        // console.log("Box address get from DAO setup script :", mostRectenlyDeployedBox);
        // console.log("GovToken address get from DAO setup script :", mostRectenlyDeployedGovToken);
        // console.log("TimeLock address get from DAO setup script :", mostRectenlyDeployedTimeLock);
        // console.log("TimeLock payable address :", timeLockAdd);
        // console.log("Governor address get from DAO setup script :", mostRecentlyDeployedGovernor);
        // console.log("Governor payable address :", governorAdd);

        vm.startBroadcast(owner);

        // roles
        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();

        timeLock.grantRole(proposerRole, address(governor));
        timeLock.grantRole(executorRole, address(0)); // anyone can execute
        timeLock.revokeRole(adminRole, owner); // remove the default admin role => no more admin

        vm.stopBroadcast();
        // uint256 gasLeftAfterDeploy = gasleft();
        // console.log("Gas left / after deployment:", gasLeftAfterDeploy);

        return (owner, govToken, timeLock, governor, box);
    }
}
