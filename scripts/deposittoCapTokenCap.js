/*const CryptoEduCapitalToken = artifacts.require("CryptoEduCapitalToken")
const CryptoEduCryptoEduFarmToken = artifacts.require("CryptoEduCryptoEduFarmToken")
	
module.exports = async function (callback) {
    myToken = await CryptoEduCapitalToken.deployed()
    farmToken = await CryptoEduCryptoEduFarmToken.deployed()
    balance = await myToken.balanceOf(farmToken.address)
    console.log(web3.utils.fromWei(balance.toString()))
    callback()
}*/
/*
const CryptoEduCapitalToken = artifacts.require("CryptoEduCapitalToken")
const CryptoEduFarmToken = artifacts.require("CryptoEduFarmToken")

module.exports = async function (callback) {
    const accounts = await new web3.eth.getAccounts()
    const myToken = await CryptoEduCapitalToken.deployed()
    const farmToken = await CryptoEduFarmToken.deployed()

    // Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner through transferFrom.
    // This is zero by default.
    const allowanceBefore = await myToken.allowance(
        accounts[0],
        farmToken.address
    )
    console.log(
    "Amount of CryptoEduCapitalToken CryptoEduFarmToken is allowed to transfer on our behalf Before: " +
        allowanceBefore.toString()
    )

    // In order to allow the Smart Contract to transfer to CryptoEduCapitalToken (ERC-20) on the accounts[0] behalf,
    // we must explicitly allow it.
    // We allow farmToken to transfer x amount of CryptoEduCapitalToken on our behalf
    await myToken.approve(farmToken.address, web3.utils.toWei("100", "ether"))

    // Validate that the farmToken can now move x amount of CryptoEduCapitalToken on our behalf
    const allowanceAfter = await myToken.allowance(accounts[0], farmToken.address)
    console.log(
    "Amount of CryptoEduCapitalToken CryptoEduFarmToken is allowed to transfer on our behalf After: " +
        allowanceAfter.toString()
    )

    // Verify accounts[0] and farmToken balance of CryptoEduCapitalToken before and after the transfer
    balanceCryptoEduCapitalTokenBeforeAccounts0 = await myToken.balanceOf(accounts[0])
    balanceCryptoEduCapitalTokenBeforeCryptoEduFarmToken = await myToken.balanceOf(farmToken.address)
    console.log("*** My Token ***")
    console.log(
    "Balance CryptoEduCapitalToken Before accounts[0] " +
        web3.utils.fromWei(balanceCryptoEduCapitalTokenBeforeAccounts0.toString())
    )
    console.log(
    "Balance CryptoEduCapitalToken Before TokenFarm " +
        web3.utils.fromWei(balanceCryptoEduCapitalTokenBeforeCryptoEduFarmToken.toString())
    )

    console.log("*** Farm Token ***")
    balanceCryptoEduFarmTokenBeforeAccounts0 = await farmToken.balanceOf(accounts[0])
    balanceCryptoEduFarmTokenBeforeCryptoEduFarmToken = await farmToken.balanceOf(farmToken.address)
    console.log(
    "Balance CryptoEduFarmToken Before accounts[0] " +
        web3.utils.fromWei(balanceCryptoEduFarmTokenBeforeAccounts0.toString())
    )
    console.log(
    "Balance CryptoEduFarmToken Before TokenFarm " +
        web3.utils.fromWei(balanceCryptoEduFarmTokenBeforeCryptoEduFarmToken.toString())
    )
    // Call Deposit function from CryptoEduFarmToken
    console.log("Call Deposit Function")
    await farmToken.deposit(web3.utils.toWei("100", "ether"))
    console.log("*** My Token ***")
    balanceCryptoEduCapitalTokenAfterAccounts0 = await myToken.balanceOf(accounts[0])
    balanceCryptoEduCapitalTokenAfterCryptoEduFarmToken = await myToken.balanceOf(farmToken.address)
    console.log(
    "Balance CryptoEduCapitalToken After accounts[0] " +
        web3.utils.fromWei(balanceCryptoEduCapitalTokenAfterAccounts0.toString())
    )
    console.log(
    "Balance CryptoEduCapitalToken After TokenFarm " +
        web3.utils.fromWei(balanceCryptoEduCapitalTokenAfterCryptoEduFarmToken.toString())
    )

    console.log("*** Farm Token ***")
    balanceCryptoEduFarmTokenAfterAccounts0 = await farmToken.balanceOf(accounts[0])
    balanceCryptoEduFarmTokenAfterCryptoEduFarmToken = await farmToken.balanceOf(farmToken.address)
    console.log(
    "Balance CryptoEduFarmToken After accounts[0] " +
        web3.utils.fromWei(balanceCryptoEduFarmTokenAfterAccounts0.toString())
    )
    console.log(
    "Balance CryptoEduFarmToken After TokenFarm " +
        web3.utils.fromWei(balanceCryptoEduFarmTokenAfterCryptoEduFarmToken.toString())
    )

    // End function
    callback()
}
*/

const CryptoEduCapitalToken = artifacts.require("CryptoEduCapitalToken")
const CapitalManager = artifacts.require("CapitalManager")

module.exports = async function (callback) {
    const accounts = await new web3.eth.getAccounts()
    myToken = await CryptoEduCapitalToken.deployed()
    capitalManager = await CapitalManager.deployed()

    user1 = accounts[0]
    user2 = accounts[1]
    user3 = accounts[2]

    //allowanceBefore = await myToken.allowance(accounts[0], capitalManager.address)
    //console.log(allowanceBefore.toString())
    //await capitalManager.initialiseNewBatch("First Batch", "Descriptionnnnnnn");

    await myToken.approve(capitalManager.address, web3.utils.toWei("1000", "ether"))
    await capitalManager.depositInCapital(web3.utils.toWei("10", "ether"));
    console.log(user1)

/*
    /!*console.log(
        "Amount of MyToken FarmToken is allowed to transfer on our behalf Before: " +
          allowanceBefore.toString()
    )
*!/
    await myToken.approve(capitalManager.address, web3.utils.toWei(balance.toString(), "ether"))
    await myToken.approve(owner, web3.utils.toWei(balance.toString(), "ether"))

    // Validate that the farmToken can now move x amount of MyToken on our behalf
    allowanceAfter = await myToken.allowance(owner, capitalManager.address)
    /!*console.log(
        "Amount of MyToken FarmToken is allowed to transfer on our behalf After: " +
        allowanceAfter.toString()
    )*!/

    //console.log("---------Balance of Owner of Cap -------------")
    balance = await myToken.balanceOf(owner)
    //console.log(web3.utils.fromWei(balance.toString()))




    await myToken.transfer(capitalManager.address, balance.toString())
    balance = await myToken.balanceOf(capitalManager.address)
    console.log(web3.utils.fromWei(balance.toString()))

    await myToken.approve(capitalManager.address, web3.utils.toWei(balance.toString(), "ether"))
    allowanceAfter = await myToken.allowance(capitalManager.address, capitalManager.address)

    user2 = '0x8472Bd377E33F71503457096C48981913FfC427e'
    await myToken.transferFrom(capitalManager.address, user2, 100)

    /!*await capitalManager.redistributeToOldInvestor([user2], [100000])*!/

    balance = await myToken.balanceOf(user2)
    //console.log(web3.utils.fromWei(balance.toString()))*/

    callback()
}
