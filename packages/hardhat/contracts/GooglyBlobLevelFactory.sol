// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 < 0.9.0;

// Created By Dannithomx

import "./GooglyBlobStorage.sol";

contract Diamond {
    DiamondStorage internal diamondStorage;

    constructor() {
        diamondStorage = new DiamondStorage();
    }

    function setFacetAddress(bytes4 functionSelector, address facetAddress) external {
        diamondStorage.setFacetAddress(functionSelector, facetAddress);
    }

    function executeFunction(bytes4 functionSelector, bytes calldata data) external returns (bytes memory) {
        address facet = diamondStorage.facetAddresses(functionSelector);
        require(facet != address(0), "Function does not exist");
        
        // Use delegatecall to execute the function in the specified facet
        (bool success, bytes memory result) = facet.delegatecall(data);
        require(success, "Function call failed");

        return result;
    }

    // Other functions and modifiers can be added here
}