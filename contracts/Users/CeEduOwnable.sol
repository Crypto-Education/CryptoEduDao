// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./CDAOAdmins.sol";
import "../Tokens/CECAToken.sol";
import "../Managers/Interfaces/ICapitalManager.sol";
import "../Managers/Interfaces/IBatchManager.sol";

abstract contract CeEduOwnable {
    CDAOAdmins private _adminSetting;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (address _adminAddress) {
        _adminSetting = CDAOAdmins(_adminAddress);
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlySuperAdmin() {
        require(_adminSetting.isSuperAdmin(msg.sender), "CDAOAdmins: caller is not the superadmin");
        _;
    }

    modifier onlyAdmin() {
        require(_adminSetting.isAdmin(msg.sender) || _adminSetting.isSuperAdmin(msg.sender), "CDAOAdmins: caller is neither an admin nor superadmin");
        _;
    }

    modifier isBatchManager() {
        require(msg.sender == address(_adminSetting.getBatchManager()));
        _;
    }

    function isSuperAdmin() public view returns(bool) {
        return _adminSetting.isSuperAdmin(msg.sender);
    }
    function getAdminSetting() public view returns(CDAOAdmins) {
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

    function getCapitalToken() public view returns (IERC20) {
        return _adminSetting.getCapitalToken();
    }


    function getCapitalManager() public view onlySuperAdmin returns (ICapitalManager) {
        return _adminSetting.getCapitalManager();
    }

    function getIdoManager() public view returns(IIdoManager) {
        return _adminSetting.getIdoManager();
    }

    function getCapitalManagerAddress() public view returns(address) {
        return address(_adminSetting.getCapitalManager());
    }

    function getTransactionFeesPerBatch() public view returns(uint256) {
        return _adminSetting.getTransactionFeesPerBatch();
    }

    function tokenIsAccepted(address _token) public view returns(bool) {
        return _adminSetting.tokenIsAccepted(_token);
    }

    function checkEligibility(address sender) virtual public returns(bool) {
        return _adminSetting.getBatchManager().checkEligibility(sender);
    }

    function getEligibilityThreshold() public view returns(uint256){
        return _adminSetting.getEligibilityThreshold();
    }
}
