
const CapitalManager = artifacts.require("CapitalManager");
const BatchManager = artifacts.require("BatchManager");
const Batch = artifacts.require("Batch");

const truffleAssert = require("truffle-assertions");

contract("CapitalManager", async accounts => {
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
      it("should fail cant redistribute ceca from outside", async () => {
        const instance = await CapitalManager.deployed();
        const batchManager1 = await BatchManager.deployed();

        // test if can deposit in bacth 1 and 2 
        const batch1 = await Batch.at(await batchManager1.getBatch.call(0));

        await truffleAssert.reverts(
          instance.sendCeCaToUser(accounts[1], web3.utils.toWei("10000000"), {from:accounts[4]}),
          "Only CeCa Batch"
        );

        await truffleAssert.reverts(
          instance.sendCeCaToUser(accounts[1], web3.utils.toWei("10000000"), {from:batch1.address})
        );
      });
 
});

