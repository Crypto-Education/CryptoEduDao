
const CDAOAdmins = artifacts.require("CDAOAdmins");
const CapitalManager = artifacts.require("CapitalManager");
const BatchManager = artifacts.require("BatchManager");
const Batch = artifacts.require("Batch");
const truffleAssert = require("truffle-assertions");

contract("CapitalManager", async accounts => {
      it("should fail cant redistribute ceca from outside", async () => {
        const instance = await CapitalManager.deployed();

        await truffleAssert.reverts(
          instance.sendCeCaToUser(accounts[1], web3.utils.toWei("10000000"), {from:accounts[4]}),
          "Only CeCa Batch"
        );
      });

      it("Test blacklist", async() => {
        const instance = await CapitalManager.deployed();
        const cDAOAdmins = await CDAOAdmins.deployed();

        await truffleAssert.reverts(instance.addToBlackList( accounts[1], {from: accounts[2]})); // only super admin 
        await cDAOAdmins.grantAdmin(accounts[1], {from : accounts[0]});
        await truffleAssert.reverts(instance.addToBlackList( accounts[1], {from: accounts[2]})); // only super admin 
        assert.isFalse(await instance.isBlacklisted( accounts[1]));
        assert.ok(await instance.addToBlackList( accounts[1], {from: accounts[0]}));
        assert.isTrue(await instance.isBlacklisted( accounts[1]));
      })
 
});

