// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {GovToken} from "../../src/GovToken.sol";
import {HelperConfig} from "../HelperConfig.s.sol";

/*
 * @note owner is used to broadcast to have the same behavior in all scripts and cases
 */

contract DeployOnlyToken is Script {
    struct NetworkConfig {
        address deployerAddress;
        uint256 deployerKey;
        uint256 chainId;
    }

    GovToken public govToken;
    HelperConfig helperConfig;

    address owner;

    function run() external returns (address, GovToken) {
        // uint256 gasLimit = block.gaslimit;
        // console.log("Gas limit / before deployment:", gasLimit);

        helperConfig = new HelperConfig();

        (address ownerPubAddress,, uint256 chainId) = helperConfig.activeNetworkConfig();
        owner = ownerPubAddress;
        console.log("Chain ID", chainId);
        console.log("Owner public address", owner);

        vm.startBroadcast(owner);

        govToken = new GovToken();

        console.log("GovToken address", address(govToken));

        vm.stopBroadcast();
        // uint256 gasLeftAfterDeploy = gasleft();
        // console.log("Gas left / after deployment:", gasLeftAfterDeploy);

        return (owner, govToken);
    }
}
