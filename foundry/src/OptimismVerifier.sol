// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IBlockhashOracle} from "./DummyOptimismBlockhashOracle.sol";
import "hop_poc/plonk_vk.sol";

/// @title Optimism Verifier Contract
/// @author LimeChain team
/// @dev Contract to verify proofs for account storage values
contract OptimismVerifier {
    /// @dev Instance of the blockhash oracle to fetch block hashes
    IBlockhashOracle oracle;

    /// @dev Address of the external verifier
    UltraVerifier verifier;

    uint8 constant public PUBLIC_INPUT_COUNT = 32;

    /// @notice Attestations for account storage slots
    /// @dev A mapping from a hash to a boolean, signifying whether the account has value at a certain slot in a certain block
    mapping(bytes32 => bool) public slotAttestations;

    /// @notice Event emitted when a slot attestation is made
    /// @param blockNumber The block number associated with the attestation
    /// @param account The account associated with the attestation
    /// @param slot The slot associated with the attestation
    /// @param slotValue The value in the slot
    event SlotAttestationEvent(uint256 blockNumber, address account, bytes32 slot, uint256 slotValue);


    /// @notice Constructs a new OptimismVerifier instance
    /// @param _oracle The address of the blockhash oracle contract
    /// @param _verifier The address of the external verifier
    constructor(address _oracle, address _verifier) {
        oracle = IBlockhashOracle(_oracle);
        verifier = UltraVerifier(_verifier);
    }

    /// @notice Verifies a proof for a specific account's storage slot value
    /// @dev Uses an external verifier and then compares with fetched data
    /// @param _proof The proof to verify
    /// @param _account The account to verify for
    /// @param _slot The slot to verify for
    /// @param _slotValue The slot value to verify for
    /// @param _blockNumber The block number to verify for
    function verify(bytes calldata _proof, address _account, bytes32 _slot, uint256 _slotValue, uint256 _blockNumber)
        external
    {
        bytes32[] memory publicInputs = new bytes32[](PUBLIC_INPUT_COUNT);

        // The layout of the public inputs can be found in circuits/Prover.toml. 
        bytes32 fetchedBlockHash = oracle.getBlockhash(_blockNumber);
        bytes32 publicInputHash = keccak256(abi.encodePacked(fetchedBlockHash, _account, _slot, _slotValue));

        for(uint i = 0; i < 32; i++) {
            publicInputs[i] = bytes32(uint256(uint8(publicInputHash[i])));
        }

        bool success = verifier.verify(_proof, publicInputs);
        require(success, "Verification failed");

        slotAttestations[publicInputHash] = true;

        emit SlotAttestationEvent(_blockNumber, _account, _slot, _slotValue);

    }
}
