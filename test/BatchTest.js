const Batch = artifacts.require("Batch");
const BatchManager = artifacts.require("BatchManager");
const fusd = artifacts.require("FBusd");
contract("Batch", async accounts => {

    
    it("TEST BATCH_CLASS", async () => {
        const fusdDeployed = await fusd.deployed();
        const batchDeployed = await BatchManager.deployed();

        await batchDeployed.createAppendBatch("Batch 3 |Test Blockchain", false, {from: accounts[0]})

        // on passe l'adresse du batchManager qu'on a récupéré  
        const instance = await Batch.at(await batchDeployed.getBatch.call(2));
        // donnes le droit au smartcontrat de déplacer de l'argent
        await fusdDeployed.approve(instance.address,  web3.utils.toWei("1000000000000", "ether"));
        
        const result = await instance.depositInCapital(web3.utils.toWei('1000'), fusdDeployed.address, {from : accounts[0]});
        // console.log(result);
        assert.ok(result.receipt.status,'Dépot effectué');
        const result2 = await instance.lockBatch((1653399955000), {from : accounts[0]}); 
        assert.ok(result2.receipt.status,'Batch bloqué');

       /*const result3 = await instance.withdraw( {from : accounts[1]});
         assert.ok(result3.receipt.status,'withdraw effectué');*/

         const result4 = await instance.myDepositedInBatchForUser(accounts[0],false, {from : accounts[0]});
         assert.equal(web3.utils.fromWei(result4),1000,'myDepositedInBatchForUser not passed');

         const result5 = await instance.getNumberOfParticipantOfBatch({from : accounts[0]});
        assert.equal(result5,1,'getNumberOfParticipantOfBatch not passed');

        const result6 = await instance.getBalance(accounts[0], {from : accounts[0]});
        assert.equal(web3.utils.fromWei(result6),1000,'getBalance not passed');

        const result7 = await instance.getHasStaked(accounts[0], {from : accounts[0]});
        assert.equal(result7,true,'getHasStaked not passed');

        const result8 = await instance.getIsStaking(accounts[0], {from : accounts[0]});
        assert.equal(result8,true,'getIsStaking not passed');

        const result9 = await instance.emergencyTransfer(fusdDeployed.address, {from : accounts[0]});
        assert.ok(result9.receipt.status,'emergencyTransfer effectué');

        const result10 = await instance.addParticipatedToken('50000','2000',fusdDeployed.address,'10000',false, {from : accounts[0]});
        assert.ok(result10.receipt.status,'addParticipatedToken effectué');

        const result11 = await instance.setAllClaimed(fusdDeployed.address,{from : accounts[0]});
        assert.ok(result11.receipt.status,'setAllClaimed effectué');
        
    
    });
    
    
  });