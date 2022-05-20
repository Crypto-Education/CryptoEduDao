const CDAOAdmins = artifacts.require("CDAOAdmins");
const { async } = require("q");
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

        await cDAOAdmins.grantAdmin(accounts[2], {from : accounts[0]});
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
    });

    it("Test Member eligibility", async() => {
        const instance = await CDAOAdmins.deployed();
        assert.equal(
            await instance.checkEligibility.call(accounts[0]),
            false
            );
        
    })
});
