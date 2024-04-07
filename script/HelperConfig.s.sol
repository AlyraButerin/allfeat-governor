// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
// import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
// import {ERC20Mock} from "../test/mocks/ERC20Mock.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address ownerPubAddress;
        uint256 deployerKey;
        uint256 chainId;
    }
    // address wbtcUsdPriceFeed;
    // address weth;
    // address wbtc;
    // uint256 deployerKey;

    // uint8 public constant DECIMALS = 8;
    // int256 public constant ETH_USD_PRICE = 2000e8; // 2000 * 10 ** DECIMALS
    // int256 public constant BTC_USD_PRICE = 1000e8; // 1000 * 10 ** DECIMALS
    // uint256 public constant ETH_INITIAL_BALANCE = 1000 * 10 ** DECIMALS; // 1000e18; //1000 * 10 ** DECIMALS; // 1000e8
    // uint256 public constant BTC_INITIAL_BALANCE = 1000 * 10 ** DECIMALS; // 1000e8
    // uint256 public constant DEFAULT_ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

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
        // https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1
        // custom weth9 and wbtc already deployed
        return NetworkConfig({
            ownerPubAddress: 0xCAfDB1c46c5036A83e2778CCc85e0F12Ce21Eb06,
            deployerKey: vm.envUint("SEPOLIA_PRIVATE_KEY"),
            chainId: 11155111
        });
    }

    function getAllfeatConfig() public view returns (NetworkConfig memory) {
        // https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1
        // custom weth9 and wbtc already deployed
        return NetworkConfig({
            ownerPubAddress: 0xbfae728Cf6D20DFba443c5A297dC9b344108de90,
            deployerKey: vm.envUint("ALLFEAT_PRIVATE_KEY"),
            chainId: 441
        });
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.ownerPubAddress != address(0)) {
            return activeNetworkConfig;
        }

        //default add and pvkey (foundry add)
        address defaultOwner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        // uint256 defaultDeployerKey = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

        return NetworkConfig({
            ownerPubAddress: defaultOwner,
            deployerKey: vm.envUint("ALLFEAT_PRIVATE_KEY"),
            chainId: block.chainid
        });
    }
}
