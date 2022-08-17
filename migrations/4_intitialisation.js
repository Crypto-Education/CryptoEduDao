const CECAToken = artifacts.require("CECAToken")
const CryptoEduDaoToken = artifacts.require("CryptoEduDaoToken")

const FBusd = artifacts.require("FBusd")

const CDAOAdmins = artifacts.require("CDAOAdmins")

const CapitalManager = artifacts.require("CapitalManager")
const IdoManager = artifacts.require("IdoManager")
const BatchManager = artifacts.require("BatchManager")
const BallotsManager = artifacts.require("BallotsManager")
const CecaFarming = artifacts.require("CecaFarming")

const MigrationV1V2 = artifacts.require("MigrationV1V2")






module.exports = async function (deployer, network, accounts) {

    
    const addressesList = {
        mainnet : {
            busd: "0xe9e7cea3dedca5984780bafc599bd69add087d56",
            capitalDeposit   : "0xE820cf29813939d84160FEbe5Aa1bd52422b1366",
            idoMainAddress   : "0xA6A97c85Bd58B4ABd5d5578b4221c8c80B9aB382",
            idoBusdAddress   : "0xD7AcE5005CE05f7e4F63331cd384c4E49B850C1e",
            teamAddress      : "0x9B3a3Cc32645D845a25e3c07e9EeC02c2528331b",
            oldCapitalToken  : "0xD5A26B2c4856F0eB6d3a8f1237152BACC70d4f31",
            oldCecaBatch     : "0x2db3c0F4172e009d478D399ee12CDBA68875DebE",
            oldCapitalManager: "0x4c5d6141Ff4BF563779B8547349219804D31Ad68",
        },
        testnet : {
            busd: '0xe9e7cea3dedca5984780bafc599bd69add087d56',
            capitalDeposit   : '0x4328335Cbe74D1fC60b5011954076534D7244494', // account 9
            idoMainAddress   : '0x4328335Cbe74D1fC60b5011954076534D7244494',
            idoBusdAddress   : '0x4328335Cbe74D1fC60b5011954076534D7244494',
            teamAddress      : '0x4328335Cbe74D1fC60b5011954076534D7244494',
            oldCapitalToken  : "0xD5A26B2c4856F0eB6d3a8f1237152BACC70d4f31",
            oldCecaBatch     : "0x2db3c0F4172e009d478D399ee12CDBA68875DebE",
            oldCapitalManager: "0x4c5d6141Ff4BF563779B8547349219804D31Ad68",
        }
    }

    let cecaToken;
    let cryptoEduDaoToken;
    let cdaoAdmins;
    let fbusdToken;
    let capitalManager;
    let batchManager
    let idoManager;
    let ballotsManager;
    let cecaFarming;
    let redistribute;
    let migrationV1V2;

    switch (network) {
        case "development":
        case "bsc_testnet":
        case "kcc_testnet":
        case "poly_testnet":
        case "aur_testnet":
            // Deploy CDAOAdmins
            /*cdaoAdmins = await CDAOAdmins.deployed()
            fbusdToken = await FBusd.deployed()
            capitalManager = await CapitalManager.deployed()
            batchManager = await BatchManager.deployed()
            idoManager = await IdoManager.deployed()
            ballotsManager = await BallotsManager.deployed()
            cecaFarming = await CecaFarming.deployed()*/

            //await cdaoAdmins.addAcceptedTokens(fbusdToken.address, {from: accounts[0]})
            /**Set Dao Addresses for diferent purpuse */
            /***await cdaoAdmins.setIdoMainAddress(addressesList.testnet.idoMainAddress, {from: accounts[0]})
            await cdaoAdmins.setIdoReceiverAddress( addressesList.testnet.idoBusdAddress, {from: accounts[0]})
            await cdaoAdmins.setTeamAddress(addressesList.testnet.teamAddress, {from: accounts[0]})
            await cdaoAdmins.setMainCapitalAddress(addressesList.testnet.capitalDeposit, {from: accounts[0]})***/
            /**Set token */
            //await cdaoAdmins.setCapitalToken(cecaToken.address, {from: accounts[0]})
            //await cdaoAdmins.setDaoToken(cryptoEduDaoToken.address, {from: accounts[0]})
            /**Set managers */
            /***await cdaoAdmins.setCapitalManagerByAdmin(capitalManager.address, {from: accounts[0]})
            await cdaoAdmins.setIdoManagerByAdmin(idoManager.address, {from: accounts[0]})
            await cdaoAdmins.setBatchManagerByAdmin(batchManager.address, {from: accounts[0]})
            await cdaoAdmins.setBallotManagerByAdmin(ballotsManager.address, {from: accounts[0]})***/
            /**Set Migratot Contract */
            //await cdaoAdmins.setMigratorV1V2(migrationV1V2.address, {from: accounts[0]})
            /** Set Old contracts for migration from V1 */
            /*await cdaoAdmins.setOldCapitalToken(addressesList.testnet.oldCapitalToken, {from: accounts[0]})
            await cdaoAdmins.setOldCeCaBatch(addressesList.testnet.oldCecaBatch, {from: accounts[0]})
            await cdaoAdmins.setOldCapitalManager(addressesList.testnet.oldCapitalManager, {from: accounts[0]})*/

            /**Initialise data contracts */
            /***await batchManager.createAppendBatch("Batch 0 |Capital Initial", true, {from: accounts[0]})
            await batchManager.createAppendBatch("Batch 1 |Partisia Blockchain", true, {from: accounts[0]})***/
            
            break;

        case "bsc":
            // To do later
            break;
    }
}