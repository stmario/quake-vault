function getNetworkStrings(chainId: number) {
    const networks = {
        1: {name: "Ethereum Mainnet", symbol: "ETH"},
        250: {name: "Fantom Opera", symbol: "FTM"},
        4002: {name: "Fantom Testnet", symbol: "FTM"}
    };
    return networks[chainId as keyof typeof networks]
}

function getContractAddress(chainId: number, symbol: string){
    const addresses: {[cId: number]: {[symb: string]: string}} = {
        4002: {"LINK": "0xfaFedb041c0DD4fA2Dc0d87a6B0979Ee6FA7af5F"}
    };
    return addresses[chainId as keyof typeof addresses][symbol]
}

export const ftmTestnetRpc = "https://rpc.testnet.fantom.network/";

export const linkContractAddress = "0xfaFedb041c0DD4fA2Dc0d87a6B0979Ee6FA7af5F";

export {getNetworkStrings, getContractAddress}
