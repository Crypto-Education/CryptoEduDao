
const BatchCreator = artifacts.require("BatchCreator")
const CapitalManager = artifacts.require("CapitalManager")
const IdoCryptoEduManager = artifacts.require("IdoCryptoEduManager")

module.exports = async function (callback) {
    const accounts = await new web3.eth.getAccounts()
    batchCreator = await BatchCreator.deployed()
    capitalManager = await CapitalManager.deployed()
    idoCryptoEduManager = await IdoCryptoEduManager.deployed()


    await batchCreator.createAppendBatch("First Batch", false, {from: accounts[0]})
    const batch1 = await capitalManager.batchList(0)
    console.log(batch1)

    await idoCryptoEduManager.initialiseNewIdo("Test", 10, {from: accounts[0]});
    const ido1 = await idoCryptoEduManager.idoInformationList(0)
    console.log(ido1)

    callback()
}
