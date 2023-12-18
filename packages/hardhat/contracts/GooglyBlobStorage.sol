// DiamondStorage.sol

// This contract stores data for the Diamond contract
// It can be upgraded independently of the Diamond contract

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiamondStorage {
    mapping(bytes4 => address) public facetAddresses;

    // Other storage variables can be added here

    modifier onlyDiamond {
        require(facetAddresses[msg.sig] != address(0), "Function does not exist");
        _;
    }

    function setFacetAddress(bytes4 functionSelector, address facetAddress) external {
        // Only allow the Diamond contract to set facet addresses
        require(msg.sender == facetAddresses[functionSelector], "Not authorized");
        facetAddresses[functionSelector] = facetAddress;
    }
}