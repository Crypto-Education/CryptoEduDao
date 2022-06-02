const CDAOAdmins = artifacts.require("CDAOAdmins");
const Ballot = artifacts.require("Ballot");
const BallotsManager = artifacts.require("BallotsManager");
const fusd = artifacts.require("FBusd");
const BatchManager = artifacts.require("BatchManager");

const truffleAssert = require("truffle-assertions");
contract("Ballot", async accounts => {

    
    it("TEST BALLOT_CLASS", async () => {
        const cDAOAdmins1= await CDAOAdmins.deployed();
        const fusdDeployed = await fusd.deployed();
        const ballotManagerDeployed = await BallotsManager.deployed();
        const proposalNames = ['OUI','NON','ABSTENTION'];
        const batchManager1 = await BatchManager.deployed();

        await ballotManagerDeployed.initialiseNewBallot('Ballot TEST 1', proposalNames, {from : accounts[0]});
        const ballotCreated1 = await Ballot.at(await ballotManagerDeployed.getBallot.call(0));
        let proposal = 0; // 0 => OUI 1=> NON 2=> ABSTENTION 3=> ERREUR 
        
        assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[0]));

        // should revert because has not deposited 
        await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[0]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet");

        // create eligibility users 
        await batchManager1.redistributeToOldInvestor([accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]})
        
        await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[7]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); // cant vote because deposited balance < 100
        await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[8]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); // cant vote because deposited balance < 100

        assert.ok(await ballotCreated1.vote( proposal, {from : accounts[9]}),'Vote effectué avec succès'); // can vote because deposited balance > 100

        
        // await ballotCreated1.isEligibleForIdo();        
        // assert.equal( await ballotCreated1.isEligibleForIdo( {from : accounts[0]}),true,'Ballot elligible');
        //construire la structure proposal
        
        
/*
        const winningProposal = await ballotCreated1.winningProposal( proposal, {from : accounts[0]});
        assert.equal(winningProposal,'proposal 1','proposition ayant gagnée');

        const winnerName = await ballotCreated1.winnerName( {from : accounts[0]});
        assert.equal(winnerName,'jim','le nom du gagnant n est pas correct');   

        // only admin can call the function
        const lockVote = await ballotCreated1.lockVote({from : accounts[0]});
        assert.ok(lockVote.receipt.status,'Vote locked');   
        // On ne peut pas voter lorsque le vote est locked
        const voteLocked = await ballotCreated1.vote( proposal);
        assert.ok(voteLocked.receipt.status,'Vote effectué avec succès');

        const proposalSize = await ballotCreated1.getProposalSize({from : accounts[0]});
        assert.ok(proposalSize.receipt.status,'Vote locked'); 

        const canVote0 = await ballotCreated1.canVote({from : accounts[0]});
        assert.equal(canVote0,true,'Vote locked'); 

        const canVote1 = await ballotCreated1.canVote({from : accounts[3]});
        assert.equal(canVote1,true,'Vote locked'); 

        const canVote2 = await ballotCreated1.canVote({from : accounts[5]});
        assert.equal(canVote2,true,'Vote locked'); 

        const canVote3 = await ballotCreated1.canVote({from : accounts[8]});
        assert.equal(canVote3,true,'Vote locked');*/ 
        

    
    });
    
    
  });