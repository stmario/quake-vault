//TODO: switch to Moralis, testnet RPC: https://rinkeby.infura.io/v3/8ee4348a5d474bd283db31954ccc4531
function getNetworkStrings(chainId: number) {
    const networks = {
        1: {name: "Ethereum Mainnet", symbol: "ETH", defaultRpc: "https://mainnet.infura.io/v3/"},
        250: {name: "Fantom Opera", symbol: "FTM", defaultRpc: "https://rpc.ftm.tools/"},
        4002: {name: "Fantom Testnet", symbol: "FTM", defaultRpc: "https://rpc.testnet.fantom.network/"}
    };
    return networks[chainId as keyof typeof networks]
}

function getContractAddress(chainId: number, symbol: string){
    const addresses: {[cId: number]: {[symb: string]: string}} = {
        4002: {"LINK": "0xfaFedb041c0DD4fA2Dc0d87a6B0979Ee6FA7af5F"}
    };
    return addresses[chainId as keyof typeof addresses][symbol]
}

export {getNetworkStrings, getContractAddress}
