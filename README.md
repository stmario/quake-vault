# quake-vault

Install the Ionic CLI

Before proceeding, make sure your computer has Node.js installed. See these instructions to set up an environment for Ionic.

Install the Ionic CLI with npm:
```console
npm install -g @ionic/cli
```

Run the PWA:
```console
cd quake-vault
ionic serve
```

# smart contract

First install the requirements:
```console
cd src/smartcontract/lib
git clone https://github.com/OpenZeppelin/openzeppelin-contracts.git
git clone https://github.com/smartcontractkit/chainlink.git
curl -L https://foundry.paradigm.xyz | bash
foundryup
forge install foundry-rs/forge-std
```

Store your Rinkeby RPC url in the variable ETH_RINKEBY_RPC.
Run tests with:
```console
forge test --fork-url $ETH_RINKEBY_RPC -vvvv
```
