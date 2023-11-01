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
    /// @param _publicInputs The public inputs for the verifier
    function verify(bytes calldata _proof, bytes32[] calldata _publicInputs)
        external
    {
        require(verifier.verify(_proof, _publicInputs), "Invalid proof");
        slotAttestations[keccack256(_publicInputs)] = true;
    }
}
