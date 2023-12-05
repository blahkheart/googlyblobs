// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

pragma abicoder v2;

/// @title Mouth SVG generator
library MouthDetail {
    uint256 constant public mouthTypeCount = 4;

    function buildMouth(uint256 _id)pure public returns(string memory){
        return  _selectMouthById( _id);
    }

    function getMouthTypeNameByIndex(uint256 _id)pure public returns(string memory){
        string[] memory names = new string[](12);
        string memory _mouthTypeName;
        names[0] = "Goober Gasp";
        names[1] = "TongueTease Giggle";
        names[2] = "Deadpan Pucker";
        names[3] = "Startled SquishGoo";
        require(_id > 0 && _id <= names.length, "Invalid Id");
        for(uint i =0; i < names.length; i++){
        // [i + 1] causes index to start from 1 and not 0
            if(_id == (i+1)) 
            _mouthTypeName = names[i];
        }
        return _mouthTypeName;
    }

    /// @dev Selects a mouth type based on number (_id) provided
    function _selectMouthById(uint256 _id)
        private
        pure
        returns (string memory)
    {
        require(_id > 0 && _id <= 4, "Invalid Id");
        if(_id == 1) return base(string(abi.encodePacked(_mouth_1())));
        if(_id == 2) return base(string(abi.encodePacked(_mouth_2())));
        if(_id == 3) return base(string(abi.encodePacked(_mouth_3())));
        return base(string(abi.encodePacked(_mouth_4())));
    }

    function _mouth_1() private pure returns (string memory) {
        return string(
            abi.encodePacked(
               '<ellipse fill="#000" stroke-width="1" cx="200" cy="240" id="svg_mouth" rx="11.5" ry="7.875" stroke="#000"/>',
               '<ellipse fill="#FFC0CB" cx="200" cy="245" rx="8.75" id="svg_tongue" ry="2.9375" />'
            )
        );
    }

    function _mouth_2() private pure returns (string memory) {
        return string(
            abi.encodePacked(
               '<ellipse fill="#000" stroke-width="1" cx="200" cy="240" id="svg_mouth" rx="11.5" ry="7.875" stroke="#000"/>',
               '<ellipse xmlns="http://www.w3.org/2000/svg" fill="#FFC0CB" cx="200" cy="249" rx="8.7" id="svg_tongue" ry="11.9375"/>',
               '<line xmlns="http://www.w3.org/2000/svg" x1="192.5" y1="213" x2="193.5" y2="224" id="svg_tongue_line" stroke="#000" stroke-width="1" transform="rotate(7, -61, 291)"/>'
            )
        );
    }

    function _mouth_3() private pure returns (string memory) {
        return string(
            abi.encodePacked(
               '<ellipse xmlns="http://www.w3.org/2000/svg" fill="#000" stroke-width="1" cx="200" cy="240" id="svg_mouth" rx="11.5" ry="2" stroke="#000"/>'
            )
        );
    }

    function _mouth_4() private pure returns (string memory) {
        return string(
            abi.encodePacked(
               '<ellipse xmlns="http://www.w3.org/2000/svg" fill="#000" stroke-width="1" cx="200" cy="251" id="svg_mouth" rx="11.5" ry="7.875" stroke="#000"/>',
               '<ellipse xmlns="http://www.w3.org/2000/svg" fill="#FFC0CB" cx="200" cy="256" rx="8.75" id="svg_tongue" ry="2.9375"/>'
            )
        );
    }

    /// @dev The base SVG for the mouth
    function base(string memory children) private pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<g id="mouth">', children, "</g>"
            )
        );
    }
}