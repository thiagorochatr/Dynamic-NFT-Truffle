const dNFTS = artifacts.require("dNFTS");

module.exports = async function (deployer, _network, accounts) {
    await deployer.deploy(dNFTS);
}