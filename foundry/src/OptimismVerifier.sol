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

    public constant PUBLIC_INPUT_COUNT = 186;

    /// @notice Attestations for account storage slots
    /// @dev A mapping from a hash to a boolean, signifying whether the account has value at a certain slot in a certain block
    mapping(uint256 => bool) public slotAttestations;

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
    /// @param _valueRLP RLP encoded (nonce, balance, storage hash, code hash)
    /// @param _blockNumber The block number to verify for
    function verify(bytes calldata _proof, address _account, bytes32 _slot, uint256 _slotValue, bytes _valueRLP, uint256 _blockNumber)
        external
    {
        bytes32[] memory publicInputs = new bytes32[](PUBLIC_INPUT_COUNT);

        // The layout of the public inputs can be found in circuits/Prover.toml. 
        // First we have 32 bytes32 values containing uint8 for the block hash
        // Second is the 20 bytes for address padded to bytes32
        // third is the RLP encoded account value (nonce, balance, storage hash, code hash)
        // fourth is the 32 uint8 byte values for the slot padded to bytes32

        bytes32 fetchedBlockHash = oracle.getBlockhash(blockNumber);
        for(uint i = 0; i < 32; i++) {
            publicInputs[i] = bytes32(uint256(blockHash[i]));
        }

        bytes20 accountBytes = bytes20(_account);
        for(uint i = 0; i < 20; i++)
        {
            publicInputs[i + 32] = bytes32(uint256(accountBytes[i]));
        }

        // TODO: RLP encode account value and turn to 70 bytes
        require(_valueRLP.length == 70, "RLP encoded account value must be 70 bytes");
        for(uint i = 0; i < 70; i++)
        {
            publicInputs[52 + i] = bytes32(uint256(_valueRLP[i]));
        }


        bytes32 slotBytes = bytes32(_slot);
        for(uint i = 0; i < 32; i++) {
            publicInputs[122 + i] = bytes32(uint256(slotBytes[i]));
        }

        bytes32 storageValueBytes = bytes32(_slotValue);
        for(uint i = 0; i < 32; i++) {
            publicInputs[154 + i] = bytes32(uint256(storageValueBytes[i]));
        }

        bool success = verifier.verify(proofBytes, publicInputs);
        require(success, "Verification failed");

        bytes memory data = abi.encodePacked(fetchedBlockhash, _account, _slot, _slotValue);
        slotAttestations[keccak256(data)] = true;

        emit SlotAttestationEvent(_blockNumber, _account, _slot, _slotValue);

    }
}
