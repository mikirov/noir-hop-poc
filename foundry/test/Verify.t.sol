pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "hop_poc/plonk_vk.sol";
import {console} from "forge-std/Script.sol";
import { DummyOptimismBlockhashOracle } from "../src/DummyOptimismBlockhashOracle.sol";
import { OptimismVerifier } from "../src/OptimismVerifier.sol";

contract VerifyTest is Test{

    OptimismVerifier wrapper;
    UltraVerifier verifier;
    DummyOptimismBlockhashOracle oracle;

    uint8 constant PUBLIC_INPUT_COUNT = 186;

    function setUp() public {
        verifier = new UltraVerifier();
        oracle = new DummyOptimismBlockhashOracle();
        wrapper = new OptimismVerifier(address(oracle), address(verifier));
    }

    function test_verify() public {
        // we are verifying the total supply of an ERC20 on optimism at given block number
        // uint256 blockNumber = 16717551;
        // bytes32 blockHash = bytes32(0xb637c466207e6ed1021d5ec8a0bacc2ffb089a02ddb584206f675dd25be6372b);
        // oracle.setBlockhash(blockNumber, blockHash); // we are going to do that from the REST API in the future

        // address account = 0x32307adfFE088e383AFAa721b06436aDaBA47DBE; // OptimismUselessToken ERC20
        // bytes32 slot = bytes32(uint256(2)); // totalSupply
        // uint256 value = 102000000000000000000000; // 102000 ether


        //TODO: the part below  can be extracted in the wrapper verifier contract, however we would need to supply the method with account_value(nonce, balance, storage hash, code_hash)

        //HACK: this comes from the Prover.toml of the circuits
        uint8[20] memory accountKey = [50, 48, 122, 223, 254, 8, 142, 56, 58, 250, 167, 33, 176, 100, 54, 173, 171, 164, 125, 190];
        uint8[70] memory accountValue = [248, 68, 1, 128, 160, 146, 18, 189, 229, 2, 21, 45, 131, 245, 14, 245, 173, 166, 104, 47, 100, 161, 133, 71, 5, 195, 237, 66, 75, 63, 241, 145, 7, 35, 198, 34, 119, 160, 39, 152, 110, 23, 161, 245, 146, 134, 213, 189, 219, 69, 160, 225, 171, 67, 77, 94, 143, 124, 137, 35, 209, 53, 83, 244, 92, 51, 8, 172, 232, 220];
        uint8[32] memory blockHash = [182, 55, 196, 102, 32, 126, 110, 209, 2, 29, 94, 200, 160, 186, 204, 47, 251, 8, 154, 2, 221, 181, 132, 32, 111, 103, 93, 210, 91, 230, 55, 43];
        uint8[32] memory storageKey = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2];
        uint8[32] memory storageValue = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 21, 153, 110, 91, 60, 214, 179, 192, 0, 0];

        bytes32[] memory publicInputs = new bytes32[](186);
        // convert address to 20 bytes32 values for prover
        //bytes20 accountBytes = bytes20(account);

        for(uint i = 0; i < 32; i++) {
            publicInputs[i] = bytes32(uint256(blockHash[i]));
        }

        for(uint i = 0; i < 20; i++)
        {
            publicInputs[i + 32] = bytes32(uint256(accountKey[i]));
        }
        // convert account_value(nonce, balance, storage hash, code_hash) to 70 bytes32 values for prover
        for(uint i = 0; i < 70; i++)
        {
            publicInputs[52 + i] = bytes32(uint256(accountValue[i]));
        }

        //simulate fetching block hash
        //bytes32 fetchedBlockHash = oracle.getBlockhash(blockNumber);

        for(uint i = 0; i < 32; i++) {
            publicInputs[122 + i] = bytes32(uint256(storageKey[i]));
        }
        // convert value to 32 bytes32 values for prover
        for(uint i = 0; i < 32; i++) {
            publicInputs[154 + i] = bytes32(uint256(storageValue[i]));
        }

        string memory proof = vm.readLine("./circuits/proofs/hop_poc.proof");
        bytes memory proofBytes = vm.parseBytes(proof);
        wrapper.verify(proofBytes, publicInputs);
    }
}
