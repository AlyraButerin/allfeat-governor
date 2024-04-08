// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

/**
 * @title Box
 * @dev This contract has a number that can be changed
 * @dev This is the target of proposal execution
 * @dev It should be owned by the TimeLock contract to be able to execute changes
 */
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 private number;

    event NumberChanged(uint256 newValue);

    constructor(address owner) Ownable(owner) {
        number = 0;
    }

    function store(uint256 newNumber) public onlyOwner {
        number = newNumber;
        emit NumberChanged(newNumber);
    }

    function retrieve() public view returns (uint256) {
        return number;
    }
}
