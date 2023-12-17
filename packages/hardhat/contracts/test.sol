// DiamondProxy.sol
// This is the diamond contract that acts as a proxy and routes function calls to the facets
import "./DiamondStorageBase.sol"; // This is the contract that defines the diamond storage struct
import "./DiamondCutter.sol"; // This is the contract that implements the diamondCut function
import "./DiamondLoupeFacet.sol"; // This is the contract that implements the diamond loupe functions
import "./IDiamondFacet.sol"; // This is the interface for the facets
import "./IDiamondProxy.sol"; // This is the interface for the diamond proxy

abstract contract DiamondProxy is DiamondStorageBase, IDiamondProxy {
    constructor () public {
        DiamondCutter diamondCutter = new DiamondCutter(); // Create a new diamond cutter contract
        dataAddress["diamondCutter"] = address(diamondCutter); // Store the address of the diamond cutter in the diamond storage
        DiamondLoupeFacet diamondLoupeFacet = new DiamondLoupeFacet(); // Create a new diamond loupe facet contract
        address[] memory facets = new address; // Create an array of facet addresses
        facets[0] = address(diamondLoupeFacet); // Add the diamond loupe facet address to the array
        _registerFacets(facets); // Register the facets and their function selectors in the diamond
    }

    // IDiamondProxy function
    // This function allows the diamond to register new facets
    function registerFacets (address[] memory _facets) public override {
        require(msg.sender == address(this), 'external caller not allowed'); // Only the diamond can call this function
        _registerFacets(_facets); // Register the facets and their function selectors in the diamond
    }

    // Internal methods
    // This function registers the facets and their function selectors in the diamond
    function _registerFacets (address[] memory _facets) internal {
        bytes[] memory changes = new bytes; // Create an array of bytes to store the changes
        for (uint i = 0; i < _facets.length; i += 1) {
            IDiamondFacet f = IDiamondFacet(_facets[i]); // Create an interface for the facet
            bytes memory selectors = f.getSelectors(); // Get the function selectors of the facet
            changes[i] = abi.encodePacked(_facets[i], selectors); // Encode the facet address and the selectors into bytes
        }
        _cut(changes); // Execute the diamond cut function with the changes
    }

    // This function executes the diamond cut function with the changes
    function _cut (bytes[] memory _changes) internal {
        bytes memory cutFunction = abi.encodeWithSelector(DiamondCutter.diamondCut.selector, _changes); // Encode the diamond cut function selector and the changes into bytes
        (bool success,) = dataAddress["diamondCutter"].delegatecall(cutFunction); // Delegate call the diamond cutter contract with the encoded data
        require(success, "Adding functions failed."); // Check if the call was successful
    }

    // This is the fallback function that routes function calls to the facets
    fallback() external payable {
        DiamondStorage storage ds = diamondStorage(); // Get the diamond storage struct
        address facet = ds.facetAddress[msg.sig]; // Get the facet address for the function selector
        require(facet != address(0), "Function does not exist."); // Check if the facet exists
        assembly {
            // Copy the calldata to memory
            calldatacopy(0, 0, calldatasize())
            // Delegate call the facet with the calldata
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // Copy the return data to memory
            returndatacopy(0, 0, returndatasize())
            // Check if the call was successful
            switch result
            // Return the return data
            case 0 {revert(0, returndatasize())}
            default {return (0, returndatasize())}
        }
    }
}
