const Batch = artifacts.require("Batch");
const BatchManager = artifacts.require("BatchManager");
const fusd = artifacts.require("FBusd");
const CDAOAdmins = artifacts.require("CDAOAdmins");

const truffleAssert = require("truffle-assertions");
contract("Batch", async accounts => {

    
    it("TEST BATCH_CLASS", async () => {
        const fusdDeployed = await fusd.deployed();
        const batchDeployed = await BatchManager.deployed();

        await batchDeployed.createAppendBatch("Batch 3 |Test Blockchain", false, {from: accounts[0]})
        
        await batchDeployed.createAppendBatch("Batch 4 |Test Blockchain", false, {from: accounts[0]})
        await batchDeployed.createAppendBatch("Batch 5 |Test Blockchain", false, {from: accounts[0]})
        await batchDeployed.createAppendBatch("Batch 6 |Test Blockchain", false, {from: accounts[0]})
        await batchDeployed.createAppendBatch("Batch 7 |Test Blockchain", false, {from: accounts[0]})
        console.log(web3.utils.fromWei(await batchDeployed.getBatchListSize()));
        // on passe l'adresse du batchManager qu'on a récupéré  
        const batchCreated1 = await Batch.at(await batchDeployed.getBatch.call(2));
        const batchCreated2 = await Batch.at(await batchDeployed.getBatch.call(3));
        const batchCreated3 = await Batch.at(await batchDeployed.getBatch.call(4));
        const batchCreated4 = await Batch.at(await batchDeployed.getBatch.call(5));
        const batchCreated5 = await Batch.at(await batchDeployed.getBatch.call(6));
        // donnes le droit au smartcontrat de déplacer de l'argent
        await fusdDeployed.approve(batchCreated1.address,  web3.utils.toWei("1000000000000", "ether"));
        await fusdDeployed.approve(batchCreated2.address,  web3.utils.toWei("1000000000000", "ether"));
        await fusdDeployed.approve(batchCreated3.address,  web3.utils.toWei("1000000000000", "ether"));
        await fusdDeployed.approve(batchCreated4.address,  web3.utils.toWei("1000000000000", "ether"));
        await fusdDeployed.approve(batchCreated5.address,  web3.utils.toWei("1000000000000", "ether"));
        
        fusdDeployed.transfer(accounts[1],web3.utils.toWei("100000"), {from: accounts[0]});
        fusdDeployed.transfer(accounts[2],web3.utils.toWei("100000"), {from: accounts[0]});
        fusdDeployed.transfer(accounts[3],web3.utils.toWei("500000"), {from: accounts[0]});
        fusdDeployed.transfer(accounts[4],web3.utils.toWei("120000"), {from: accounts[0]});


        const capitalDeposited1 = await batchCreated1.depositInCapital(web3.utils.toWei('300000'), fusdDeployed.address, {from : accounts[0]});
        assert.ok(capitalDeposited1.receipt.status,'Dépot effectué dans le premier 1 batch');
        //await truffleAssert.reverts(capitalDeposited1, "Cant deposit bach is locked or amount ");

        const capitalDeposited11 = await batchCreated1.depositInCapital(web3.utils.toWei('600000'), fusdDeployed.address, {from : accounts[0]});
        assert.ok(capitalDeposited11.receipt.status,'Dépot effectué dans le premier batch');
        //await truffleAssert.reverts(capitalDeposited11, "Cant deposit bach is locked or amount ");
        
        const capitalDeposited2 = await batchCreated2.depositInCapital(web3.utils.toWei('500000'), fusdDeployed.address, {from : accounts[0]});  
        assert.ok(capitalDeposited2.receipt.status,'Dépot effectué dans le second batch');
        //await truffleAssert.reverts(capitalDeposited2, "Cant deposit in bach ");

       //on doit approuver que cet account peut dépenser de l'argent qui lui a été transféré 
       //await fusdDeployed.approve(accounts[1],  web3.utils.toWei("1000000000000", "ether"),{from: accounts[1]});
       await fusdDeployed.approve(batchCreated3.address,  web3.utils.toWei("1000000000000", "ether"), {from: accounts[1]});
       await fusdDeployed.approve(batchCreated4.address,  web3.utils.toWei("1000000000000", "ether"), {from: accounts[2]});
       await fusdDeployed.approve(batchCreated5.address,  web3.utils.toWei("1000000000000", "ether"), {from: accounts[3]});
       await fusdDeployed.approve(batchCreated5.address,  web3.utils.toWei("1000000000000", "ether"), {from: accounts[4]});
      
       //await Contract.methods.approve(accounts[1],  web3.utils.toWei("1000000000000", "ether")).send({
       // from: accounts[1]
     //})
        // on ne peut pas déposer plus que ce qu'on nous a transféré
          const capitalDeposited3 = await batchCreated3.depositInCapital(web3.utils.toWei('80000'), fusdDeployed.address, {from : accounts[1]});
          assert.ok(capitalDeposited3.receipt.status,'Dépot effectué dans le 3em batch');
        
          const capitalDeposited4 = await batchCreated4.depositInCapital(web3.utils.toWei('60000'), fusdDeployed.address, {from : accounts[2]});
          assert.ok(capitalDeposited4.receipt.status,'Dépot effectué dans le 4em batch');
        
          const capitalDeposited5 = await batchCreated5.depositInCapital(web3.utils.toWei('100000'), fusdDeployed.address, {from : accounts[3]});
          assert.ok(capitalDeposited5.receipt.status,'Dépot effectué dans le 5em batch');
        // account 4 depose dans le batch5
        const capital4Deposited5 = await batchCreated5.depositInCapital(web3.utils.toWei('20000'), fusdDeployed.address, {from : accounts[4]});
        assert.ok(capital4Deposited5.receipt.status,'Dépot effectué dans le 5em batch par le user 4');
        
        //console.log(result);
        

        // On bloque le 1er batch créé
        const lockBatch1 = await batchCreated1.lockBatch((1653399955000), {from : accounts[0]}); 
        assert.ok(lockBatch1.receipt.status,'Batch 1 bloqué');
        // On bloque le 5em batch (seul l'admin peut bloquer le batch)
        const lockBatch2 = await batchCreated3.lockBatch((1653399955000), {from : accounts[0]}); 
        assert.ok(lockBatch2.receipt.status,'Batch 5 bloqué');

        //dépot dans un batch bloqué, On ne peut pas déposer dans un batch bloqué
        //  const depotInBatchLocked = await batchCreated3.depositInCapital(web3.utils.toWei('1000000'), fusdDeployed.address, {from : accounts[0]});      
        //  assert.ok(depotInBatchLocked.receipt.status,'Dépot effectué dans le batch 5 bloqué');

       /*const result3 = await instance.withdraw( {from : accounts[1]});
         assert.ok(result3.receipt.status,'withdraw effectué');*/
        
        // On vérifie le dépot du batch 1
          const myDepositedInBatchForUser = await batchCreated1.myDepositedInBatchForUser.call(accounts[0],false, {from : accounts[0]});
          assert.equal(web3.utils.fromWei(myDepositedInBatchForUser), 900000,'myDepositedInBatchForUser not passed');
          
          // On vérifie le dépot du batch 2
          const myDepositedInBatchForUser5 = await batchCreated2.myDepositedInBatchForUser.call(accounts[0],false, {from : accounts[0]});
          assert.equal(web3.utils.fromWei(myDepositedInBatchForUser5),500000,'myDepositedInBatchForUser1 not passed');
            
          // On vérifie le dépot du batch 3
          const myDepositedInBatchForUser3 = await batchCreated3.myDepositedInBatchForUser.call(accounts[1],false, {from : accounts[0]});
          assert.equal(web3.utils.fromWei(myDepositedInBatchForUser3),80000,'myDepositedInBatchForUser2 not passed');
            
          // On vérifie le dépot du batch 4
          const myDepositedInBatchForUser4 = await batchCreated4.myDepositedInBatchForUser.call(accounts[2],false, {from : accounts[0]});
          assert.equal(web3.utils.fromWei(myDepositedInBatchForUser4),60000,'myDepositedInBatchForUser3 not passed');

          // On vérifie le dépot du batch 5 par user 3
          const myDepositedInBatch5ForUser3 = await batchCreated5.myDepositedInBatchForUser.call(accounts[3],false, {from : accounts[1]});
          assert.equal(web3.utils.fromWei(myDepositedInBatch5ForUser3),100000,'myDepositedInBatch5ForUser3 not passed');
         
           // On vérifie le dépot du batch 5 par user 4
          const myDepositedInBatch5ForUser4 = await batchCreated5.myDepositedInBatchForUser.call(accounts[4],false, {from : accounts[0]});
          assert.equal(web3.utils.fromWei(myDepositedInBatch5ForUser4),20000,'myDepositedInBatch5ForUser4 not passed');

          const getBalanceBatchCreated1 = await batchCreated1.getBalance.call(accounts[0]);
          assert.equal(web3.utils.fromWei(getBalanceBatchCreated1),900000,'getBalanceBatchCreated1 not passed');

          const getBalanceBatchCreated5 = await batchCreated5.getBalance.call(accounts[4]);
          assert.equal(web3.utils.fromWei(getBalanceBatchCreated5),20000,'getBalanceBatchCreated1 not passed');

          const emergencyTransfer = await batchCreated4.emergencyTransfer(fusdDeployed.address, {from : accounts[0]});
          assert.ok(emergencyTransfer.receipt.status,'emergencyTransfer effectué');

          const addParticipatedToken = await batchCreated1.addParticipatedToken('50000','2000',fusdDeployed.address,'10000',false, {from : accounts[0]});
          assert.ok(addParticipatedToken.receipt.status,'addParticipatedToken effectué');

        //   const addParticipatedToken = await batchCreated1.setAllClaimed(fusdDeployed.address,{from : accounts[0]});
        //   assert.ok(addParticipatedToken.receipt.status,'setAllClaimed effectué');

        //const result11 = await instance.setAllClaimed(fusdDeployed.address,{from : accounts[0]});
        //assert.ok(result11.receipt.status,'setAllClaimed effectué');

        
    
    });
    
    it("TEST Token Information", async () => {
      //const batchMDeployed = await BatchManager.deployed();
      const cDAOAdmins = await CDAOAdmins.deployed();
      //const capitalMDeployed = await CapitalManager.deployed();
      const fusdDeployed = await fusd.deployed();
      //const cECAToken = await CECAToken.deployed();
  
      const batchDeployed = await BatchManager.deployed();

      await batchDeployed.createAppendBatch("Batch new |Test Blockchain", false, {from: accounts[0]});
      
      const batchCreated1 = await Batch.at(await batchDeployed.getBatch.call(2));
      
      await cDAOAdmins.grantAdmin(accounts[3], {from : accounts[0]});

      await truffleAssert.reverts(batchCreated1.setTokenInformation(fusdDeployed.address, false, web3.utils.toWei("100"), {from: accounts[5]})); 
      await truffleAssert.reverts(batchCreated1.setTokenInformation(fusdDeployed.address, false, web3.utils.toWei("100"), {from: accounts[2]})); 
      assert.ok(await batchCreated1.setTokenInformation(fusdDeployed.address, false, web3.utils.toWei("100"), {from: accounts[3]}),'admin can call ');
      await truffleAssert.reverts(batchCreated1.setTokenInformation(fusdDeployed.address, false, web3.utils.toWei("100"), {from: accounts[7]}));
      assert.ok(await batchCreated1.setTokenInformation(fusdDeployed.address, false, web3.utils.toWei("100"), {from: accounts[0]}),'super admin can call ');
      const tokenInfos = await batchCreated1.tokenInfos.call(fusdDeployed.address);
      assert.equal(tokenInfos.amount,web3.utils.toWei("100"),'amount not equal ');
    });
  });