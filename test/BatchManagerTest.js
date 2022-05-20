
const BatchManager = artifacts.require("BatchManager");

contract("BatchManager", async accounts => {
  // it("should return the result", () =>
  // CapitalManager.deployed()
  //     .then(instance => instance.myBalanceDeposited())
  //     .then(balance => {
  //       assert.equal(
  //         balance.valueOf(),
  //         10000,
  //         "The result is ok"
  //       );
  //     }));
  it("TEST BATCH_MANAGER", async () => {
    const instance = await BatchManager.deployed();
    // console.log(await instance.getBatch(0));
    // console.log(await instance.getBatch(1));
    // console.log(await instance.getBatch(2));
  // const result = await instance.createAppendBatch(" Ne Batch 1",false, {from : accounts[0]});
  // assert.ok(result.receipt.status,'result ok');
    
    assert.equal(web3.utils.fromWei(await instance.getTotalDepositedInAllBatch( {from : accounts[0]})), '50000','Montant inférieur');
    // assert.equal(web3.utils.fromWei(await instance.getTotalInLockedBatch( accounts[0])), 0,'Montant inférieur');
    // assert.equal(web3.utils.fromWei(await instance.getUserWeight(  accounts[0])), '100000','Montant inférieur');
    //assert.equal(web3.utils.fromWei(await instance.getUserWeight(accounts[0])), '50000','Montant inférieur');
    //assert.equal(await instance.recoverLostWallet(accounts[0],accounts[1],{from : accounts[0]}), '50000','Montant inférieur');
    
     //assert.equal(await instance.getBatchListSize(), '2','nbre de bactch non trouvé');
    
    
  });
  
  
});