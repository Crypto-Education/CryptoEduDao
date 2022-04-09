const CryptoEduCapitalToken = artifacts.require("CryptoEduCapitalToken")
const FarmToken = artifacts.require("CryptoEduFarmToken")
const FBusd = artifacts.require("FBusd")
const CryptoEduFarmToken = artifacts.require("CryptoEduFarmToken")
const CapitalManager = artifacts.require("CapitalManager")
const IdoCryptoEduManager = artifacts.require("IdoCryptoEduManager")
const BatchCreator = artifacts.require("BatchCreator")
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

    let cryptoEduCapitalToken;
    let farmToken;
    let fbusdToken;
    let capitalManager;
    let batchCreator
    let idoCryptoEduManager;
    let ballotsManager;

    switch (network) {
        case "development":
        case "testnet":
            // Deploy CryptoEduCapitalToken
            await deployer.deploy(CryptoEduCapitalToken)
            cryptoEduCapitalToken = await CryptoEduCapitalToken.deployed()

            await deployer.deploy(FarmToken)
            farmToken = await FarmToken.deployed()

            await deployer.deploy(FBusd)
            fbusdToken = await FBusd.deployed()

            await deployer.deploy(CapitalManager, cryptoEduCapitalToken.address, fbusdToken.address, addressesList.testnet.capitalDeposit)
            capitalManager = await CapitalManager.deployed()

            await deployer.deploy(BatchCreator, capitalManager.address, fbusdToken.address, addressesList.testnet.capitalDeposit)
            batchCreator = await BatchCreator.deployed()

            await capitalManager.setBatchCreatorAddress(batchCreator.address)

            await cryptoEduCapitalToken.passMinterRole(capitalManager.address)

            await deployer.deploy(IdoCryptoEduManager,
                capitalManager.address,
                cryptoEduCapitalToken.address,
                fbusdToken.address,
                addressesList.testnet.idoMainAddress,
                addressesList.testnet.idoBusdAddress,
                addressesList.testnet.teamAddress
            )
            idoCryptoEduManager = await IdoCryptoEduManager.deployed()
            batchCreator.createAppendBatch("Batch 0 |Capital Initial", false, {from: accounts[0]})

            await deployer.deploy(BallotsManager, capitalManager.address)
            ballotsManager = BallotsManager.deployed()
            /*await ballotsManager.initialiseNewBallot("Objectif du nouveau Batch (Batch 01)",
                ["200.000 Tropad", "25.000$ Pour L'ico de Particia Network", "Avoir les MEX pour Maiar", "Autres"]
            );*/
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