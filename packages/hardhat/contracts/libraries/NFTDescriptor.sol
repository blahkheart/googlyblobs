//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

pragma abicoder v2;

import "@openzeppelin/contracts/utils/Strings.sol";
// import "./parts/constants/Colors.sol";
import "./parts/Eyes.sol";
import "./parts/Eyebag.sol";
import "./parts/Body.sol";
import "./parts/Mouth.sol";
import "./parts/LevelDetail.sol";

/// @notice Helper to generate SVGs
library NFTDescriptor {
	using Strings for uint256;
	using Strings for uint160;

	struct SVGParams {
		uint256 bodyId;
		string bodyName;
		string bodyColor;
		string bodyColorName;
		bool isCyclops;
		string eyeColor;
		string eyeColorName;
		uint256 eyeSize;
		uint256 pupilSize;
		bool hasEyebag;
		uint256 mouthId;
		string mouthName;
		uint256 level;
		address owner;
	}

	/// @dev generate SVG header
	function generateSVGHead() private pure returns (string memory) {
		return
			string(
				abi.encodePacked(
					'<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">'
				)
			);
	}

	// function generateSVGImage(SVGParams memory _svgParams) public pure returns (string memory svg) {
	function generateSVGImage(
		SVGParams memory _svgParams
	) internal pure returns (string memory svg) {
		bool isCyclops = _svgParams.isCyclops;
		if (isCyclops) {
			return
				string(
					abi.encodePacked(
						generateSVGHead(),
						BodyDetail.buildBody(
							_svgParams.bodyId,
							_svgParams.bodyColor
						),
						EyesDetail.buildCyclopseEye(
							_svgParams.eyeColor,
							_svgParams.eyeSize,
							_svgParams.pupilSize
						),
						MouthDetail.buildMouth(_svgParams.mouthId),
						LevelDetail.buildLevel(_svgParams.level),
						"</svg>"
					)
				);
		}
		return
			string(
				abi.encodePacked(
					generateSVGHead(),
					BodyDetail.buildBody(
						_svgParams.bodyId,
						_svgParams.bodyColor
					),
					EyesDetail.buildLeftEye(
						_svgParams.eyeColor,
						_svgParams.eyeSize,
						_svgParams.pupilSize
					),
					EyesDetail.buildRightEye(
						_svgParams.eyeColor,
						_svgParams.eyeSize,
						_svgParams.pupilSize
					),
					EyebagDetail.buildEyebag(_svgParams.hasEyebag),
					MouthDetail.buildMouth(_svgParams.mouthId),
					LevelDetail.buildLevel(_svgParams.level),
					"</svg>"
				)
			);
	}

	/// @dev generate Json Metadata description
	function generateDescription(
		SVGParams memory params
	) internal pure returns (string memory) {
		return
			string(
				abi.encodePacked(
					"This is a level #",
					params.level.toString(),
					" GooglyBlob with a ",
					params.bodyName,
					" body, and the ",
					params.mouthName,
					" mouth."
				)
			);
	}

	/// @dev generate Json Metadata attributes
	function generateAttributes(
		SVGParams memory _svgParams
	) internal pure returns (string memory) {
		return
			string(
				abi.encodePacked(
					"[",
					getJsonAttribute("Body", _svgParams.bodyName, false),
					getJsonAttribute(
						"Level",
						_svgParams.level.toString(),
						false
					),
					abi.encodePacked(
						getJsonAttribute(
							"Color",
							_svgParams.bodyColorName,
							false
						),
						getJsonAttribute(
							"Sclera Color",
							_svgParams.eyeColorName,
							false
						),
						getJsonAttribute("Mouth", _svgParams.mouthName, false),
						getJsonAttribute(
							"Owner",
							uint160(_svgParams.owner).toHexString(20),
							true
						),
						"]"
					)
				)
			);
	}

	/// @dev Get the json attribute as
	///    {
	///      "trait_type": "Skin",
	///      "value": "Human"
	///    }
	function getJsonAttribute(
		string memory trait,
		string memory value,
		bool end
	) private pure returns (string memory json) {
		return
			string(
				abi.encodePacked(
					'{ "trait_type" : "',
					trait,
					'", "value" : "',
					value,
					'" }',
					end ? "" : ","
				)
			);
	}
}
