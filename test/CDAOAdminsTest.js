const CDAOAdmins = artifacts.require("CDAOAdmins");
const Batch = artifacts.require("Batch");
const BatchManager = artifacts.require("BatchManager");
const FBusd = artifacts.require("FBusd");
const CECAToken = artifacts.require("CECAToken");
const CapitalManager = artifacts.require("CapitalManager");
const Ballot = artifacts.require("Ballot");
const BallotsManager = artifacts.require("BallotsManager");


const truffleAssert = require("truffle-assertions");

contract("CDAOAdmins", accounts => {
  it("Test administration function", async () => {
        const cDAOAdmins = await CDAOAdmins.deployed();
        assert.equal(
            await cDAOAdmins.isAdmin(accounts[0]),
            false,
            `${accounts[0]} n'est pas admin`
            );
        assert.equal(
            await cDAOAdmins.isSuperAdmin(accounts[0]),
            true,
            `${accounts[0]} n'est pas superadmin`
            );
        assert.equal(
            await cDAOAdmins.isAdmin(accounts[1]),
            false,
            `${accounts[1]} n'est pas admin`
            );
        assert.equal(
            await cDAOAdmins.isSuperAdmin(accounts[1]),
            false,
            `${accounts[1]} n'est pas superadmin`
            );

        assert.ok(await cDAOAdmins.grantAdmin(accounts[2], {from : accounts[0]}));
        assert.equal(
            await cDAOAdmins.isAdmin(accounts[2]),
            true,
            `${accounts[2]} n'est pas admin`
            );

        await truffleAssert.reverts(cDAOAdmins.grantAdmin(accounts[1], {from : accounts[2]}), "caller is not the superadmin");
        await truffleAssert.reverts(cDAOAdmins.removerGrantAdmin(accounts[2], {from : accounts[2]}), "caller is not the superadmin");
        await truffleAssert.reverts(cDAOAdmins.removerGrantAdmin(accounts[2], {from : accounts[1]}), "caller is not the superadmin");
    
        await cDAOAdmins.removerGrantAdmin(accounts[2], {from : accounts[0]});
        assert.equal(
            await cDAOAdmins.isAdmin(accounts[2]),
            false
            );

        await truffleAssert.reverts(cDAOAdmins.changeSuperAdmin(accounts[2], {from : accounts[1]}), "caller is not the superadmin");
        await truffleAssert.reverts(cDAOAdmins.changeSuperAdmin(accounts[2], {from : accounts[0]}), "New user most be an administrator");
        await cDAOAdmins.grantAdmin(accounts[2], {from : accounts[0]});
        await cDAOAdmins.changeSuperAdmin(accounts[2], {from : accounts[0]});
        assert.equal(
            await cDAOAdmins.isSuperAdmin(accounts[2]),
            true
            );
        await cDAOAdmins.grantAdmin(accounts[0], {from : accounts[2]});
        await cDAOAdmins.changeSuperAdmin(accounts[0], {from : accounts[2]});
    });

    it("Test Member eligibility And deposit in capital", async() => {
        const cDAOAdmins1= await CDAOAdmins.deployed();
        const fbusdToken1 = await FBusd.deployed();
        const capitalManager = await CapitalManager.deployed();

        assert.equal(
            await cDAOAdmins1.checkEligibility.call(accounts[0]),
            false
            );

        const batchManager1 = await BatchManager.deployed();

        // test if can deposit in bacth 1 and 2 
        const batch1 = await Batch.at(await batchManager1.getBatch.call(0));
        await truffleAssert.reverts(batch1.depositInCapital(web3.utils.toWei("100"), fbusdToken1.address), "Cant deposit bach is locked or amount ");
        
        const batch2 = await Batch.at(await batchManager1.getBatch.call(1));
        await truffleAssert.reverts(batch2.depositInCapital(web3.utils.toWei("100"), fbusdToken1.address), "Cant deposit bach is locked or amount ");
        
        const cECAToken1 = await CECAToken.at(await capitalManager.getCapitalToken(batch1.address));
        const cECAToken2 = await CECAToken.at(await capitalManager.getCapitalToken(batch2.address));

        // sent fusd to account 2
        await fbusdToken1.transfer(accounts[2], web3.utils.toWei("1000"), {from: accounts[0]});

        assert.equal(await fbusdToken1.balanceOf(accounts[2]), web3.utils.toWei("1000"));

        // test redistribute token to batch 1 
        // Can't call redistribute from out site 
        await truffleAssert.reverts(batch1.redistributeCapital([accounts[8], accounts[9]], [web3.utils.toWei("80"), web3.utils.toWei("200")], {from : accounts[1]}), "");
        await truffleAssert.reverts(
            capitalManager.redistributeToOldInvestor([accounts[8], accounts[9]], [web3.utils.toWei("80"), web3.utils.toWei("200")], 0, {from : accounts[1]}),  
            "caller is not the superadmin"
            );
        
        await capitalManager.redistributeToOldInvestor([accounts[7],accounts[8], accounts[9]], [web3.utils.toWei("70"),web3.utils.toWei("99"), web3.utils.toWei("200")], 0, {from : accounts[0]})
        
        assert.equal(await cECAToken1.balanceOf(accounts[7]), web3.utils.toWei("70"));
        assert.equal(await cECAToken1.balanceOf(accounts[8]), web3.utils.toWei("99"));
        assert.equal(await cECAToken1.balanceOf(accounts[9]), web3.utils.toWei("200"));

        assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[7]));
        assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[8])); 
        assert.isTrue(await cDAOAdmins1.checkEligibility.call(accounts[9]));

        // redistribute a second time but in batch 2
        await capitalManager.redistributeToOldInvestor([accounts[8], accounts[7]], [web3.utils.toWei("80"), web3.utils.toWei("200")], 1, {from : accounts[0]})
        assert.equal(await cECAToken2.balanceOf(accounts[7]), web3.utils.toWei("200"));
        assert.equal(await cECAToken2.balanceOf(accounts[8]), web3.utils.toWei("80"));
        assert.equal(await cECAToken2.balanceOf(accounts[9]), web3.utils.toWei("0"));

        assert.isTrue(await cDAOAdmins1.checkEligibility.call(accounts[7])); 
        assert.isTrue(await cDAOAdmins1.checkEligibility.call(accounts[8])); 
        assert.isTrue(await cDAOAdmins1.checkEligibility.call(accounts[9]));
    })
    it("Test Member eligibility at Snap", async() => {
        const proposalNames = ['OUI','NON','ABSTENTION'];
        const ballotManagerDeployed = await BallotsManager.deployed();
        const capitalManager = await CapitalManager.deployed();
        const cDAOAdmins1= await CDAOAdmins.deployed();
        const batchManager1 = await BatchManager.deployed();

        const batch1 = await Batch.at(await batchManager1.getBatch.call(0));

        await ballotManagerDeployed.initialiseNewBallot('Ballot TEST 1', proposalNames, {from : accounts[0]});
        const ballotCreated1 = await Ballot.at(await ballotManagerDeployed.getBallot.call(0));
        
        assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[5]));
        await ballotCreated1.takeSnapshop({from : accounts[0]});

        await capitalManager.redistributeToOldInvestor([accounts[5]], [web3.utils.toWei("300")], 0, {from : accounts[0]})
        const snapId = (await ballotCreated1.snapshopsId.call()).toString();
        console.log(snapId);
        console.log(batch1.address);
        console.log((await cDAOAdmins1.getSnapshopFor.call(snapId, batch1.address)).toString());
        assert.isFalse(await cDAOAdmins1.checkEligibility.call(accounts[5], snapId, "0x0000000000000000000000000000000000000000", { from : accounts[0]})); // avec le snap account 5 n'est  pas eligible 
        assert.isTrue(await cDAOAdmins1.checkEligibility.call(accounts[5])); // sans le snap account 5 est eligible 
    });
});
