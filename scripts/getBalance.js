const CDAOAdmins = artifacts.require("CDAOAdmins");
const Batch = artifacts.require("Batch");
const BatchManager = artifacts.require("BatchManager");
const FBusd = artifacts.require("FBusd");
const CECAToken = artifacts.require("CECAToken");
const CapitalManager = artifacts.require("CapitalManager");

 
        
        

module.exports = async function (callback) {
    const accounts = await new web3.eth.getAccounts()


    const cDAOAdmins1= await CDAOAdmins.deployed();
    const fbusdToken1 = await FBusd.deployed();
    const cECAToken = await CECAToken.deployed();
    const capitalManager = await CapitalManager.deployed();
    const batchManager1 = await BatchManager.deployed();

    console.log(await batchManager1.getTotalInLockedBatch(_user));
   
    const batch1 = await Batch.at(await batchManager1.getBatch.call(0));
    console.log(capitalManager.address);
    console.log(await cDAOAdmins1.getCapitalManager())
    
    //await capitalManager.sendCeCaToUserTest(accounts[8], web3.utils.toWei("80"), {from: accounts[0]});

    balance = await cECAToken.balanceOf(accounts[8])
    console.log(web3.utils.fromWei(balance.toString()))

    let data = await batchManager1.redistributeToOldInvestor([accounts[8], accounts[9]], [web3.utils.toWei("80"), web3.utils.toWei("200")], 0, {from : accounts[0]});
    //console.log(data);
    
    balance = await cECAToken.balanceOf(accounts[8])
    console.log(web3.utils.fromWei(balance.toString()))

    balance = await cECAToken.balanceOf(accounts[9])
    console.log(web3.utils.fromWei(balance.toString()))

    callback()
}
