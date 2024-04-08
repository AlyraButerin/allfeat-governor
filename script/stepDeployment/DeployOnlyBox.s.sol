// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Box} from "../../src/Box.sol";
import {HelperConfig} from "../HelperConfig.s.sol";

/*
 * @note owner is used to broadcast to have the same behavior in all scripts and cases
 */
contract DeployOnlyBox is Script {
    struct NetworkConfig {
        address deployerAddress;
        uint256 deployerKey;
        uint256 chainId;
    }

    Box public box;
    HelperConfig helperConfig;

    address owner;

    function run() external returns (address, Box) {
        // uint256 gasLimit = block.gaslimit;
        // console.log("Gas limit / before deployment:", gasLimit);

        helperConfig = new HelperConfig();

        (address deployerAddress,, uint256 chainId) = helperConfig.activeNetworkConfig();
        owner = deployerAddress;
        console.log("Chain ID", chainId);
        console.log("Owner/deployer address", owner);

        vm.startBroadcast(owner);

        box = new Box(owner);

        console.log("Box address", address(box));
        console.log("Box owner", box.owner());

        vm.stopBroadcast();
        // uint256 gasLeftAfterDeploy = gasleft();
        // console.log("Gas left / after deployment:", gasLeftAfterDeploy);

        return (box.owner(), box);
    }
}
