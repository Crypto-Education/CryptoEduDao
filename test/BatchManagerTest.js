const BatchManager = artifacts.require("BatchManager");
const { async } = require("q");
const truffleAssert = require("truffle-assertions");

contract("BatchManager", async accounts => {

  it("TEST BATCH_MANAGER", async () => {
    const instance = await BatchManager.deployed();
    // console.log(await instance.getBatch(0));
    // console.log(await instance.getBatch(1));
    // console.log(await instance.getBatch(2));
    
  console.log(web3.utils.fromWei(await instance.getBatchListSize()));
  const result1 = await instance.createAppendBatch("BATCH-TEST 3 ",false, {from : accounts[0]});
  console.log(web3.utils.fromWei(await instance.getBatchListSize()));
  assert.ok(result1.receipt.status,'result ok');
    
    // assert.equal(web3.utils.fromWei(await instance.getTotalDepositedInAllBatch( {from : accounts[0]})), '50000','Montant inférieur');
    // assert.equal(web3.utils.fromWei(await instance.getTotalInLockedBatch( accounts[0])), 0,'Montant inférieur');
    // assert.equal(web3.utils.fromWei(await instance.getUserWeight(  accounts[0])), '100000','Montant inférieur');
    //assert.equal(web3.utils.fromWei(await instance.getUserWeight(accounts[0])), '50000','Montant inférieur');
    //assert.equal(await instance.recoverLostWallet(accounts[0],accounts[1],{from : accounts[0]}), '50000','Montant inférieur');
    
     //assert.equal(await instance.getBatchListSize(), '2','nbre de bactch non trouvé');
      // assert.equal(await instance.getBatchListSize(), 2);
      //const result = await instance.createAppendBatch("Batch 3 |Batch test", false, {from: accounts[0]});
      //assert.ok(result.receipt.status)
      //assert.equal(await instance.getBatchListSize(), 3);
    
  });
  
});