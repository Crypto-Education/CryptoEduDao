
const CapitalManager = artifacts.require("CapitalManager");

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
  it("should return result", async () => {
    const instance = await CapitalManager.deployed();
    const balance = await instance.myBalanceDeposited();
    assert.equal(balance.valueOf(),'The value is not set');
  });


 
});

