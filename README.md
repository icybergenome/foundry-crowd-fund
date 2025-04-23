## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Install package

```shell
$ forge install smartcontractkit/chainlink-brownie-contracts --no-commit 
# install from github and check the lib folder and remapping in `foundry.toml`
```


### Test

```shell
$ forge test -vvv # -vvv for verbose output number of v(s) corresponds to the verbosity level
$ forge test --match-test <test name> -vvv --fork-url <rpc url testnet>
$ forge coverage --fork-url <rpc url testnet>
```

### Gas Snapshots

```shell
$ forge snapshot
$ forge snapshot -m <test name>
```

### Inspect

```shell
$ forge inspect FundMe storageLayout
$ cast storage <contract address> <storage_slot>
```

### Deployment steps

```shell
$ forge build
$ forge build --zksync # for zkSync build, output folder will be zkout
$ forge create SimpleStorage --interactive
$ # Using .env approach which is not recommended for production
$ source .env
$ forge script script/DeployFundMe.s.sol --rpc-url $RPC_URL --broadcast --private-key $PRIVATE_KEY
$ # Using keystore approach
$ cast wallet import devKey --interactive
$ cast wallet list # to list the wallets
$ forge script script/DeployFundMe.s.sol --rpc-url $RPC_URL --account devKey --sender 0x00_associated_public_address --broadcast
$ # for zkSync deployment
$ forge create src/SimpleStorage.sol:SimpleStorage --rpc-url $RPC_URL --account devKey --sender 0x00_associated_public_address --zksync --legacy
```

### Scripts

```shell
$ forge script script/DeployFundMe.s.sol --rpc-url $RPC_URL --account devKey --sender 0x00_associated_public_address --broadcast
$ forge script script/Interactions.s.sol:fundFundMe --rpc-url $RPC_URL --account devKey --sender 0x00_associated_public_address --broadcast
```
### Gas Optimization
* immutable, constant and memory variables are not saved in storage hence they are cheaper
* storage variables are more expensive
* private variable are more gas optimized but doesn't mean they are really private.
* When contract is complied bytecode is generated and opcodes are generated as well
* opcodes represent the gas cost each opcode will cost