# noir-mip

This project produce a generalized ZK based Merkle-Patricia tree inclusion proofs (MPTIP), proving storage slots in Ethereum Mainnet.
The first thing the circuit needs to do is prove that the stateRoot is part of the blockhash.
Then, it needs to prove that the storage slot is part of the stateRoot.
Finally, it needs to prove that the value in the storage slot is the expected value.

## Usage

### Prerequisites

- rustc 1.70.0 (90c541806 2023-05-31)
- nargo 0.17.0

### Environment variables

Set the following environment variables in `.env` file:

```bash
MAINNET_RPC= // Mainnet RPC endpoint
BLOCK_NUMBER= // Block number
TARGET_ACCOUNT= // Target account address
STORAGE_SLOT= // Target storage slot
```

Example:

```bash
MAINNET_RPC=https://opt-goerli.g.alchemy.com/v2/{api-key-here}
BLOCK_NUMBER=12965000
TARGET_ACCOUNT=dAC17F958D2ee523a2206206994597C13D831ec7
STORAGE_SLOT=0000000000000000000000000000000000000000000000000000000000000002
```

### Install

```bash
cargo build
```

### Generate prover configuration

```bash
cargo run gen_prove_params > Prover.toml
```

### Generate verifier configuration

```bash
cargo run gen_verify_params > Verifier.toml
```

### Generate proof

```bash
nargo prove
```

### Verify proof

```bash
nargo verify
```

## Test

```bash
nargo test
```