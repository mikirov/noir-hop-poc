// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin/access/Ownable.sol";

/// @title Interface for Blockhash Oracle
/// @author LimeChain team
interface IBlockhashOracle {
    /// @notice Fetches the blockhash for a given block number
    /// @param blockNumber The number of the block whose hash is required
    /// @return The blockhash of the specified block
    function getBlockhash(uint256 blockNumber) external view returns (bytes32);
}

/// @title A dummy blockhash oracle for the Optimism network
/// @author LimeChain team
/// @dev This is a mock implementation for testing purposes
contract DummyOptimismBlockhashOracle is Ownable, IBlockhashOracle {
    /// @dev Mapping of block numbers to their corresponding blockhashes
    mapping(uint256 => bytes32) blockNumberToBlockhash;

    /// @notice Fetches the blockhash for a given block number
    /// @param blockNumber The number of the block whose hash is required
    /// @return The blockhash of the specified block
    function getBlockhash(uint256 blockNumber) external view override returns (bytes32) {
        return blockNumberToBlockhash[blockNumber];
    }

    /// @notice Allows the owner to set the blockhash for a specific block number
    /// @param blockNumber The number of the block for which to set the hash
    /// @param hash The hash value to set for the specified block number
    function setBlockhash(uint256 blockNumber, bytes32 hash) external onlyOwner {
        blockNumberToBlockhash[blockNumber] = hash;
    }
}
