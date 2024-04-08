// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MyGovernor} from "../../src/MyGovernor.sol";
import {Box} from "../../src/Box.sol";
import {TimeLock} from "../../src/TimeLock.sol";
import {GovToken} from "../../src/GovToken.sol";
import {HelperConfig} from "../HelperConfig.s.sol";

/*
 * @note owner is used to broadcast to have the same behavior in all scripts and cases
 * @note BUGGY at the moment :  Action2_propose not passed
 */
contract GovernorStepDeployTest is Test {
    MyGovernor governor;
    Box box;
    TimeLock timeLock;
    GovToken govToken;
    HelperConfig helperConfig;

    address public owner;

    uint256[] public values;
    bytes[] public calldatas;
    address[] public targets;

    function run() public {
        // ======> get the most recent deployment addresses and the owner address
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

        // ======> EXECUTE
        // proposal parameters
        uint256 valueToStore = 888;
        string memory description = "store 888 in the box";
        bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

        values.push(0); // no value to send
        calldatas.push(encodedFunctionCall);
        targets.push(address(box));
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // execute parameters
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));

        vm.startBroadcast(owner); // not necessary

        governor.execute(targets, values, calldatas, descriptionHash);

        console.log("GovernorTest / Proposal state :", uint256(governor.state(proposalId)));

        vm.stopBroadcast();
    }
}
