const CryptoEduCapitalToken = artifacts.require("CryptoEduCapitalToken")
const CapitalManager = artifacts.require("CapitalManager")

module.exports = async function (callback) {
    const accounts = await new web3.eth.getAccounts()
    capitalManager = await CapitalManager.deployed()
    await capitalManager.transferOwnership(accounts[0] , {from:accounts[2]})
    callback()
}
