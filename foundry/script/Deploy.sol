pragma solidity ^0.8.17;

import "hop_poc/plonk_vk.sol";
import "../src/OptimismVerifier.sol";
import {Script, console} from "forge-std/Script.sol";

contract Deploy is Script {
    OptimismVerifier public wrapper;
    UltraVerifier public verifier;
    DummyOptimismBlockhashOracle oracle;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        verifier = new UltraVerifier();
        oracle = new DummyOptimismBlockhashOracle();
        wrapper = new OptimismVerifier(verifier, oracle);

        console.log("oracle", address(oracle));
        console.log("wrapper verifier", address(verifier));
        console.log("generated verifier", address(generatedVerifier));

        vm.stopBroadcast();
    }
}
