const CDAOAdmins = artifacts.require("CDAOAdmins");
const Ballot = artifacts.require("Ballot");
const Batch = artifacts.require("Batch");
const BallotsManager = artifacts.require("BallotsManager");
const fusd = artifacts.require("FBusd");
const BatchManager = artifacts.require("BatchManager");
const CapitalManager = artifacts.require("CapitalManager");

const truffleAssert = require("truffle-assertions");
contract("Ballot", async accounts => {

    
    it("TEST INITIALISE BALLOT", async () => {
        const cDAOAdmins1= await CDAOAdmins.deployed();
        const fusdDeployed = await fusd.deployed();
        const ballotManagerDeployed = await BallotsManager.deployed();
        const proposalNames = ['OUI','NON','ABSTENTION'];
        const proposalNames1 = ['GREEN','RED','YELLOW'];
        const proposalNames2 = ['YDE','DLA','NONE'];
        const proposalNames3 = ['SUNDAY','MONDAY','NONE'];
        const batchManager1 = await BatchManager.deployed();

        // seul l'admin peut initialiser le batch
        await ballotManagerDeployed.initialiseNewBallot('Ballot TEST 1', proposalNames, Date.now() + 10000, {from : accounts[0]});
        await ballotManagerDeployed.initialiseNewBallot('Ballot TEST 2', proposalNames1, Date.now() + 10000, {from : accounts[0]});
        await ballotManagerDeployed.initialiseNewBallot('Ballot TEST 3', proposalNames2, Date.now() + 10000, {from : accounts[0]});
        await ballotManagerDeployed.initialiseNewBallot('Ballot TEST 4', proposalNames3, Date.now() + 10000, {from : accounts[0]});
       
    });

    it("VOTE", async () => {
        const cDAOAdmins1= await CDAOAdmins.deployed();
        const fusdDeployed = await fusd.deployed();
        const ballotManagerDeployed = await BallotsManager.deployed();
        const proposalNames = ['OUI','NON','ABSTENTION'];
        const capitalManager = await CapitalManager.deployed();
        const batchManager1 = await BatchManager.deployed();
        const batch1 = await Batch.at(await batchManager1.getBatch.call(0));


        const ballotCreated1 = await Ballot.at(await ballotManagerDeployed.getBallot.call(0));
        const ballotCreated2 = await Ballot.at(await ballotManagerDeployed.getBallot.call(1));
        const ballotCreated3 = await Ballot.at(await ballotManagerDeployed.getBallot.call(2));
        const ballotCreated4 = await Ballot.at(await ballotManagerDeployed.getBallot.call(3));
        
        let proposal = 0; // 0 => OUI 1=> NON 2=> ABSTENTION 3=> ERREUR 
        let proposal1 = 1; // 0 => OUI 1=> NON 2=> ABSTENTION 3=> ERREUR 
        let proposal2 = 2; // 0 => OUI 1=> NON 2=> ABSTENTION 3=> ERREUR 
        let proposal3 = 3; // 0 => OUI 1=> NON 2=> ABSTENTION 3=> ERREUR 
        //tous les comptes ne sont pas éligibles pour voter
        assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[3]));
        
        // should revert because has not deposited 
        await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[0]}), "spanshot not taken yet");
        // create eligibility users 
        await capitalManager.redistributeToOldInvestor([accounts[1],accounts[2],accounts[3],accounts[4],accounts[5],accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350"),web3.utils.toWei("800"),web3.utils.toWei("780"),web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]})
        
        // take snapshot to activate votes
        await ballotCreated1.takeSnapshop({from:accounts[0]});
        await ballotCreated2.takeSnapshop({from:accounts[0]});
        await ballotCreated3.takeSnapshop({from:accounts[0]});
        await ballotCreated4.takeSnapshop({from:accounts[0]});

        // should revert because has not deposited 
        await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[0]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet");
        //assert.ok(await ballotCreated1.vote( proposal, {from : accounts[0]}),'Vote echoué'); 

        // create eligibility users 
        //await capitalManager.redistributeToOldInvestor([accounts[1],accounts[2],accounts[3],accounts[4],accounts[5],accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("550"),web3.utils.toWei("450"),web3.utils.toWei("350"),web3.utils.toWei("800"),web3.utils.toWei("780"),web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]})
        
        await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[7]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); // cant vote because deposited balance < 100
        //assert.ok(await ballotCreated1.vote( proposal, {from : accounts[7]}),'Vote echoué'); 

        await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[8]})); // cant vote because deposited balance < 100

        const snapId = (await ballotCreated1.snapshopsId.call()).toString();

        assert.ok(await ballotCreated1.vote( proposal, {from : accounts[9]}),'Vote effectué avec succès'); 
        //await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[9]})); // can vote because deposited balance > 100

        assert.ok(await ballotCreated1.vote( proposal, {from : accounts[1]}),'Vote effectué avec succès'); 
        assert.ok(await ballotCreated1.vote( proposal1, {from : accounts[2]}),'Vote effectué avec succès'); 
        assert.ok(await ballotCreated1.vote( proposal1, {from : accounts[3]}),'Vote effectué avec succès'); 
        assert.ok(await ballotCreated1.vote( proposal, {from : accounts[4]}),'Vote effectué avec succès'); 
        //assert.ok(await ballotCreated1.vote( proposal2, {from : accounts[5]}),'Vote effectué avec succès'); 
       
        assert.ok(await ballotCreated2.vote( proposal, {from : accounts[1]}),'Vote effectué avec succès'); 
        assert.ok(await ballotCreated2.vote( proposal1, {from : accounts[2]}),'Vote effectué avec succès'); 
        assert.ok(await ballotCreated2.vote( proposal, {from : accounts[9]}),'Vote effectué avec succès');

        assert.ok(await ballotCreated3.vote( proposal1, {from : accounts[3]}),'Vote effectué avec succès'); 
        assert.ok(await ballotCreated3.vote( proposal, {from : accounts[1]}),'Vote effectué avec succès'); 
        assert.ok(await ballotCreated3.vote( proposal1, {from : accounts[2]}),'Vote effectué avec succès'); 
        assert.ok(await ballotCreated3.vote( proposal2, {from : accounts[4]}),'Vote effectué avec succès');  
        assert.ok(await ballotCreated4.vote( proposal2, {from : accounts[4]}),'Vote effectué avec succès'); 
        await truffleAssert.reverts(ballotCreated4.vote( proposal3, {from : accounts[5]})); // proposal not exist
       
        await truffleAssert.reverts(ballotCreated2.vote( proposal, {from : accounts[7]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet");
        await truffleAssert.reverts(ballotCreated2.vote( proposal, {from : accounts[8]}), "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"); 
        // On ne peut pas voter plusieurs fois
        await truffleAssert.reverts(ballotCreated1.vote( proposal, {from : accounts[9]})); 
        await truffleAssert.reverts(ballotCreated2.vote( proposal, {from : accounts[9]})); 
    });

    it("TEST WINNER PROPOSAL", async () => {
        const ballotManagerDeployed = await BallotsManager.deployed();

        const ballotCreated1 = await Ballot.at(await ballotManagerDeployed.getBallot.call(0));
        const ballotCreated2 = await Ballot.at(await ballotManagerDeployed.getBallot.call(1));
        const ballotCreated3 = await Ballot.at(await ballotManagerDeployed.getBallot.call(2));
        const ballotCreated4 = await Ballot.at(await ballotManagerDeployed.getBallot.call(3));

        assert.equal(await ballotCreated1.winningProposal.call(), 0,'Cette proposition  na pas gagné');
        assert.equal(await ballotCreated2.winningProposal.call(), 0,'Cette proposition  na pas gagné');
        assert.equal((await ballotCreated3.winningProposal.call()).toString(), 2,'Cette proposition  na pas gagné');
        assert.equal((await ballotCreated4.winningProposal.call()).toString(), 2,'Cette proposition  na pas gagné');
        assert.equal(await ballotCreated1.winnerName.call(),'OUI','la popisition gagnante n est pas correct');  
        assert.equal(await ballotCreated2.winnerName.call(),'GREEN','la popisition gagnante n est pas correct');  
        assert.equal(await ballotCreated3.winnerName.call(),'NONE','la popisition gagnante n est pas correct');  
        assert.equal(await ballotCreated4.winnerName.call(),'NONE','la popisition gagnante n est pas correct');  
    
    });
    it("LOCK VOTE", async () => {
        const cDAOAdmins1= await CDAOAdmins.deployed();
        const ballotManagerDeployed = await BallotsManager.deployed();
        let proposal = 0; // 0 => OUI 1=> NON 2=> ABSTENTION 3=> ERREUR

        const ballotCreated1 = await Ballot.at(await ballotManagerDeployed.getBallot.call(0));
        const ballotCreated2 = await Ballot.at(await ballotManagerDeployed.getBallot.call(1));
 
        // only admin can call the function
        await truffleAssert.reverts(ballotCreated1.lockVote({from : accounts[1]}));
        assert.ok(await cDAOAdmins1.grantAdmin(accounts[1], {from : accounts[0]}));
        assert.ok(await ballotCreated1.lockVote({from : accounts[1]}));
        
        // On ne peut pas voter lorsque le vote est locked
        await truffleAssert.reverts(ballotCreated1.vote( proposal,{from : accounts[9]}));
        await truffleAssert.reverts(ballotCreated1.vote( proposal,{from : accounts[2]}));

        assert.ok(await ballotCreated2.lockVote({from : accounts[0]}));

        await truffleAssert.reverts(ballotCreated2.vote( proposal,{from : accounts[9]}));
        await truffleAssert.reverts(ballotCreated2.vote( proposal,{from : accounts[2]}));
        assert.equal(await ballotCreated1.getProposalSize({from : accounts[0]}), 3,'Incorrect'); 
    
    });

    it("CAN VOTE", async () => {
        const ballotManagerDeployed = await BallotsManager.deployed();

 
        const ballotCreated1 = await Ballot.at(await ballotManagerDeployed.getBallot.call(0));
        const ballotCreated2 = await Ballot.at(await ballotManagerDeployed.getBallot.call(1));
        const ballotCreated3 = await Ballot.at(await ballotManagerDeployed.getBallot.call(2));
        const ballotCreated4 = await Ballot.at(await ballotManagerDeployed.getBallot.call(3));

        assert.equal(await ballotCreated1.canVote.call({from : accounts[1]}),false,'He cannot vote'); 
        assert.equal(await ballotCreated1.canVote.call({from : accounts[7]}), false,'He cannot vote'); 

        // le account 1 a déjà voté dans ballot2
        assert.equal(await ballotCreated2.canVote.call({from : accounts[1]}), false,'He cannot vote'); 

        assert.equal(await ballotCreated3.canVote.call({from : accounts[3]}), false,'He cannot vote');
        assert.equal(await ballotCreated3.canVote.call({from : accounts[0]}), true,'He cannot vote');
    });
    
});