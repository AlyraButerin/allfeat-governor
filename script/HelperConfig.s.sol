// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

/*
 * @note owner is used to broadcast to have the same behavior in all scripts and cases
 * if needed we can get it with the deployer address in the network config
 */
/**
 * @title HelperConfig
 * @dev script used to get network related config if needed
 */
contract HelperConfig is Script {
    /**
     * @dev NetworkConfig struct
     * @dev deployerKey is here ONLY FOR TEST AND DEBUG PURPOSES if needed (not best practice)
     * @param deployerAddress: address of the deployer
     * @param deployerKey: private key of the deployer
     * @param chainId: chain id
     */
    struct NetworkConfig {
        address deployerAddress;
        uint256 deployerKey;
        uint256 chainId;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == 441) {
            activeNetworkConfig = getAllfeatConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            deployerAddress: vm.envAddress("SEPOLIA_WALLET_ADDRESS"),
            deployerKey: vm.envUint("SEPOLIA_PRIVATE_KEY"),
            chainId: block.chainid
        });
    }

    function getAllfeatConfig() public view returns (NetworkConfig memory) {
        return NetworkConfig({
            deployerAddress: vm.envAddress("ALLFEAT_WALLET_ADDRESS"),
            deployerKey: vm.envUint("ALLFEAT_PRIVATE_KEY"),
            chainId: block.chainid
        });
    }

    function getOrCreateAnvilConfig() public view returns (NetworkConfig memory) {
        if (activeNetworkConfig.deployerAddress != address(0)) {
            return activeNetworkConfig;
        }

        //default foundry msg.sender address
        address defaultOwner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;

        return NetworkConfig({
            deployerAddress: defaultOwner,
            deployerKey: vm.envUint("ALLFEAT_PRIVATE_KEY"), //not needed in local
            chainId: block.chainid
        });
    }
}
