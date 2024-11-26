// LevelFactory.sol
// This is the factory contract that creates new Level contracts using the Diamond Standard
import "./DiamondProxy.sol"; // This is the diamond contract that acts as a proxy and routes function calls to the facets
import "./LevelFacet.sol"; // This is the facet contract that implements the Level functionality

contract LevelFactory {
    // This is the event that is emitted when a new Level is created
    event LevelCreated(address indexed level, address indexed creator);

    // This is the function that creates a new Level contract using the Diamond Standard
    function createLevel() public returns (address) {
        // Create a new diamond proxy contract
        DiamondProxy diamond = new DiamondProxy();
        // Create a new level facet contract
        LevelFacet levelFacet = new LevelFacet();
        // Create an array of facet addresses
        address[] memory facets = new address;
        // Add the level facet address to the array
        facets[0] = address(levelFacet);
        // Register the facets in the diamond
        diamond.registerFacets(facets);
        // Initialize the level with the msg.sender as the creator
        levelFacet.initialize(msg.sender);
        // Emit the LevelCreated event with the diamond address and the creator address
        emit LevelCreated(address(diamond), msg.sender);
        // Return the diamond address
        return address(diamond);
    }
}
