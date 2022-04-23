// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./CDAOAdmins.sol";

abstract contract CeEduOwnable {
    CDAOAdmins private _adminSetting;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (CDAOAdmins _adminAddress) {
        _adminSetting = _adminAddress;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlySuperAdmin() {
        require(_adminSetting.isSuperAdmin(msg.sender), "CDAOAdmins: caller is not the superadmin");
        _;
    }

    modifier onlyAdmin() {
        require(_adminSetting.isAdmin(msg.sender) || _adminManager.isSuperAdmin(msg.sender), "CDAOAdmins: caller is neither an admin nor superadmin");
        _;
    }

    function isSuperAdmin() public returns(bool) {
        return _adminSetting.isSuperAdmin(msg.sender);
    }
    function getAdminSetting() internal returns(CDAOAdmins) {
        return _adminSetting;
    }

    /**
     * manage Daos addresses
     */
    function getIdoMainAddress() public view returns (address) {
        return _adminSetting.getIdoMainAddress();
    }

    function getIdoReceiverAddress() public view returns (address) {
        return _adminSetting.getIdoReceiverAddress();
    }

    function getTeamAddress() public view returns (address){
        return _adminSetting.getTeamAddress();
    }

    function getMainCapitalAddress() public view returns (address){
        return _adminSetting.getMainCapitalAddress();
    }

    function getCapitalToken() public returns (CECAToken) {
        return _adminSetting.getCapitalToken();
    }


    function getCapitalManager() public onlySuperAdmin returns (CapitalManager) {
        return _adminSetting.getCapitalManager();
    }

    function getIdoManager() public returns(IdoManager) {
        return _adminSetting.getIdoManager();
    }

    function getCapitalManagerAddress() public returns(address) {
        return address(_adminSetting.getCapitalManager());
    }

    function getTransactionFeesPerBatch() public {
        return _adminSetting.getTransactionFeesPerBatch();
    }

    function tokenIsAccepted(address _token) public view returns(bool) {
        return _adminSetting.tokenIsAccepted(_token);
    }

    function checkEligibility(address sender) public returns(bool) {
        CapitalManager capitalManager = _adminSetting.getCapitalManager();
        return capitalManager.checkEligibility(sender);
    }
}
