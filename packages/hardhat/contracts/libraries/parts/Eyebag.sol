// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

pragma abicoder v2;

/// @title Eyebag SVG generator
library Eyebag {

    function buildEyebag(bool _hasEyebag)pure public returns(string memory){
        string memory _eyebag_ = _getEyebagSVG();
        if(_hasEyebag != true) _eyebag_ = "";
        return _eyebag_;
    }

    /// @dev Combines Eyebag SVG component with the base SVG component
    function _getEyebagSVG()
        private
        pure
        returns (string memory)
    {
        return base(string(abi.encodePacked(_eyebag())));
    }

    function _eyebag() private pure returns (string memory) {
        return string(
            abi.encodePacked(
               '<line xmlns="http://www.w3.org/2000/svg" x1="190.5" y1="220" x2="205.5" y2="225" stroke="#000" stroke-width="1" transform="rotate(10, 220, 310)"/>',
               '<line xmlns="http://www.w3.org/2000/svg" x1="195" y1="234" x2="207.5" y2="225" stroke="#000" stroke-width="1" transform="rotate(5, 300, 50)"/>'
            )
        );
    }

    /// @dev The base SVG for the mouth
    function base(string memory children) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<g id="eyebag">', children, "</g>"
            )
        );
    }
}