// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../../Managers/Interfaces/IBatchManager.sol";
import "../../Managers/Interfaces/IIdoManager.sol";
import "../../Managers/Interfaces/ICapitalManager.sol";
import "../../Managers/Interfaces/IBallotsManager.sol";

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
    
    function getCapitalToken() external view returns (IERC20);

    function getTransactionFeesPerBatch() external view returns (uint256);
    /**
     * Managers
     */
    function getCapitalManager() external view returns (ICapitalManager);

    function getIdoManager() external view returns (IIdoManager);

    function getBatchManager() external view returns(IBatchManager);

    function getBallotsManager() external view returns(IBallotsManager);

    function getEligibilityThreshold() external view returns(uint256);
    /** Setters
     */
    function setIdoMainAddress(address _addr) external;

    function setIdoReceiverAddress(address _addr) external ;

    function setTeamAddress(address _addr) external ;

    function setMainCapitalAddress(address _addr) external ;


    function setCapitalToken(IERC20 _addr) external;


    function setCapitalManager(ICapitalManager _addr) external ;

    function setCapitalManagerByAdmin(ICapitalManager _addr) external;

    function setIdoManager(IIdoManager _addr) external;

    function setIdoManagerByAdmin(IIdoManager _addr) external;

    function setBatchManager(IBatchManager _addr) external;

    function setBatchManagerByAdmin(IBatchManager _addr) external ;

    function setTransactionFeesPerBatch(uint256 _transactionFeesPerBatch) external;
    
    function setEligibilityThreshold(uint256 _eligibilityThreshold) external ;

    function setBallotManagerByAdmin(IBallotsManager _addr) external ;

    /**
     * add accepted cryptos as payment
     */
    function addAcceptedTokens(address _addr) external;

    function removeAcceptedTokens(address _addr) external;

    function tokenIsAccepted(address _token) external view returns (bool);
    
    function checkEligibility(address _user) external view returns (bool);
}
