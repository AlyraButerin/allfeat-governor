// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
// import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {GovToken} from "../src/GovToken.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/*
 * @note owner is used to broadcast to have the same behavior in all scripts and cases
 */
/**
 * @title DeployGovernor
 * @dev This contract deploys the Governor contracts and sets up the roles, ownership and delegation
 *
 */
contract DeployGovernor is Script {
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

    function run() external returns (address, GovToken, TimeLock, MyGovernor, Box) {
        // uint256 gasLimit = block.gaslimit;
        // console.log("Gas limit / before deployment:", gasLimit);

        uint256 gasLeftBeforeDeploy = gasleft();
        console.log("Gas left / before deployment:", gasLeftBeforeDeploy);

        helperConfig = new HelperConfig();

        (address deployerAddress,, uint256 chainId) = helperConfig.activeNetworkConfig();
        owner = deployerAddress;
        console.log("Chain ID", chainId);
        console.log("Owner/Deployer address", owner);

        vm.startBroadcast(owner);

        govToken = new GovToken();
        // uint256 gasLeftAfterTokenDeploy = gasleft();
        // console.log("Gas left / after GovToken deployment:", gasLeftAfterTokenDeploy);
        govToken.mint(owner, INITIAL_SUPPLY);
        govToken.delegate(owner); // to allow ourselves to vote
        // uint256 gasLeftAfterTokenActions = gasleft();
        // console.log("Gas left / after GovToken actions:", gasLeftAfterTokenActions);

        timeLock = new TimeLock(MIN_DELAY, proposers, executors, owner); // everyone can propose and execute
        // uint256 gasLeftAfterTimeLockDeploy = gasleft();
        // console.log("Gas left / after MyGovernor deployment:", gasLeftAfterTimeLockDeploy);

        governor = new MyGovernor(govToken, timeLock);
        // uint256 gasLeftAfterGovDeploy = gasleft();
        // console.log("Gas left / after MyGovernor deployment:", gasLeftAfterGovDeploy);

        // roles
        bytes32 proposerRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();

        timeLock.grantRole(proposerRole, address(governor));
        timeLock.grantRole(executorRole, address(0)); // anyone can execute
        timeLock.revokeRole(adminRole, owner); // remove the default admin role => no more admin
        uint256 gasLeftAfterRoles = gasleft();
        console.log("Gas left / after roles attributions:", gasLeftAfterRoles);

        // box = new Box(address(this));
        box = new Box(owner);
        // uint256 gasLeftAfterBoxDeploy = gasleft();
        // console.log("Gas left / after GovToken actions:", gasLeftAfterBoxDeploy);

        // addresses of contracts :
        console.log("GovToken address", address(govToken));
        console.log("TimeLock address", address(timeLock));
        console.log("MyGovernor address", address(governor));
        console.log("Box address", address(box));

        //ownership of contracts :
        // console.log("GovToken owner", owner);
        // console.log("TimeLock owner", timeLock.owner());
        // console.log("MyGovernor owner", governor.owner());
        console.log("Box owner", box.owner());

        box.transferOwnership(address(timeLock));
        // uint256 gasLeftAfterBoxTransfer = gasleft();
        // console.log("Gas left / after GovToken actions:", gasLeftAfterBoxTransfer);

        // timeLock ultimately controls the box
        console.log("New Box owner", box.owner());

        vm.stopBroadcast();
        uint256 gasLeftAfterDeploy = gasleft();
        console.log("Gas left / after deployment:", gasLeftAfterDeploy);

        return (owner, govToken, timeLock, governor, box);
    }
}
