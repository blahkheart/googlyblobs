// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

pragma abicoder v2;

contract Colors {
    mapping(uint256 => string) bodyColorIdToName;
    mapping(uint256 => string) bodyColorIdToCode;
    mapping(uint256 => string) eyeColorIdToName;
    mapping(uint256 => string) eyeColorIdToCode;

    string[] eyeColorNames = [
        "White",		
        "WhiteSmoke",
        "Old Lace",
        "Snow"
    ];

    string[] eyeColorCodes = [
        "FFFFFF",		
        "F5F5F5",
        "FDF5E6",
        "FFFAFA"
    ];

    string[] bodyColorNames = [
        "Aqua",		
        "BurlyWood",
        "Coral",		 
        "Crimson",	  
        "DarkMagenta",	 
        "DarkOrchid",	 
        "DarkSlateBlue",	 
        "DarkSlateGrey",
        "DeepPink",
        "DimGrey",
        "DodgerBlue",	 
        "FireBrick",	 
        "Fuchsia",
        "Gold",
        "GoldenRod",
        "HotPink",
        "IndianRed",
        "Indigo",
        "Khaki",
        "Lime",
        "Magenta",
        "Maroon",
        "MidnightBlue",
        "NavajoWhite", 
        "OliveDrab",
        "RebeccaPurple", 
        "Red",
        "RoyalBlue",
        "SaddleBrown",
        "SeaGreen",
        "Sienna",
        "Silver",
        "SteelBlue",
        "Teal",
        "Tomato",
        "Yellow"		
    ];

    string[] bodyColorCodes = [
        "00FFFF",		
        "DEB887",
        "FF7F50",		 
        "DC143C",	  
        "8B008B",	 
        "9932CC",	 
        "483D8B",	 
        "2F4F4F",
        "FF1493",
        "696969",
        "1E90FF",	 
        "B22222",	 
        "FF00FF",
        "FFD700",
        "DAA520",
        "FF69B4",
        "CD5C5C",
        "4B0082",
        "F0E68C",
        "00FF00",
        "FF00FF",
        "800000",
        "191970",
        "FFDEAD", 
        "6B8E23",
        "663399", 
        "FF0000",
        "4169E1",
        "8B4513",
        "2E8B57",
        "A0522D",
        "C0C0C0",
        "4682B4",
        "008080",
        "FF6347",
        "FFFF00"		
    ];

    constructor() {
        _initializeColors();
    }

    function _initializeColors() private {
        // [i + 1] causes index to start from 1 and not 0
        for (uint256 i = 0; i < bodyColorNames.length; i++) {
            bodyColorIdToName[i+1] = bodyColorNames[i];
            bodyColorIdToCode[i+1] = bodyColorCodes[i];
        }
        for(uint256 i = 0; i < eyeColorNames.length; i++){
            eyeColorIdToName[i+1] = eyeColorNames[i];
            eyeColorIdToCode[i+1] = eyeColorCodes[i];
        }
    }

    function getEyeColor(uint256 _id)view external returns (string memory name, string memory color){
        require(_id <= eyeColorsCount(), "Invalid Id");
        name = eyeColorIdToName[_id];
        color = eyeColorIdToCode[_id];
    }

    function getBodyColor(uint256 _id)view external returns (string memory name, string memory color){
        require(_id <= bodyColorsCount(), "Invalid Id");
        name = bodyColorIdToName[_id];
        color = bodyColorIdToCode[_id];
    }

    function bodyColorsCount()view public returns (uint256 colorCount){
        colorCount = bodyColorCodes.length;
    }
    
    function eyeColorsCount()view public returns (uint256 colorCount){
        colorCount = eyeColorCodes.length;
    }
}