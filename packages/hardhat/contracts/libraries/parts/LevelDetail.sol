// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

pragma abicoder v2;

/// @title Level generator
library LevelDetail {

    function buildLevel(uint256 _tokenLevel)pure public returns(string memory){
        return _readyLevelSVG(_tokenLevel);
    }

    /// @dev Combines Level component with the base SVG component
    function _readyLevelSVG(uint256 _tokenLevel)
        private
        pure
        returns (string memory)
    {
        return base(string(abi.encodePacked(_level(_tokenLevel))));
    }

    function _level(uint256 _tokenLevel) private pure returns (string memory) {
        return string(
            abi.encodePacked(
               '<text x="0" y="0" text-anchor="middle" font-family="serif" font-size="22px" fill="#000">LEVEL</text>',
               '<text x="0" y="30" text-anchor="middle" font-weight="bold" font-family="serif" font-size="22px" fill="#000">',_tokenLevel,"</text>"
            )
        );
    }

    /// @dev The base SVG for the level segment
    function base(string memory children) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<g id="level" transform="translate(204.5, 355)">', children, "</g>"
            )
        );
    }
}