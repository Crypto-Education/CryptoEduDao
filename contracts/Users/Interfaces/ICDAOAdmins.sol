// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "../../Tokens/CryptoEduDaoToken.sol";
import "../../Managers/Interfaces/IBatchManager.sol";
import "../../Managers/Interfaces/IIdoManager.sol";
import "../../Managers/Interfaces/ICapitalManager.sol";
import "../../Managers/Interfaces/IBallotsManager.sol";
import "./V1Interfaces.sol";

interface ICDAOAdmins {

    function grantAdmin(address _userAddr) external ;

    function isAdmin(address _userAddr) view external returns (bool);

    function isSuperAdmin(address _userAddr) view external returns (bool) ;


    function removerGrantAdmin(address _userAddr) external ;

    function changeSuperAdmin(address _userAddr) external ;
    /**
     * @dev Returns the address of the current owner.
     */
    function superAdmin() external view returns (address);
    /**
     * manage Daos addresses
     */
    function getIdoMainAddress() external view returns (address) ;

    function getIdoReceiverAddress() external view returns (address);

    function getTeamAddress() external view returns (address);

    function getMainCapitalAddress() external view returns (address);
    
    function getCapitalToken(address relatedBatch) external view returns (ISERC20);

    function getCUSDToken() external view returns (ISERC20);
    
    function getDaoToken() external view returns (CryptoEduDaoToken);

    function getTransactionFeesPerBatch() external view returns (uint256);
    /**
        Old contract from V1
     */
    function getOldCapitalToken() external view returns (IERC20);
    function getOldCeCaBatch()  external view returns (OldCeCaBatch);
    function getOldCapitalManager() external view returns (OldCapitalManager);
    function getMigratorV1V2()  external view returns (address);


    /**
     * Managers
     */
    function getCapitalManager() external view returns (ICapitalManager);

    function getIdoManager() external view returns (IIdoManager);

    function getBatchManager() external view returns(IBatchManager);

    function getBallotsManager() external view returns(IBallotsManager);

    function getEligibilityThreshold() external view returns(uint256);

    /**
     * add accepted cryptos as payment
     */
    function addAcceptedTokens(address _addr) external;

    function removeAcceptedTokens(address _addr) external;

    function tokenIsAccepted(address _token) external view returns (bool);
    
    function addAcceptedIdoTokens(address _addr) external;

    function removeAcceptedIdoTokens(address _addr) external;

    function tokenIsAcceptedIdo(address _token) external view returns (bool);
    
    function checkEligibility(address _user) external view returns (bool);

    function checkEligibility(address _user, uint _snap, address _batchId) external returns (bool);

    function createCecaTokenForBatch(address _batch, uint _index) external;

    function takeSnapshop(uint _snapshopsId) external;

    function getSnapshopFor(uint _snapshopsId, address _batch) view external returns(uint256);
}
