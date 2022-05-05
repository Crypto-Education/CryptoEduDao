// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./Interfaces/ICDAOAdmins.sol";
import "../Managers/Interfaces/ICapitalManager.sol";
import "../Managers/Interfaces/IBatchManager.sol";

abstract contract CeEduOwnable {
    ICDAOAdmins private _adminSetting;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor (address _adminAddress) {
        _adminSetting = ICDAOAdmins(_adminAddress);
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

    function getAdminSetting() public view returns(ICDAOAdmins) {
        return _adminSetting;
    }
}
