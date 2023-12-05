// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

pragma abicoder v2;

/// @title Eyes SVG generator
library EyesDetail {
    function buildLeftEye(string memory scleraColor, uint256 eyeSize, uint256 pupilSize) public pure returns (string memory){
        return _leftEye(scleraColor, eyeSize, pupilSize);
    }

    function buildRightEye(string memory scleraColor, uint256 eyeSize, uint256 pupilSize) public pure returns (string memory){
        return _rightEye(scleraColor, eyeSize, pupilSize);
    }

    function buildCyclopseEye(string memory scleraColor, uint256 eyeSize, uint256 pupilSize) public pure returns(string memory){
        return _cyclopseEye(scleraColor, eyeSize, pupilSize);
    }

    /// @dev Combines _eye component with the non-cyclopse base for the left eye
    function _leftEye(string memory scleraColor, uint256 eyeSize, uint256 pupilSize)
        private
        pure
        returns (string memory)
    {
        return baseNonCyclopseLeft(string(abi.encodePacked(_eye(scleraColor, eyeSize, pupilSize))));
    }

    /// @dev Combines _eye component with the non-cyclopse base for the right eye
    function _rightEye(string memory scleraColor, uint256 eyeSize, uint256 pupilSize)
        private
        pure
        returns (string memory)
    {
        return baseNonCyclopseRight(string(abi.encodePacked(_eye(scleraColor, eyeSize, pupilSize))));
    }

    /// @dev Combines _eye component with the cyclopse base
    function _cyclopseEye(string memory scleraColor, uint256 eyeSize, uint256 pupilSize)
        private
        pure
        returns (string memory)
    {
        return baseCyclopse(string(abi.encodePacked(_eye(scleraColor, eyeSize, pupilSize))));
    }

    /// @dev The dynamic eye component for all eye types
    function _eye(string memory scleraColor, uint256 eyeSize, uint256 pupilSize) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<circle r="',
                eyeSize,
                '" cx="0" cy="0" stroke-width="2" stroke="#000000" fill="#',
                scleraColor,
                '"></circle>',
                '<circle r="',
                pupilSize,
                '" cx="0" cy="0" fill="#000000"></circle>'
            )
        );
    }

    /// @dev The base SVG for the non-cyclopse left eye
    function baseNonCyclopseLeft(string memory children) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<g id="eye-left" transform="matrix(1,0,0,1,179.5,200)">',
                children, 
                "</g>"
            )
        );
    }

    /// @dev The base SVG for the non-cyclopse right eye
    function baseNonCyclopseRight(string memory children) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<g id="eye-right" transform="matrix(1,0,0,1,220.5,200)">',
                children, 
                "</g>"
            )
        );
    }

     /// @dev The base SVG for the cyclopse eye
    function baseCyclopse(string memory children) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<g id="cyclopse" transform="matrix(1,0,0,1,200,190)">',
                children, 
                "</g>"
            )
        );
    }
}