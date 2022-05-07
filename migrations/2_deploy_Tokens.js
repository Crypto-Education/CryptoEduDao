const CECAToken = artifacts.require("CECAToken")
const FBusd = artifacts.require("FBusd")

const CDAOAdmins = artifacts.require("CDAOAdmins")

const CapitalManager = artifacts.require("CapitalManager")
const IdoManager = artifacts.require("IdoManager")
const BatchManager = artifacts.require("BatchManager")
const BallotsManager = artifacts.require("BallotsManager")
const MigrationV1V2 = artifacts.require("MigrationV1V2")



const addressesList = {
    mainnet : {
        busd: "0xe9e7cea3dedca5984780bafc599bd69add087d56",
        capitalDeposit: "0xE820cf29813939d84160FEbe5Aa1bd52422b1366",
        idoMainAddress: "0xA6A97c85Bd58B4ABd5d5578b4221c8c80B9aB382",
        idoBusdAddress: "0xD7AcE5005CE05f7e4F63331cd384c4E49B850C1e",
        teamAddress: "0x9B3a3Cc32645D845a25e3c07e9EeC02c2528331b"
    },
    testnet : {
        busd: '0xe9e7cea3dedca5984780bafc599bd69add087d56',
        capitalDeposit: '0x4328335Cbe74D1fC60b5011954076534D7244494',
        idoMainAddress: '0x4328335Cbe74D1fC60b5011954076534D7244494',
        idoBusdAddress: '0x4328335Cbe74D1fC60b5011954076534D7244494',
        teamAddress: '0x9B3a3Cc32645D845a25e3c07e9EeC02c2528331b'
    }
}



module.exports = async function (deployer, network, accounts) {

    let cecaToken;
    let cdaoAdmins;
    let fbusdToken;
    let capitalManager;
    let batchManager
    let idoManager;
    let ballotsManager;
    let migrationV1V2;

    switch (network) {
        case "development":
        case "testnet":
            // Deploy CDAOAdmins
            await deployer.deploy(CDAOAdmins)
            cdaoAdmins = await CDAOAdmins.deployed()

            /**
             * deploy tokens
             */
            await deployer.deploy(CECAToken)
            cecaToken = await CECAToken.deployed()

            await deployer.deploy(FBusd)
            fbusdToken = await FBusd.deployed()

            /**
             * deplo managers
             */
            await deployer.deploy(CapitalManager, cecaToken.address, cdaoAdmins.address)
            capitalManager = await CapitalManager.deployed()

            await deployer.deploy(BatchManager, cdaoAdmins.address)
            batchManager = await BatchManager.deployed()

            await deployer.deploy(IdoManager, cdaoAdmins.address)
            idoManager = await IdoManager.deployed()

            await deployer.deploy(BallotsManager, cdaoAdmins.address)
            ballotsManager = await BallotsManager.deployed()

            await deployer.deploy(MigrationV1V2, cdaoAdmins.address)
            migrationV1V2 = await MigrationV1V2.deployed()


            /**
             * Settings
             */
            // pass minterShip to Capital Manager
            await cecaToken.passMinterRole(capitalManager.address, {from: accounts[0]})
            /**Set accepted tokens Stable coins only */
            await cdaoAdmins.addAcceptedTokens(fbusdToken.address, {from: accounts[0]})
            /**Set Dao Addresses for diferent purpuse */
            await cdaoAdmins.setIdoMainAddress(addressesList.testnet.idoMainAddress, {from: accounts[0]})
            await cdaoAdmins.setIdoReceiverAddress( addressesList.testnet.idoBusdAddress, {from: accounts[0]})
            await cdaoAdmins.setTeamAddress(addressesList.testnet.teamAddress, {from: accounts[0]})
            await cdaoAdmins.setMainCapitalAddress(addressesList.testnet.capitalDeposit, {from: accounts[0]})
            /**Set token */
            await cdaoAdmins.setCapitalToken(cecaToken.address, {from: accounts[0]})
            /**Set managers */
            await cdaoAdmins.setCapitalManagerByAdmin(capitalManager.address, {from: accounts[0]})
            await cdaoAdmins.setIdoManagerByAdmin(idoManager.address, {from: accounts[0]})
            await cdaoAdmins.setBatchManagerByAdmin(batchManager.address, {from: accounts[0]})
            await cdaoAdmins.setBallotManagerByAdmin(ballotsManager.address, {from: accounts[0]})
            /**Set Migratot Contract */
            await cdaoAdmins.setMigratorV1V2(migrationV1V2.address, {from: accounts[0]})
            /** Set Old contracts for migration from V1 */
            await cdaoAdmins.setOldCapitalToken(ballotsManager.address, {from: accounts[0]})
            await cdaoAdmins.setOldCeCaBatch(ballotsManager.address, {from: accounts[0]})
            await cdaoAdmins.setOldCapitalManager(ballotsManager.address, {from: accounts[0]})

            /**Initialise data contracts */
            await batchManager.createAppendBatch("Batch 0 |Capital Initial", false, {from: accounts[0]})
            await batchManager.createAppendBatch("Batch 1 |Partisia Blockchain", false, {from: accounts[0]})
            
            break;

        case "bsc":
            // To do later
            break;
    }
}