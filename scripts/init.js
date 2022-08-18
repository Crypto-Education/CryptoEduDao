const CDAOAdmins = artifacts.require("CDAOAdmins");
const BatchManager = artifacts.require("BatchManager");
const Batch = artifacts.require("Batch");
const CECAToken = artifacts.require("CECAToken");
const CapitalManager = artifacts.require("CapitalManager");
const FBusd = artifacts.require("FBusd")

const truffleAssert = require("truffle-assertions");
const { convertCompilerOptionsFromJson } = require("typescript");

module.exports = async function (callback) {
    const accounts = await new web3.eth.getAccounts()
    
    const batchMDeployed = await BatchManager.deployed();
    const cDAOAdmins = await CDAOAdmins.deployed();

    await batchMDeployed.createAppendBatch("Batch 3 |Test Blockchain", false, {from: accounts[0]})
    // pass role to account 1 
    await cDAOAdmins.grantAdmin(accounts[1], {from : accounts[0]});
    await batchMDeployed.createAppendBatch("Batch 4 |Test Blockchain", false, {from: accounts[1]})
    
    const capitalManager = await CapitalManager.deployed();

    // pass role to account 1 
    await cDAOAdmins.grantAdmin(accounts[1], {from : accounts[0]});

    // test schoud be ok
    await
        capitalManager.redistributeToOldInvestor(
          [accounts[1],accounts[2],accounts[3]], 
          [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("200")], 
          0, 
          {from: accounts[0]}
        )
    console.log(batchMDeployed.address);
    /**
    let data = await batchMDeployed.getTotalDepositedInAllBatch.call(); 
    console.log(web3.utils.fromWei(data)) */
    callback()
}