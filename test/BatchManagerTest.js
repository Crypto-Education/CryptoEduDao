const BatchManager = artifacts.require("BatchManager");
const { async } = require("q");
const truffleAssert = require("truffle-assertions");

contract("BatchManager", async accounts => {
    it("TEST BATCH_MANAGER", async () => {
      const instance = await BatchManager.deployed();
      assert.equal(await instance.getBatchListSize(), 2);
      const result = await instance.createAppendBatch("Batch 3 |Batch test", false, {from: accounts[0]});
      assert.ok(result.receipt.status)
      assert.equal(await instance.getBatchListSize(), 3);
    });
});