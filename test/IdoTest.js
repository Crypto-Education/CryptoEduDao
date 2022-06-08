const Ido = artifacts.require("Ido");
const CDAOAdmins = artifacts.require("CDAOAdmins");
const IdoManager = artifacts.require("IdoManager");
const fusd = artifacts.require("FBusd");
const Batch = artifacts.require("Batch");
const BatchManager = artifacts.require("BatchManager");

const truffleAssert = require("truffle-assertions");
contract("Ido", async accounts => {

      
  it("TEST INITIALISE IDO", async () => {
    const fusdDeployed = await fusd.deployed();
    const idoManagerDeployed = await IdoManager.deployed();

// seul l'admin peut initialiser le ido
    await idoManagerDeployed.initialiseNewIdo('IDO TEST 1', web3.utils.toWei("10"), {from : accounts[0]});
    await idoManagerDeployed.initialiseNewIdo('IDO TEST 2', web3.utils.toWei("8"), {from : accounts[0]});
    await idoManagerDeployed.initialiseNewIdo('IDO TEST 3', web3.utils.toWei("15"), {from : accounts[0]});
    await idoManagerDeployed.initialiseNewIdo('IDO TEST 4', web3.utils.toWei("12"), {from : accounts[0]});
    
   
});
   
it("ELIGIBILITY", async () => {
  const cDAOAdmins1= await CDAOAdmins.deployed();
  const fusdDeployed = await fusd.deployed();
  
  const idoManagerDeployed = await IdoManager.deployed();
  
  const batchManagerDeployed = await BatchManager.deployed();

  const idoCreated1 = await Ido.at(await idoManagerDeployed.getIdo.call(0));
  const idoCreated2 = await Ido.at(await idoManagerDeployed.getIdo.call(1));
  const idoCreated3 = await Ido.at(await idoManagerDeployed.getIdo.call(2));
  const idoCreated4 = await Ido.at(await idoManagerDeployed.getIdo.call(3));

  await truffleAssert.reverts(await batchManagerDeployed.createAppendBatch("Batch 1 |Test ido ", false, {from: accounts[0]}));
  
  const batchCreated1 = await Batch.at(await batchManagerDeployed.getBatch.call(3));

  //tous les comptes sont éligibles pour voter
  //assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[3]));
   
  await batchCreated1.redistributeToOldInvestor([accounts[1],accounts[2],accounts[3],accounts[4],accounts[5],accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350"),web3.utils.toWei("800"),web3.utils.toWei("780"),web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]});
 
  // should revert because has not deposited 
  //await truffleAssert.reverts(ballotCreated1.isEligible( {from : accounts[0]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet");
  //await assert.equal(idoCreated1.isEligible({from : accounts[0]}),true, "Account not eligible");
 //  assert.isFalse(await idoCreated1.isEligible({from : accounts[3]}));
  await assert.equal(idoCreated1.isEligible({from : accounts[1]}),true, "Account not eligible");
  await assert.equal(await idoCreated1.isEligible({from : accounts[3]}),true, "Account not eligible");
  await assert.equal(await idoCreated2.isEligible({from : accounts[0]}),true, "Account not eligible");
  await assert.equal(await idoCreated2.isEligible({from : accounts[9]}),true, "Account not eligible");
  await assert.equal(await idoCreated3.isEligible({from : accounts[0]}),true, "Account not eligible");
  await assert.equal(await idoCreated3.isEligible({from : accounts[7]}),true, "Account not eligible");
  await assert.equal(await idoCreated4.isEligible({from : accounts[1]}),true, "Account not eligible");
  await assert.equal(await idoCreated4.isEligible({from : accounts[8]}),true, "Account not eligible");
 
}); 

it("DEPOSIT", async () => {
  const cDAOAdmins1= await CDAOAdmins.deployed();
  const fusdDeployed = await fusd.deployed();
  
  const idoManagerDeployed = await IdoManager.deployed();
  const batchManagerDeployed = await BatchManager.deployed();


  const idoCreated1 = await Ido.at(await idoManagerDeployed.getIdo.call(0));
  const idoCreated2 = await Ido.at(await idoManagerDeployed.getIdo.call(1));
  const idoCreated3 = await Ido.at(await idoManagerDeployed.getIdo.call(2));
  const idoCreated4 = await Ido.at(await idoManagerDeployed.getIdo.call(3));

  await truffleAssert.reverts(await batchManagerDeployed.createAppendBatch("Batch 1 |Test ido ", false, {from: accounts[0]}));
  
  
  const batchCreated1 = await Batch.at(await batchManagerDeployed.getBatch.call(3));

  //tous les comptes sont éligibles pour voter
  assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[3]));
    
    //personne ayant déposer le capital
  await batchCreated1.redistributeToOldInvestor([accounts[1],accounts[2],accounts[3],accounts[4],accounts[5],accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350"),web3.utils.toWei("800"),web3.utils.toWei("780"),web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]})
 
  // set setIdoToken
  
  //depositForIdo
 // await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[7]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); // cant vote because deposited balance < 100

  await truffleAssert.reverts(idoCreated1.depositForIdo(web3.utils.toWei("50"), batchCreated1.address,{from: accounts[1]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); 
 
  await truffleAssert.reverts(idoCreated1.idoLockDeposit({from: accounts[0]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); 
 
}); 
it("SET TOKEN", async () => {
  const cDAOAdmins1= await CDAOAdmins.deployed();
  const fusdDeployed = await fusd.deployed();
  
  const idoManagerDeployed = await IdoManager.deployed();
  const batchManagerDeployed = await BatchManager.deployed();


  const idoCreated1 = await Ido.at(await idoManagerDeployed.getIdo.call(0));
  const idoCreated2 = await Ido.at(await idoManagerDeployed.getIdo.call(1));
  const idoCreated3 = await Ido.at(await idoManagerDeployed.getIdo.call(2));
  const idoCreated4 = await Ido.at(await idoManagerDeployed.getIdo.call(3));

  //tous les comptes sont éligibles pour voter
  assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[3]));
  truffleAssert.reverts(await batchManagerDeployed.createAppendBatch("Batch 1 |Test ido ", false, {from: accounts[0]}));
    
  const batchCreated1 = await Batch.at(await batchManagerDeployed.getBatch.call(3));
    //personne ayant déposer le capital
  await batchCreated1.redistributeToOldInvestor([accounts[1],accounts[2],accounts[3],accounts[4],accounts[5],accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350"),web3.utils.toWei("800"),web3.utils.toWei("780"),web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]})

  
  // set setIdoToken
  
  //depositForIdo
  //await Assert.ok(idoCreated1.setIdoToken(accounts[1], web3.utils.toWei("450"),batchCreated1.address, {from: accounts[4]})," IDO NOT SET"); 
  await truffleAssert.reverts(idoCreated1.setIdoToken(accounts[1], web3.utils.toWei("450"),batchCreated1.address, {from: accounts[4]})); 
 
  await truffleAssert.reverts(idoCreated1.redistributeIdoToken({from: accounts[0]})); 
 
  await truffleAssert.reverts(idoCreated1.getSumOfAllWeight({from: accounts[0]})); 
 
  await truffleAssert.reverts(idoCreated1.emergencyTransfer(batchCreated1.address,{from: accounts[0]})); 
 
  await truffleAssert.reverts(idoCreated1.myDepositedInIdo({from: accounts[0]})); 
 
  
  

}); 
    
  });