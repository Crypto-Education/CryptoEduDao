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
    const capitalManager = await CapitalManager.deployed();
    const batchMDeployed = await BatchManager.deployed();
    const cDAOAdmins = await CDAOAdmins.deployed();

    await truffleAssert.reverts(capitalManager.redistributeToOldInvestor(
      [accounts[1],accounts[2],accounts[3]], 
      [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("100")], 
      5, 
      {from: accounts[0]}
      ), "redistributeToOldInvestor: mismatch"); // index not existing 

    // Only superAdmin can redistributeToOldInvestor
    await truffleAssert.reverts(capitalManager.redistributeToOldInvestor(
      [accounts[1],accounts[2],accounts[3]], 
      [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("100")], 
      0, 
      {from: accounts[1]}
      )); // is not super admin 

    // pass role to account 1 
    await cDAOAdmins.grantAdmin(accounts[1], {from : accounts[0]});
    await truffleAssert.reverts(capitalManager.redistributeToOldInvestor(
      [accounts[1],accounts[2],accounts[3]], 
      [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("100")], 
      5, 
      {from: accounts[1]}
      )); // is not super admin 

    // test schoud be ok
    assert.ok(await
        capitalManager.redistributeToOldInvestor(
          [accounts[1],accounts[2],accounts[3]], 
          [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("200")], 
          0, 
          {from: accounts[0]}
        )
      );

    // test if can deposit in bacth 1 and 2 
    const batch1 = await Batch.at(await batchMDeployed.getBatch.call(0));
    const batch2 = await Batch.at(await batchMDeployed.getBatch.call(1));
    const cECAToken1 = await CECAToken.at(await capitalManager.getCapitalToken(batch1.address));
    const cECAToken2 = await CECAToken.at(await capitalManager.getCapitalToken(batch2.address));

    // check if ceca was sent 
    assert.equal(await cECAToken1.balanceOf(accounts[1]), web3.utils.toWei("100"));
    assert.equal(await cECAToken1.balanceOf(accounts[2]), web3.utils.toWei("100"));
    assert.equal(await cECAToken1.balanceOf(accounts[3]), web3.utils.toWei("200"));
    
    // check deposited 
    const batchCreated1 = await Batch.at(await batchMDeployed.getBatch.call(0));
    assert.equal((await batchCreated1.myDepositedInBatchForUser.call(accounts[0],false)).toString(), "0");
    assert.equal((await batchCreated1.myDepositedInBatchForUser.call(accounts[1],false)).toString(), web3.utils.toWei("100"));
    assert.equal((await batchCreated1.myDepositedInBatchForUser.call(accounts[2],false)).toString(), web3.utils.toWei("100"));
    assert.equal((await batchCreated1.myDepositedInBatchForUser.call(accounts[3],false)).toString(), web3.utils.toWei("200"));


    // test userWeight getUserWeight 
    assert.equal((await batchMDeployed.getUserWeight.call(accounts[0])).toString(), 0);
    assert.equal((await batchMDeployed.getUserWeight.call(accounts[1])).toString(), 1);
    assert.equal((await batchMDeployed.getUserWeight.call(accounts[2])).toString(), 1);
    assert.equal((await batchMDeployed.getUserWeight.call(accounts[3])).toString(), 2);
    // test userWeight getPercentageUserWeight
    assert.equal(await batchMDeployed.getPercentageUserWeight.call(accounts[0]), 0);
    assert.equal(await batchMDeployed.getPercentageUserWeight.call(accounts[1]), 25);
    assert.equal(await batchMDeployed.getPercentageUserWeight.call(accounts[2]), 25);
    assert.equal(await batchMDeployed.getPercentageUserWeight.call(accounts[3]), 50);
  });

  it("TEST recoverLostWallet", async () => {
    const batchMDeployed = await BatchManager.deployed();
    const cDAOAdmins = await CDAOAdmins.deployed();
    const capitalMDeployed = await CapitalManager.deployed();
    const fusdDeployed = await FBusd.deployed();

    await truffleAssert.reverts(batchMDeployed.recoverLostWallet(accounts[1], accounts[3], {from: accounts[1]})); // is not super admin 
    // pass admin role to account 1 
    await cDAOAdmins.grantAdmin(accounts[1], {from : accounts[0]});
    await truffleAssert.reverts(batchMDeployed.recoverLostWallet( accounts[1], accounts[3], {from: accounts[1]})); // is not super admin 
    assert.equal((await batchMDeployed.getPercentageUserWeight.call(accounts[1])).toString(), 25);
    assert.equal((await batchMDeployed.getPercentageUserWeight.call(accounts[4])).toString(), 0);

    assert.ok(await
      capitalMDeployed.redistributeToOldInvestor(
        [accounts[1],accounts[2],accounts[3]], 
        [web3.utils.toWei("100"),web3.utils.toWei("100"),web3.utils.toWei("200")], 
        0, 
        {from: accounts[0]}
      )
    );
    const batchCreated = await Batch.at(await batchMDeployed.getBatch.call(0));

    assert.isFalse(await capitalMDeployed.isBlacklisted.call(accounts[1]));

    assert.ok(await batchMDeployed.recoverLostWallet(accounts[1], accounts[4], {from: accounts[0]})); // is super admin 
    assert.ok(await capitalMDeployed.addToBlackList(accounts[1], {from: accounts[0]})); // is super admin
    
    // account 1 shoud be blacklisted 
    assert.equal((await batchMDeployed.getPercentageUserWeight.call(accounts[1])).toString(), 25); // because we can't take back from old wallet
    assert.equal((await batchMDeployed.getPercentageUserWeight.call(accounts[4])).toString(), 25);
    assert.isTrue(await capitalMDeployed.isBlacklisted.call(accounts[1]));

    const batchCreated1 = await Batch.at(await batchMDeployed.getBatch.call(0));
    const cECAToken1 = await CECAToken.at(await capitalMDeployed.getCapitalToken(batchCreated1.address));

    assert.equal(await cECAToken1.balanceOf(accounts[4]), web3.utils.toWei("200"));

    await truffleAssert.reverts(batchCreated1.depositInCapital(web3.utils.toWei("500"), fusdDeployed.address, {from: accounts[1]})); // blacklist can't deposit
    fusdDeployed.transfer(accounts[1],web3.utils.toWei("10000"), {from: accounts[0]});
    await truffleAssert.reverts(batchCreated1.depositInCapital(web3.utils.toWei("500"), fusdDeployed.address, {from: accounts[1]})); // blacklist can't deposit

  });
  
});