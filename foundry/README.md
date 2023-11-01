# noir-hop-poc
Foundry project interacting with zk verifier for the HOP PoC

# OptimismVerifier
- calls UltraVerifier for ZK proof
- validates that the proof supplied is for the correct block number, slot, value and account

# DummyOptimismBlockhashOracle
- holds a mapping from block number to block hash on optimism goerli network

# DummyOptimi

## Usage
- set up .env
- deploy using:
```
forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --ffi --broadcast -vvvv --verify
```
### Build

```shell
$ forge build
```

### Test

```shell
$ forge test --ffi -vvv
```