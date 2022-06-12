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

  assert.ok(batchManagerDeployed.createAppendBatch("Batch 2 |Test ido ", true, {from: accounts[0]}));
  
  
  const batchCreated1 = await Batch.at(await batchManagerDeployed.getBatch.call(0));

  // on peut pas appeler la redistribution directement a partir du bacth on doit passer par le manager
  await truffleAssert.reverts(batchCreated1.redistributeCapital([accounts[1],accounts[2],accounts[3]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350")]), "Not Manager Contract");

  await batchManagerDeployed.redistributeToOldInvestor([accounts[1],accounts[2],accounts[3],accounts[4],accounts[5],accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350"),web3.utils.toWei("800"),web3.utils.toWei("780"),web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 2, {from : accounts[0]});
 
  assert.isFalse(await idoCreated2.isEligible({from : accounts[0]}), "Account not eligible");
  assert.isTrue(await idoCreated1.isEligible({from : accounts[1]}), "Account not eligible");
  assert.isTrue(await idoCreated1.isEligible({from : accounts[2]}), "Account not eligible");
  assert.isTrue(await idoCreated1.isEligible({from : accounts[3]}), "Account not eligible");
  assert.isTrue(await idoCreated1.isEligible({from : accounts[4]}), "Account not eligible");
  assert.isTrue(await idoCreated1.isEligible({from : accounts[5]}), "Account not eligible");
  assert.isFalse(await idoCreated1.isEligible({from : accounts[6]}), "Account not eligible");
  assert.isFalse(await idoCreated3.isEligible({from : accounts[7]}), "Account not eligible")
  assert.isFalse(await idoCreated4.isEligible({from : accounts[8]}), "Account not eligible");
  assert.isTrue(await idoCreated2.isEligible({from : accounts[9]}), "Account not eligible");
 
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

  //await truffleAssert.reverts(batchManagerDeployed.createAppendBatch("Batch 3 |Test ido ", false, {from: accounts[1]}));
  
  
  const batchCreated1 = await Batch.at(await batchManagerDeployed.getBatch.call(0));

  //doit etre true car dans le it precedent on a envoye 350
  assert.isTrue(await cDAOAdmins1.checkEligibility.call(accounts[3]));

  await truffleAssert.reverts(idoCreated1.depositForIdo(web3.utils.toWei("50"), batchCreated1.address, {from: accounts[0]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); // normal car la ligne 48 dit bien qu'il n'est pas eligible donc il ne peut pas deposer 
  await truffleAssert.reverts(idoCreated1.depositForIdo(web3.utils.toWei("50"), batchCreated1.address, {from: accounts[1]}), "No enough Token to pay"); // normal car le  token qu'il envoit n'est pas accepte comme moyen de paiement il faut envoyer les FUSD 
  
  await truffleAssert.reverts(idoCreated1.depositForIdo(web3.utils.toWei("50"), fusd.address, {from: accounts[1]}), "No enough Token to pay"); // normal car so solde en fusd est insuffisant 
  assert.ok(await fusdDeployed.transfer(accounts[1], web3.utils.toWei("100")), {from: accounts[0]}) // on lui envoie 100 FUSD donc le compte 1 peut deposer 
  
  assert.ok(await fusdDeployed.approve(idoCreated1.address, web3.utils.toWei("10000000000"), {from: accounts[1]}))
  // max c'est 10
  await truffleAssert.reverts(idoCreated1.depositForIdo(web3.utils.toWei("50"), fusd.address, {from: accounts[1]}), "amount cannot be 0 and should be less than maximum") // on peut pas deposer plus que le max qui a ete defini
  assert.ok(await idoCreated1.depositForIdo(web3.utils.toWei("3"), fusd.address, {from: accounts[1]})); // manque 7
  assert.equal(await idoCreated1.myDepositedInIdo({from: accounts[1]}), web3.utils.toWei("3")); 
  
  await truffleAssert.reverts(idoCreated1.depositForIdo(web3.utils.toWei("8"), fusd.address, {from: accounts[1]})) // on peut pas deposer plus que le max qui a ete defini
  assert.ok(await idoCreated1.depositForIdo(web3.utils.toWei("7"), fusd.address, {from: accounts[1]})); // manque 0

  //pas besoin de redistribuer a chanque fois deja fait dans le it precedant 
  //await batchManagerDeployed.redistributeToOldInvestor([accounts[1],accounts[2],accounts[3],accounts[4],accounts[5],accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350"),web3.utils.toWei("800"),web3.utils.toWei("780"),web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]})
 
  // set setIdoToken
  
  //depositForIdo
 // await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[7]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); // cant vote because deposited balance < 100

 // await assert.ok(idoCreated1.depositForIdo(web3.utils.toWei("50"), fusd.address,{from: accounts[1]}), "amount cannot be 0 and should be less than maximum"); 
 
  // only admins can locked ido
  await assert.ok(idoCreated1.idoLockDeposit({from: accounts[0]}), "Ido locked"); 

// can not deposit in locked ido
  //await assert.ok(idoCreated1.depositForIdo(web3.utils.toWei("8"), fusd.address,{from: accounts[1]}), "can not deposit in ido locked"); 
 
  
  assert.equal(await idoCreated1.getSumOfAllWeight({from: accounts[0]}), 5); 
  assert.equal(await idoCreated1.myDepositedInIdo({from: accounts[1]}), web3.utils.toWei("10")); 
 
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


  //tous les comptes sont éligibles pour l'ido
  assert.isTrue(await cDAOAdmins1.checkEligibility.call(accounts[3]));
  assert.ok(await batchManagerDeployed.createAppendBatch("Batch 1 |Test ido ", false, {from: accounts[0]}));
    
  const batchCreated1 = await Batch.at(await batchManagerDeployed.getBatch.call(3));
    //personne ayant déposer le capital
  await batchManagerDeployed.redistributeToOldInvestor([accounts[1],accounts[2],accounts[3],accounts[4],accounts[5],accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350"),web3.utils.toWei("800"),web3.utils.toWei("780"),web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]})


  
  // set setIdoToken
  
  //depositForIdo

  //await assert.ok(idoCreated1.setIdoToken(accounts[1], web3.utils.toWei("450"),batchCreated1.address, {from: accounts[4]})); 
 
  assert.ok(await fusdDeployed.transfer(accounts[1], web3.utils.toWei("500")), {from: accounts[0]}) // on lui envoie 100 FUSD donc le compte 1 peut deposer 
  
  assert.ok(await fusdDeployed.approve(idoCreated1.address, web3.utils.toWei("10000000000"), {from: accounts[1]}))
  
  assert.ok(await fusdDeployed.transfer(accounts[3], web3.utils.toWei("500")), {from: accounts[0]}) // on lui envoie 100 FUSD donc le compte 1 peut deposer 
  
  assert.ok(await fusdDeployed.approve(idoCreated1.address, web3.utils.toWei("10000000000"), {from: accounts[3]}))
  
  assert.ok(await fusdDeployed.transfer(accounts[7], web3.utils.toWei("500")), {from: accounts[0]}) // on lui envoie 100 FUSD donc le compte 1 peut deposer 
  
  assert.ok(await fusdDeployed.approve(idoCreated1.address, web3.utils.toWei("10000000000"), {from: accounts[7]}))
  
  assert.ok(await fusdDeployed.transfer(accounts[9], web3.utils.toWei("500")), {from: accounts[0]}) // on lui envoie 100 FUSD donc le compte 1 peut deposer 
  
  assert.ok(await fusdDeployed.approve(idoCreated1.address, web3.utils.toWei("10000000000"), {from: accounts[9]}))
  
  await truffleAssert.reverts(idoCreated1.setIdoToken(fusdDeployed.address, web3.utils.toWei("45.5"), web3.utils.toWei("10.86"),fusdDeployed.address, {from: accounts[4]})); // seulemet un admin ou un super admin peuvent
  assert.ok(await idoCreated1.setIdoToken(fusdDeployed.address, web3.utils.toWei("45.5"), web3.utils.toWei("10.86"),fusdDeployed.address, {from: accounts[0]})); 
  await truffleAssert.reverts(idoCreated1.setIdoToken(fusdDeployed.address, web3.utils.toWei("45.5"), web3.utils.toWei("10.86"),fusdDeployed.address, {from: accounts[0]}));  // on ne peut pas set 2 fois 

 
  assert.ok(await idoCreated1.redistributeIdoToken({from: accounts[0]})); 
 
  await truffleAssert.reverts(idoCreated1.emergencyTransfer(fusd.address,{from: accounts[1]})); 
  await truffleAssert.reverts(idoCreated1.emergencyTransfer(fusd.address,{from: accounts[3]}));  
  await truffleAssert.reverts(idoCreated1.emergencyTransfer(fusd.address,{from: accounts[6]})); 
  await truffleAssert.reverts(idoCreated1.emergencyTransfer(fusd.address,{from: accounts[8]})); 
  await truffleAssert.reverts(idoCreated1.emergencyTransfer(fusd.address,{from: accounts[9]}));

}); 
    
  });