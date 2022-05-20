
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
    console.log(await instance.getBatch(0));
    console.log(await instance.getBatch(1));
    console.log(await instance.getBatch(2));
    

    
    // const result2 = await instance.getTotalDepositedInAllBatch( {from : accounts[0]});
    // assert.equal(result2.valueOf(), 50000,'Montant inférieur');
  });


 
});