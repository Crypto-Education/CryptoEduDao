const CECAToken = artifacts.require("CECAToken")
const FBusd = artifacts.require("FBusd")

const CDAOAdmins = artifacts.require("CDAOAdmins")

const CapitalManager = artifacts.require("CapitalManager")
const IdoManager = artifacts.require("IdoManager")
const BatchManager = artifacts.require("BatchManager")
const BallotsManager = artifacts.require("BallotsManager")



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

            /**
             * Settings
             */
            // pass minterShip to Capital Manager
            await cecaToken.passMinterRole(capitalManager.address, {from: accounts[0]})
            await cdaoAdmins.setIdoMainAddress(addressesList.testnet.idoMainAddress, {from: accounts[0]})
            await cdaoAdmins.setIdoReceiverAddress( addressesList.testnet.idoBusdAddress, {from: accounts[0]})
            await cdaoAdmins.setTeamAddress(addressesList.testnet.teamAddress, {from: accounts[0]})
            await cdaoAdmins.setMainCapitalAddress(addressesList.testnet.capitalDeposit, {from: accounts[0]})
            await cdaoAdmins.setCapitalToken(cecaToken.address, {from: accounts[0]})
            await cdaoAdmins.setCapitalManagerByAdmin(capitalManager.address, {from: accounts[0]})
            await cdaoAdmins.setIdoManagerByAdmin(idoManager.address, {from: accounts[0]})
            await cdaoAdmins.setBatchManagerByAdmin(batchManager.address, {from: accounts[0]})
            await cdaoAdmins.setBallotManagerByAdmin(ballotsManager.address, {from: accounts[0]})

            await batchManager.createAppendBatch("Batch 0 |Capital Initial", false, {from: accounts[0]})
            
            break;

        case "bsc":
            // Deploy CryptoEduCapitalToken
            await deployer.deploy(CryptoEduCapitalToken)
            cryptoEduCapitalToken = await CryptoEduCapitalToken.deployed()

            await deployer.deploy(CryptoEduFarmToken)
            const cryptoEduFarmToken = await CryptoEduFarmToken.deployed()

            await deployer.deploy(CapitalManager,
                cryptoEduCapitalToken.address,
                addressesList.mainnet.busd,
                addressesList.mainnet.capitalDeposit)
            capitalManager = await CapitalManager.deployed()

            await deployer.deploy(BatchCreator, capitalManager.address, addressesList.mainnet.busd, addressesList.mainnet.capitalDeposit)
            batchCreator = await BatchCreator.deployed()

            await capitalManager.setBatchCreatorAddress(batchCreator.address)

            //change token's owner/minter from deployer to capitalManager
            await cryptoEduCapitalToken.passMinterRole(capitalManager.address)

            await deployer.deploy(IdoCryptoEduManager,
                capitalManager.address,
                cryptoEduCapitalToken.address,
                addressesList.mainnet.busd,
                addressesList.mainnet.idoMainAddress,
                addressesList.mainnet.idoBusdAddress,
                addressesList.mainnet.teamAddress
            )
            idoCryptoEduManager = await IdoCryptoEduManager.deployed()
            await batchCreator.createAppendBatch("Batch 0 |Capital Initial", false, {from: accounts[0]})

            await deployer.deploy(BallotsManager, capitalManager.address)
            ballotsManager = BallotsManager.deployed()
            break;
    }
}