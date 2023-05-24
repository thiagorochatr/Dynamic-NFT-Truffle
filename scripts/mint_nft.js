const dNFTS = artifacts.require("dNFTS");

module.exports = async function(callback) {
    const accounts = await web3.eth.getAccounts();
    const _instancedNFTs = await dNFTS.deployed();
    try {
        await _instancedNFTs.safeMint(accounts[0]);
        console.log("FOI AQUI HEIN dNFT");
    } catch (err) {
        console.error(err);
    }
    
    callback();
}