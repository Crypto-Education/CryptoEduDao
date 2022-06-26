const CDAOAdmins = artifacts.require("CDAOAdmins");
const BatchManager = artifacts.require("BatchManager");
const Batch = artifacts.require("Batch");
const CECAToken = artifacts.require("CECAToken");
const CapitalManager = artifacts.require("CapitalManager");
const FBusd = artifacts.require("FBusd")


const truffleAssert = require("truffle-assertions");

contract("BatchManager", async accounts => {

  it("Test createAppendBatch", async() => {
    const batchMDeployed = await BatchManager.deployed();
    const cDAOAdmins = await CDAOAdmins.deployed();

    // Only admin can create batch 
    await truffleAssert.reverts(batchMDeployed.createAppendBatch("Batch 3 |Test Blockchain", false, {from: accounts[1]}));
    assert.ok(await batchMDeployed.createAppendBatch("Batch 3 |Test Blockchain", false, {from: accounts[0]}));
    assert.equal(await batchMDeployed.getBatchListSize.call(), 3);
    // pass role to account 1 
    await cDAOAdmins.grantAdmin(accounts[1], {from : accounts[0]});
    assert.ok(await batchMDeployed.createAppendBatch("Batch 4 |Test Blockchain", false, {from: accounts[1]}));
    assert.equal(await batchMDeployed.getBatchListSize.call(), 4);
  });

  it("Test redistributeToOldInvestor", async() => {
    const batchMDeployed = await BatchManager.deployed();
    const cDAOAdmins = await CDAOAdmins.deployed();
    const cECAToken = await CECAToken.deployed();

    await truffleAssert.reverts(batchMDeployed.redistributeToOldInvestor(
      [accounts[1],accounts[2],accounts[3]], 
      [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("100")], 
      5, 
      {from: accounts[0]}
      ), "redistributeToOldInvestor: mismatch"); // index not existing 

    // Only superAdmin can redistributeToOldInvestor
    await truffleAssert.reverts(batchMDeployed.redistributeToOldInvestor(
      [accounts[1],accounts[2],accounts[3]], 
      [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("100")], 
      0, 
      {from: accounts[1]}
      )); // is not super admin 

    // pass role to account 1 
    await cDAOAdmins.grantAdmin(accounts[1], {from : accounts[0]});
    await truffleAssert.reverts(batchMDeployed.redistributeToOldInvestor(
      [accounts[1],accounts[2],accounts[3]], 
      [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("100")], 
      5, 
      {from: accounts[1]}
      )); // is not super admin 

    // test schoud be ok
    assert.ok(await
        batchMDeployed.redistributeToOldInvestor(
          [accounts[1],accounts[2],accounts[3]], 
          [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("200")], 
          0, 
          {from: accounts[0]}
        )
      );
    // check if ceca was sent 
    assert.equal(await cECAToken.balanceOf(accounts[1]), web3.utils.toWei("100"));
    assert.equal(await cECAToken.balanceOf(accounts[2]), web3.utils.toWei("100"));
    assert.equal(await cECAToken.balanceOf(accounts[3]), web3.utils.toWei("200"));
    
    // check deposited 
    const batchCreated1 = await Batch.at(await batchMDeployed.getBatch.call(0));
    assert.equal(await batchCreated1.myDepositedInBatchForUser(accounts[0],false, {from : accounts[0]}), "0");
    assert.equal(await batchCreated1.myDepositedInBatchForUser(accounts[1],false, {from : accounts[0]}), web3.utils.toWei("100"));
    assert.equal(await batchCreated1.myDepositedInBatchForUser(accounts[2],false, {from : accounts[0]}), web3.utils.toWei("100"));
    assert.equal(await batchCreated1.myDepositedInBatchForUser(accounts[3],false, {from : accounts[0]}), web3.utils.toWei("200"));


    // test userWeight getUserWeight 
    assert.equal(await batchMDeployed.getUserWeight(accounts[0]), 0);
    assert.equal(await batchMDeployed.getUserWeight(accounts[1]), 1);
    assert.equal(await batchMDeployed.getUserWeight(accounts[2]), 1);
    assert.equal(await batchMDeployed.getUserWeight(accounts[3]), 2);
    // test userWeight getPercentageUserWeight
    assert.equal(await batchMDeployed.getPercentageUserWeight(accounts[0]), 0);
    assert.equal(await batchMDeployed.getPercentageUserWeight(accounts[1]), 25);
    assert.equal(await batchMDeployed.getPercentageUserWeight(accounts[2]), 25);
    assert.equal(await batchMDeployed.getPercentageUserWeight(accounts[3]), 50);
    

  });

  it("TEST recoverLostWallet", async () => {
    const batchMDeployed = await BatchManager.deployed();
    const cDAOAdmins = await CDAOAdmins.deployed();
    const capitalMDeployed = await CapitalManager.deployed();
    const fusdDeployed = await FBusd.deployed();
    const cECAToken = await CECAToken.deployed();

    await truffleAssert.reverts(batchMDeployed.recoverLostWallet( accounts[1], accounts[3], {from: accounts[1]})); // is not super admin 
    // pass admin role to account 1 
    await cDAOAdmins.grantAdmin(accounts[1], {from : accounts[0]});
    await truffleAssert.reverts(batchMDeployed.recoverLostWallet( accounts[1], accounts[3], {from: accounts[1]})); // is not super admin 
    assert.equal(await batchMDeployed.getPercentageUserWeight(accounts[1]), 25);
    assert.equal(await batchMDeployed.getPercentageUserWeight(accounts[4]), 0);

    assert.ok(await
      batchMDeployed.redistributeToOldInvestor(
        [accounts[1],accounts[2],accounts[3]], 
        [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("200")], 
        0, 
        {from: accounts[0]}
      )
    );

    assert.ok( await batchMDeployed.recoverLostWallet( accounts[1], accounts[4], {from: accounts[0]})); // is super admin 
    // account 1 shoud be blacklisted 
    assert.equal(await batchMDeployed.getPercentageUserWeight(accounts[1]), 0);
    assert.equal(await batchMDeployed.getPercentageUserWeight(accounts[4]), 25);
    assert.isTrue(await capitalMDeployed.isBlacklisted(accounts[1]));
    assert.equal(await cECAToken.balanceOf(accounts[4]), web3.utils.toWei("200"));

    const batchCreated1 = await Batch.at(await batchMDeployed.getBatch.call(0));
    await truffleAssert.reverts(batchCreated1.depositInCapital(web3.utils.toWei("500"), fusdDeployed.address, {from: accounts[1]})); // blacklist can't deposit
    fusdDeployed.transfer(accounts[1],web3.utils.toWei("10000"), {from: accounts[0]});
    await truffleAssert.reverts(batchCreated1.depositInCapital(web3.utils.toWei("500"), fusdDeployed.address, {from: accounts[1]})); // blacklist can't deposit

  });
  
});