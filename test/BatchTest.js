const Batch = artifacts.require("Batch");
const BatchManager = artifacts.require("BatchManager");
const fusd = artifacts.require("FBusd");
contract("Batch", async accounts => {

    
    it("TEST BATCH_CLASS", async () => {
        const fusdDeployed = await fusd.deployed();
        const batchDeployed = await BatchManager.deployed();
        // on passe l'adresse du batchManager qu'on a récupéré  
        const instance = await Batch.at(await batchDeployed.getBatch(0));
        // donnes e droit au smartcontrat de déplacer de l'argent
        await fusdDeployed.approve(instance.address,  web3.utils.toWei("1000000000000", "ether"));
        
        const result = await instance.depositInCapital(web3.utils.toWei('1000'),fusdDeployed.address, {from : accounts[0]});
        console.log(result);
        assert.ok(result.receipt.status,'Dépot effectué');
      
    });
    
    
  });