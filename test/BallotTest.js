const Ballot = artifacts.require("Ballot");
const BallotManager = artifacts.require("BallotManager");
const fusd = artifacts.require("FBusd");
const proposalNames = ['OUI','NON','ABSTENTION'];

contract("Ballot", async accounts => {

    
    it("TEST BALLOT_CLASS", async () => {
        const fusdDeployed = await fusd.deployed();
        const ballotManagerDeployed = await BallotManager.deployed();
       
        // construire un tableau de proposal onlyadmin
        ballotManagerDeployed.initialiseNewBallot('Ballot TEST 1', proposalNames, {from : accounts[1]});
        
        const ballotCreated1 = await Ballot.at(await ballotManagerDeployed.getBallot.call(0));
        await ballotCreated1.isEligibleForIdo();        
        assert.equal( await ballotCreated1.isEligibleForIdo( {from : accounts[0]}),true,'Ballot elligible');
        //construire la structure proposal

        const vote = await ballotCreated1.vote( proposal);
        assert.ok(vote.receipt.status,'Vote effectué avec succès');

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
        assert.equal(canVote3,true,'Vote locked'); 
        

    
    });
    
    
  });