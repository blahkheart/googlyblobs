// DiamondStorage.sol

// This contract stores data for the Diamond contract
// It can be upgraded independently of the Diamond contract

// SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// contract DiamondStorage {
//     mapping(bytes4 => address) public facetAddresses;

//     // Other storage variables can be added here

//     modifier onlyDiamond {
//         require(facetAddresses[msg.sig] != address(0), "Function does not exist");
//         _;
//     }

//     function setFacetAddress(bytes4 functionSelector, address facetAddress) external {
//         // Only allow the Diamond contract to set facet addresses
//         require(msg.sender == facetAddresses[functionSelector], "Not authorized");
//         facetAddresses[functionSelector] = facetAddress;
//     }
// }


// DiamondStorageBase.sol
// This is the contract that defines the diamond storage struct
pragma solidity ^0.8.0;

contract DiamondStorageBase {
    // This is the struct that stores the data for the NFT game
    struct GameData {
        uint256 levelUpRange; // The range of levels that can be upgraded
        mapping(address => LevelData) levelData; // The mapping of level addresses to level data structs
        mapping(address => bool) levels; // The mapping of level addresses to boolean values indicating if they are registered or not
        uint256 levelUpFee; // The fee for upgrading a level
    }

    // This is the struct that stores the data for each level
    struct LevelData {
        address levelAddress; // The address of the level contract
        address levelCreator; // The address of the level creator
        uint256 minAllowedLevel; // The minimum level required to play the level
    }

    // This is the struct that stores the data for the diamond
    struct DiamondStorage {
        mapping(bytes4 => address) facetAddress; // The mapping of function selectors to facet addresses
        mapping(address => bytes4[]) facetFunctionSelectors; // The mapping of facet addresses to function selectors
        bytes4[] selectors; // The array of all function selectors
        address[] facets; // The array of all facet addresses
        GameData gameData; // The game data struct
    }

    // This is the function that returns the diamond storage struct
    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        // Create a bytes32 variable to store the position of the diamond storage struct in the contract storage
        bytes32 position = keccak256("diamond.storage");
        // Load the diamond storage struct from the contract storage
        assembly {
            ds.slot := position
        }
    }
}
