// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

// Created by Dannithomx
/**
    !Disclaimer!
    please review this code on your own before using any of
    the following code for production.
    Dannithomx will not be liable in any way if for the use 
    of the code. That being said, the code has been tested 
    to the best of the developers' knowledge to work as intended.
*/

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";
import "./interfaces/IPublicLockV13.sol";
import "./interfaces/ILevels.sol";
// import "./interfaces/IGooglyBlobs.sol";
// import "./libraries//ToColor.sol";
import "./libraries/parts/Body.sol";
import "./libraries/parts/Mouth.sol";
import "./constants/Colors.sol";
import "./libraries/NFTDescriptor.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
  @title GooglyBlobs NFT Contract
  @author Danny Thomx
  @notice Explain to an end user what this does
  @dev Explain to a developer any extra details
*/

interface IColors {
	function getEyeColor(
		uint256 _id
	) external view returns (string memory name, string memory color);

	function getBodyColor(
		uint256 _id
	) external view returns (string memory name, string memory color);
}

// contract GooglyBlobs is ERC721Enumerable,IGooglyBlob, IERC721Receiver, Ownable {
contract GooglyBlobs is
	ERC721Enumerable,
	Ownable,
	ReentrancyGuard,
	VRFConsumerBaseV2
{
	using Address for address;
	using Strings for uint256;
	using Strings for uint160;
	using Counters for Counters.Counter;

	ILevels public LevelsFactory;
	IColors Colors;
	uint256 public maxSupply = 5000;
	uint256 public constant MAX_OWNER_FREE_MINT = 100; // Owner can mint 100 for free
	uint256 ownerFreeMintCount = 0;
	uint256 public price = 0.02 ether;
	address constant dev = 0xCA7632327567796e51920F6b16373e92c7823854;
	Counters.Counter private _tokenIdCounter;
	bool public isLevelsFactorySet;
	uint256 constant EYEBAG_THRESHOLD = 30;
	uint256 constant CYCLOPS_THRESHOLD = 90;

	// Chainlink VRF Variables
	VRFCoordinatorV2Interface immutable COORDINATOR;
	uint64 immutable s_subscriptionId;
	bytes32 immutable keyHash;
	uint32 constant callbackGasLimit = 60000;
	uint16 constant REQUEST_CONFIRMATIONS = 3;
	uint32 constant NUM_WORDS = 1;

	mapping(uint256 => uint256) tokenIdTolevel;
	mapping(uint256 => NFTDescriptor.SVGParams) tokenIdToTraits;
	mapping(address => mapping(uint256 => bool)) private unlockedLevels;
	mapping(uint256 => address) public s_requestIdToSender; // Tracks VRF requests to requester

	// Events
	event NftRequested(uint256 indexed requestId, address requester);
	event NftMinted(uint256 _tokenId, address minter);
	/**
	 * @dev Emitted when `holder` levels up NFT with tokenId of `tokenId`.
	 */
	event LevelUp(
		address levelLock,
		uint256 indexed tokenId,
		uint256 indexed newLevel
	);

	constructor(
		uint64 _subscriptionId,
		bytes32 _keyHash,
		address _VRFCoordinator,
		address _colors
	) ERC721("GooglyBlobs", "BLOB") VRFConsumerBaseV2(_VRFCoordinator) {
		COORDINATOR = VRFCoordinatorV2Interface(_VRFCoordinator);
		s_subscriptionId = _subscriptionId;
        keyHash = _keyHash;
		Colors = IColors(_colors);
		_tokenIdCounter.increment();
	}

	receive() external payable {}

	function _levelUp(uint256 _tokenId) private returns (uint256) {
		uint256 currentLevel = tokenIdTolevel[_tokenId];
		uint256 newLevel = currentLevel + 1;
		tokenIdTolevel[_tokenId] = newLevel;
		return newLevel;
	}

	// @dev To get the level of an nft
	function getLevel(uint256 _tokenId) public view returns (uint256) {
		require(_exists(_tokenId), "Non existent token");
		return tokenIdTolevel[_tokenId];
	}

	// @dev To level up an nft
	function levelUp(
		IPublicLockV13 _levelLock,
		uint256 _tokenId
	) public nonReentrant returns (uint256) {
		require(_exists(_tokenId), "Nonexistent token");
		require(address(LevelsFactory) != address(0), "LevelsFactory not set");
		require(msg.sender == ownerOf(_tokenId), "Not owner");
		address levelLockAddress = address(_levelLock);
		uint256 currentLevel = tokenIdTolevel[_tokenId];
		uint256 levelUpRange = LevelsFactory.getLevelUpRange();
		uint256 minAllowedLevel = LevelsFactory
			.getLevelData(levelLockAddress)
			.minAllowedLevel;
		require(LevelsFactory.isLevel(levelLockAddress), "Nonexistent level");
		require(_hasValidKey(msg.sender, levelLockAddress), "No valid key");
		require(currentLevel >= minAllowedLevel, "Meet the minimum level");
		require(
			currentLevel <= (minAllowedLevel + levelUpRange),
			"Not within levelUp range"
		);
		require(
			unlockedLevels[levelLockAddress][_tokenId] == false,
			"Already unlocked"
		);

		if (msg.sender != owner()) {
			require(
				msg.sender !=
					LevelsFactory.getLevelData(levelLockAddress).creator,
				"level created by you"
			);
		}

		uint256 newLevel = _levelUp(_tokenId);

		emit LevelUp(levelLockAddress, _tokenId, newLevel);
		return newLevel;
	}

	// @notice sets publicLock to a specific lock address which is used to create levelsFactory for GooglyBlob community
	function setLevelsFactory(ILevels _LevelsAddress) external onlyOwner {
		LevelsFactory = _LevelsAddress;
		isLevelsFactorySet = true;
	}

	function _hasValidKey(
		address _account,
		address _lockAddress
	) private view returns (bool) {
		IPublicLockV13 lock = IPublicLockV13(_lockAddress);
		bool hasKey = lock.getHasValidKey(_account);
		return hasKey;
	}

	// @notice Mint single nft
	function requestNft() public payable returns (uint256 requestId) {
		uint256 supply = totalSupply();
		require(supply < maxSupply, "Minting over");

		if (msg.sender != owner()) {
			require(msg.value >= price, "Insufficient ETH");
		}
		if (msg.sender == owner() && ownerFreeMintCount > MAX_OWNER_FREE_MINT) {
			require(msg.value >= price, "FreeMint Over");
		} else if (msg.sender == owner()) {
			ownerFreeMintCount++;
		}
		requestId = COORDINATOR.requestRandomWords(
			keyHash,
			s_subscriptionId,
			REQUEST_CONFIRMATIONS,
			callbackGasLimit,
			NUM_WORDS
		);

		s_requestIdToSender[requestId] = msg.sender;
		emit NftRequested(requestId, msg.sender);
	}

	// Fulfill Chainlink Randomness Request
	function fulfillRandomWords(
		uint256 requestId,
		uint256[] memory randomWords
	) internal override {
		address nftOwner = s_requestIdToSender[requestId];
		uint256 mintedTokenId = _tokenIdCounter.current();
		_tokenIdCounter.increment();
		// generate minted token traits
        NFTDescriptor.SVGParams memory traits = _generateTrait(mintedTokenId, nftOwner, randomWords);
        tokenIdToTraits[mintedTokenId] = traits;
		_safeMint(nftOwner, mintedTokenId);
		emit NftMinted(mintedTokenId, nftOwner);
	}

    function _generateTrait(uint256 _tokenId, address owner, uint256[] memory randomWords)internal view returns (NFTDescriptor.SVGParams memory) {
        uint256 bodyId = _getRandomNumberWithinRange(randomWords, 1, 12);
		string memory bodyName = BodyDetail.getBodyTypeNameByIndex(bodyId);
		(string memory bodyColorName, string memory bodyColor) = Colors
			.getBodyColor(_getRandomNumberWithinRange(randomWords, 1, 36));
		(string memory eyeColorName, string memory eyeColor) = Colors
			.getEyeColor(_getRandomNumberWithinRange(randomWords, 1, 4));
		bool isCyclops = _isCyclops(
			_getRandomNumberWithinRange(randomWords, 1, 100)
		);
		bool hasEyebag = _hasEyebag(isCyclops, randomWords);
        uint256 eyeSize = _calculateEyeSize(isCyclops, randomWords);
        uint256 pupilSize = _calculatePupilSize(isCyclops, randomWords);
		uint256 mouthId = _getRandomNumberWithinRange(randomWords, 1, 4);
		string memory mouthName = MouthDetail.getMouthTypeNameByIndex(mouthId);
        uint256 level = tokenIdTolevel[_tokenId];
        NFTDescriptor.SVGParams memory traits = NFTDescriptor.SVGParams({
         bodyId: bodyId,
		 bodyName:bodyName,
		 bodyColor:bodyColor,
		 bodyColorName:bodyColorName,
		 isCyclops: isCyclops,
		 eyeColor: eyeColor,
		 eyeColorName: eyeColorName,
		 eyeSize: eyeSize,
		 pupilSize: pupilSize,
		 hasEyebag: hasEyebag,
		 mouthId: mouthId,
		 mouthName:mouthName,
		 level: level,
		 owner: owner
         });
        return traits;
    }

	function _isCyclops(uint256 _gene) private pure returns (bool) {
		return _gene >= CYCLOPS_THRESHOLD;
	}

	function _hasEyebag(
		bool isCyclops,
		uint256[] memory _randomWords
	) internal pure returns (bool) {
		uint256 gene = _getRandomNumberWithinRange(_randomWords, 1, 50);
		return !isCyclops && gene >= EYEBAG_THRESHOLD;
	}

    function _calculateEyeSize(bool isCyclops, uint256[] memory randomWords) internal pure returns(uint256) {
        if(isCyclops){
            return _getRandomNumberWithinRange(randomWords, 15, 22);
        }
        return _getRandomNumberWithinRange(randomWords, 14, 18);
    }

    function _calculatePupilSize(bool isCyclops, uint256[] memory randomWords) internal pure returns(uint256) {
        if(isCyclops){
            return _getRandomNumberWithinRange(randomWords, 7, 11);
        }
        return _getRandomNumberWithinRange(randomWords, 7, 9);
    }

	function _getRandomNumberWithinRange(
		uint256[] memory _randomWords,
		uint256 minValue,
		uint256 maxValue
	) internal pure returns (uint256) {
		uint256 range = maxValue - minValue + 1;
		return (_randomWords[0] % range) + minValue;
	}

	function tokenURI(
		uint256 id
	) public view override returns (string memory _tokenURI) {
		require(_exists(id), "not exist");
		string memory name = string(abi.encodePacked("GooglyBlob #", id.toString()));
		NFTDescriptor.SVGParams memory _svgParams = tokenIdToTraits[id];
		string memory image = Base64.encode(
			bytes(NFTDescriptor.generateSVGImage(_svgParams))
		);
		string memory description = NFTDescriptor.generateDescription(
			_svgParams
		);
		string memory attributes = NFTDescriptor.generateAttributes(_svgParams);
		_tokenURI = string(
			abi.encodePacked(
				"data:application/json;base64,",
				Base64.encode(
					bytes(
						abi.encodePacked(
							'{"name":"',
							name,
							'", "description":"',
							description,
							'", "external_url":"https://burnyboys.com/token/',
							id.toString(),
							'", "attributes": "',
							attributes,
							'", "image": "',
							"data:image/svg+xml;base64,",
							image,
							'"}'
						)
					)
				)
			)
		);
		return _tokenURI;
	}

	function getOwnerFreeMintCount()
		public
		view
		onlyOwner
		returns (uint256 minted)
	{
		minted = ownerFreeMintCount;
	}

	function withdraw() public payable onlyOwner {
		address buidlguidl = 0x97843608a00e2bbc75ab0C1911387E002565DEDE;
		(bool bg, ) = payable(buidlguidl).call{
			value: (address(this).balance * 20) / 100
		}("");
		require(bg);

		// This will payout the dev the rest of the initial Revenue.
		(bool d, ) = payable(dev).call{ value: address(this).balance }("");
		require(d);
	}
}
