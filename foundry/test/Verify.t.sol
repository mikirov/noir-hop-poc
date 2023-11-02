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
        uint256 blockNumber = 16717551;
        bytes32 blockHash = bytes32(0xb637c466207e6ed1021d5ec8a0bacc2ffb089a02ddb584206f675dd25be6372b);
        oracle.setBlockhash(blockNumber, blockHash); // we are going to do that from the REST API in the future

        address account = 0x32307adfFE088e383AFAa721b06436aDaBA47DBE; // OptimismUselessToken ERC20
        bytes32 slot = bytes32(uint256(2)); // totalSupply
        uint256 value = 102000000000000000000000; // 102000 ether

        string memory proof = vm.readLine("./circuits/proofs/hop_poc.proof");
        bytes memory proofBytes = vm.parseBytes(proof);

        wrapper.verify(proofBytes, );
    }
}
