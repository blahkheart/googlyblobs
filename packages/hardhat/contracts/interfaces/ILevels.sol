// SPDX-License-Identifier: MIT
pragma solidity >=0.5.17 <0.9.0;
pragma experimental ABIEncoderV2;

/**
 * @title The Levels Interface
 */

interface ILevels {

    /**  
    * @dev Struct to store the level to the be unlocked's information 
    * @param lockAddress The address of the lock representing the level to be unlocked
    * @param initialized Boolean that indicates whether or not a level is created
    * @param minAllowedLevel The minimum level an NFT must reach in order to unlock the level
    * @param creator The address of the level creator
    */
    struct LevelData {
        address lockAddress;
        bool initialized;
        uint minAllowedLevel;
        address creator;
    }

  /**
   * @notice Gets the number of levels an NFT's current level must fall 
   * within to level up with a specific level
   * @return levelUpRange
   */
  function getLevelUpRange() external view returns (uint64 levelUpRange);

  /**
   * @dev getLevelData function
   * @notice gets information for a specific level
   * @param _levelAddress the address of the current level
   * @return _levelData the information of the specified level
   */
  function getLevelData(
    address _levelAddress
  ) external payable returns (LevelData memory _levelData);

  /**
   * @dev Checks whether an address is a level.
   * @param _levelAddress Address to be checked.
   * @return _isLevel boolean 
   */
  function isLevel(
    address _levelAddress
  ) external view returns (bool _isLevel);

}