// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

// import {Test, console} from "forge-std/Test.sol";
// import {MyGovernor} from "../src/MyGovernor.sol";
// import {Box} from "../src/Box.sol";
// import {TimeLock} from "../src/TimeLock.sol";
// import {GovToken} from "../src/GovToken.sol";
// // import {DeployGovernor} from "../script/DeployGovernor.s.sol";
// import {DeployOnlyBox} from "../script/stepDeployment/DeployOnlyBox.s.sol";
// import {DeployOnlyToken} from "../script/stepDeployment/DeployOnlyToken.s.sol";
// import {DeployOnlyTimeLock} from "../script/stepDeployment/DeployOnlyTimeLock.s.sol";
// import {DeployOnlyGovernor} from "../script/stepDeployment/DeployOnlyGovernor.s.sol";
// import {SetupBoxAndToken} from "../script/stepDeployment/SetupBoxAndToken.s.sol";
// import {SetupDAO} from "../script/stepDeployment/SetupDAO.s.sol";

// contract GovernorStepDeployTest is Test {
//     MyGovernor governor;
//     Box box;
//     TimeLock timeLock;
//     GovToken govToken;

//     DeployOnlyGovernor governorDeployer;
//     DeployOnlyBox boxDeployer;
//     DeployOnlyToken tokenDeployer;
//     DeployOnlyTimeLock timeLockDeployer;
//     SetupBoxAndToken setupBoxAndTokenDeployer;
//     SetupDAO setupDAODeployer;

//     // address boxOwner;
//     // address govTokenOwner;
//     // address timeLockOwner;
//     // address governorOwner;

//     // address public owner = makeAddr("owner");

//     // Allfeat test pubk owner
//     // address public ALLFEAT_owner = 0xbfae728Cf6D20DFba443c5A297dC9b344108de90;
//     // Sepolia test pubk owner
//     // address public SEPOLIA_owner = 0xCAfDB1c46c5036A83e2778CCc85e0F12Ce21Eb06;

//     // Allfeat test pubk owner
//     // address public owner = 0xbfae728Cf6D20DFba443c5A297dC9b344108de90;
//     // Sepolia test pubk owner
//     address public owner;

//     uint256 public constant MIN_DELAY = 3600; // 1 hour, after a vote is passed
//     uint256 public constant VOTING_DELAY = 1; // 1 block, blocks till a proposal is active
//     uint256 public constant VOTING_PERIOD = 50400; // 1 week

//     address[] public proposers;
//     address[] public executors;

//     uint256[] public values;
//     bytes[] public calldatas;
//     address[] public targets;

//     function setUp() public {
//         boxDeployer = new DeployOnlyBox();
//         (address owner1, Box box1) = boxDeployer.run();

//         tokenDeployer = new DeployOnlyToken();
//         tokenDeployer.run();

//         timeLockDeployer = new DeployOnlyTimeLock();
//         (address a, TimeLock b) = timeLockDeployer.run();

//         governorDeployer = new DeployOnlyGovernor();
//         (owner, governor) = governorDeployer.run();

//         setupBoxAndTokenDeployer = new SetupBoxAndToken();
//         setupBoxAndTokenDeployer.run();

//         setupDAODeployer = new SetupDAO();
//         setupDAODeployer.run();

//         //addresses
//         console.log("Box address", address(box));
//         console.log("GovToken address", address(govToken));
//         console.log("TimeLock address", address(timeLock));
//         console.log("Governor address", address(governor));

//         //owners
//         // console.log("Box owner", boxOwner);
//         // console.log("GovToken owner", govTokenOwner);
//         // console.log("TimeLock owner", timeLockOwner);
//         // console.log("Governor owner", owner);

//         //////////////// INITIAL TEST (without deployment script) ////////////////
//         // govToken = new GovToken();
//         // govToken.mint(owner, INITIAL_SUPPLY);

//         // vm.startPrank(owner);
//         // govToken.delegate(owner); // to allow ourselves to vote
//         // timeLock = new TimeLock(MIN_DELAY, proposers, executors, owner); // everyone can propose and execute
//         // governor = new MyGovernor(govToken, timeLock);

//         // // roles
//         // bytes32 proposerRole = timeLock.PROPOSER_ROLE();
//         // bytes32 executorRole = timeLock.EXECUTOR_ROLE();
//         // bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();

//         // timeLock.grantRole(proposerRole, address(governor));
//         // timeLock.grantRole(executorRole, address(0)); // anyone can execute
//         // timeLock.revokeRole(adminRole, owner); // remove the default admin role => no more admin
//         // vm.stopPrank();

//         // timeLock owns the DAO and DAO owns the timeLock
//         // box = new Box(address(this));
//         // box.transferOwnership(address(timeLock));
//         // timeLock ultimately controls the box
//     }

//     function test_CantUpdateBoxWithoutGovernance() public {
//         vm.expectRevert();
//         box.store(1);
//     }

//     function test_GovernanceUpdateBox() public {
//         uint256 valueToStore = 888;
//         string memory description = "store 888 in the box";
//         bytes memory encodedFunctionCall = abi.encodeWithSignature("store(uint256)", valueToStore);

//         values.push(0); // no value to send
//         calldatas.push(encodedFunctionCall);
//         targets.push(address(box));

//         // 1. propose
//         uint256 proposalId = governor.propose(targets, values, calldatas, description);
//         // Proposal state : 0/Pending, 1/Active, 2/Cancelled, 3/Defeated, 4/Succeeded, 5/Queued, 6/Expired, 7/Executed
//         console.log("GovernorTest / Proposal state :", uint256(governor.state(proposalId)));

//         vm.warp(block.timestamp + VOTING_DELAY + 1);
//         vm.roll(block.number + VOTING_DELAY + 1);
//         console.log("GovernorTest / Proposal state :", uint256(governor.state(proposalId)));

//         // 2. vote
//         string memory reason = "888 is froggy!";
//         // support => VoteType : 0/Against, 1/For, 2/Abstain
//         uint8 voteWay = 1; // for

//         vm.prank(owner);
//         governor.castVoteWithReason(proposalId, voteWay, reason);
//         vm.warp(block.timestamp + VOTING_PERIOD + 1); //1
//         vm.roll(block.number + VOTING_PERIOD + 1); //1
//         console.log("GovernorTest / Proposal state :", uint256(governor.state(proposalId)));

//         // 3. queue
//         bytes32 descriptionHash = keccak256(abi.encodePacked(description));
//         governor.queue(targets, values, calldatas, descriptionHash);
//         vm.warp(block.timestamp + MIN_DELAY + 1);
//         vm.roll(block.number + MIN_DELAY + 1);
//         console.log("GovernorTest / Proposal state :", uint256(governor.state(proposalId)));

//         // 4. execute
//         governor.execute(targets, values, calldatas, descriptionHash);

//         assert(box.retrieve() == valueToStore);
//         console.log("GovernorTest / Box value :", box.retrieve());
//     }
// }