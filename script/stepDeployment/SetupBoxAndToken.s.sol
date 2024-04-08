// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

import {MyGovernor} from "../../src/MyGovernor.sol";
import {Box} from "../../src/Box.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {GovToken} from "../../src/GovToken.sol";
import {HelperConfig} from "../HelperConfig.s.sol";
// import {DeployOnlyBox} from "./DeployOnlyBox.s.sol";
// import {DeployOnlyToken} from "./DeployOnlyToken.s.sol";
// import {DeployOnlyTimeLock} from "./DeployOnlyTimeLock.s.sol";

/*
 * @note owner is used to broadcast to have the same behavior in all scripts and cases
 */

contract SetupBoxAndToken is Script {
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

    uint256 public constant INITIAL_SUPPLY = 100 ether;

    function run() external returns (address, GovToken, TimeLock, MyGovernor, Box) {
        // uint256 gasLimit = block.gaslimit;
        // console.log("Gas limit / before deployment:", gasLimit);

        helperConfig = new HelperConfig();

        (address deployerAddress,, uint256 chainId) = helperConfig.activeNetworkConfig();
        owner = deployerAddress;
        console.log("Chain ID", chainId);
        console.log("Owner public address", owner);

        vm.startBroadcast(owner);

        // check broadcast address if used (with owner) or not
        // console.log("owner address / broadcaster of external call :", owner);
        // console.log("msg.sender address / caller of run function", msg.sender);

        //get most recent deployments of Box, GovToken and TimeLock
        address mostRectenlyDeployedBox = DevOpsTools.get_most_recent_deployment("Box", block.chainid);
        address mostRectenlyDeployedGovToken = DevOpsTools.get_most_recent_deployment("GovToken", block.chainid);
        address mostRectenlyDeployedTimeLock = DevOpsTools.get_most_recent_deployment("TimeLock", block.chainid);
        // address mostRecentlyDeployedGovernor = DevOpsTools.get_most_recent_deployment("MyGovernor", block.chainid);

        box = Box(mostRectenlyDeployedBox);
        govToken = GovToken(mostRectenlyDeployedGovToken);
        address payable timeLockAdd = payable(mostRectenlyDeployedTimeLock);
        timeLock = TimeLock(timeLockAdd);
        // address payable governorAdd = payable(mostRecentlyDeployedGovernor);
        // governor = MyGovernor(governorAdd);

        //log addresses
        // console.log("Box address get in SetupBoxAndToken script :", mostRectenlyDeployedBox);
        // console.log("GovToken address get in SetupBoxAndToken script :", mostRectenlyDeployedGovToken);
        // console.log("TimeLock address get in SetupBoxAndToken script :", mostRectenlyDeployedTimeLock);
        // console.log("TimeLock payable address :", timeLockAdd);
        // console.log("MyGovernor address get in SetupBoxAndToken script :", mostRecentlyDeployedGovernor);
        // console.log("MyGovernor payable address :", governorAdd);

        govToken.mint(owner, INITIAL_SUPPLY);
        govToken.delegate(owner); // to allow ourselves to vote
        // // uint256 gasLeftAfterTokenOperation = gasleft();
        // // console.log("Gas left / after GovToken actions:", gasLeftAfterTokenOperation);

        box.transferOwnership(address(timeLock));
        // // uint256 gasLeftAfterBoxTransfer = gasleft();
        // // console.log("Gas left / after GovToken actions:", gasLeftAfterBoxTransfer);

        // // timeLock ultimately controls the box
        console.log("New Box owner", box.owner());

        vm.stopBroadcast();
        // uint256 gasLeftAfterDeploy = gasleft();
        // console.log("Gas left / after deployment:", gasLeftAfterDeploy);

        return (owner, govToken, timeLock, governor, box);
    }
}
