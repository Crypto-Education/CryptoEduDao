// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Managers/Interfaces/IBatchManager.sol";
import "../Managers/Interfaces/IIdoManager.sol";
import "../Managers/Interfaces/ICapitalManager.sol";
import "../Managers/Interfaces/IBallotsManager.sol";

contract CDAOAdmins {
    using Address for address;
    using SafeERC20 for IERC20;

    address private _superAdmin;
    mapping(address => bool) private _adminGrantList;



    uint256 public eligibilityThreshold = 100 ether; 
    uint256 public transactionFeesPerBatch = 0.25 ether; // for ido participation fees
    /**
    * all DAOs  address for different purposes
    */
    address private idoMainAddress; // address eligible for ICO used on BSCPAD AND Other launchpads
    address private idoReceiverAddress; // address to receive IDO amount / when users contributes
    address private teamAddress; // address to receive IDO amount
    address public mainCapitalAddress; // address to receive all capital deposited

    IERC20 public capitalToken;
    ICapitalManager public capitalManager;
    IIdoManager private idoManager;
    IBatchManager private batchManager;
    IBallotsManager private ballotManager;

    mapping(address => bool) public acceptedTokens;

    event OwnershipGranted(address indexed newOwner);
    event OwnershipRemoved(address indexed newOwner);
    event SuperOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _superAdmin = msgSender;
        emit SuperOwnershipTransferred(address(0), msgSender);
    }
    /**
         * @dev Throws if called by any account other than the owner.
         */
    modifier onlySuperAdmin() {
        require(superAdmin() == msg.sender, "CDAOAdmins: caller is not the superadmin");
        _;
    }

    modifier onlyAdmin() {
        require(superAdmin() == msg.sender || _adminGrantList[msg.sender], "CDAOAdmins: caller is neither an admin nor superadmin");
        _;
    }


    function grantAdmin(address _userAddr) public onlySuperAdmin {
        _adminGrantList[_userAddr] = true;
        emit OwnershipGranted(_userAddr);
    }

    function isAdmin(address _userAddr) view public returns (bool) {
        return _adminGrantList[_userAddr];
    }

    function isSuperAdmin(address _userAddr) view public returns (bool) {
        return _userAddr == _superAdmin;
    }


    function removerGrantAdmin(address _userAddr) public onlySuperAdmin {
        _adminGrantList[_userAddr] = false;
        emit OwnershipRemoved(_userAddr);
    }

    function changeSuperAdmin(address _userAddr) public onlySuperAdmin {
        require(isAdmin(_userAddr), "New user most be an administrator");
        _superAdmin = _userAddr;
        emit SuperOwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function superAdmin() public view returns (address) {
        return _superAdmin;
    }

    /**
     * manage Daos addresses
     */
    function getIdoMainAddress() public view returns (address) {
        return idoMainAddress;
    }

    function getIdoReceiverAddress() public view returns (address) {
        return idoReceiverAddress;
    }

    function getTeamAddress() public view returns (address){
        return teamAddress;
    }

    function getMainCapitalAddress() public view returns (address){
        return mainCapitalAddress;
    }

    function getCapitalToken() public view returns (IERC20) {
        return capitalToken;
    }

    function getTransactionFeesPerBatch() public view returns (uint256){
        return transactionFeesPerBatch;
    }

    /**
     * Managers
     */
    function getCapitalManager() public view returns (ICapitalManager) {
        return capitalManager;
    }

    function getIdoManager() public view returns (IIdoManager) {
        return idoManager;
    }

    function getBatchManager() public view returns(IBatchManager) {
        return batchManager;
    }

    function getBallotsManager() public view returns(IBallotsManager) {
        return ballotManager;
    }

    function getEligibilityThreshold() public view returns(uint256){
        return eligibilityThreshold;
    }
    /** Setters
     */
    function setIdoMainAddress(address _addr) public onlySuperAdmin {
        idoMainAddress = _addr;
    }

    function setIdoReceiverAddress(address _addr) public onlySuperAdmin {
        idoReceiverAddress = _addr;
    }

    function setTeamAddress(address _addr) public onlySuperAdmin {
        teamAddress = _addr;
    }

    function setMainCapitalAddress(address _addr) public onlySuperAdmin {
        mainCapitalAddress = _addr;
    }


    function setCapitalToken(IERC20 _addr) public onlySuperAdmin {
        capitalToken = _addr;
    }


    function setCapitalManager(ICapitalManager _addr) internal {
        capitalManager = _addr;
    }

    function setCapitalManagerByAdmin(ICapitalManager _addr) public onlySuperAdmin {
        capitalManager = _addr;
    }

    function setIdoManager(IIdoManager _addr) internal {
        idoManager = _addr;
    }

    function setIdoManagerByAdmin(IIdoManager _addr) public onlySuperAdmin {
        idoManager = _addr;
    }

    function setBatchManager(IBatchManager _addr) internal {
        batchManager = _addr;
    }

    function setBatchManagerByAdmin(IBatchManager _addr) public onlySuperAdmin {
        batchManager = _addr;
    }

    function setTransactionFeesPerBatch(uint256 _transactionFeesPerBatch) public onlySuperAdmin {
        transactionFeesPerBatch = _transactionFeesPerBatch;
    }
    
    function setEligibilityThreshold(uint256 _eligibilityThreshold) public onlySuperAdmin {
        eligibilityThreshold = _eligibilityThreshold;
    }

    function setBallotManagerByAdmin(IBallotsManager _addr) public onlySuperAdmin {
        ballotManager = _addr;
    }

    /**
     * add accepted cryptos as payment
     */
    function addAcceptedTokens(address _addr) public onlySuperAdmin {
        acceptedTokens[_addr] = true;
    }

    function removeAcceptedTokens(address _addr) public onlySuperAdmin {
        acceptedTokens[_addr] = false;
    }

    function tokenIsAccepted(address _token) public view returns (bool) {
        return acceptedTokens[_token];
    }

    function checkEligibility(address _user) public returns (bool) {
        uint256 totalInLocked = batchManager.getTotalInLockedBatch(_user);
        return totalInLocked >= getEligibilityThreshold()
                && totalInLocked == getCapitalToken().balanceOf(_user)
                && capitalManager.isBlacklisted(_user);
    }
}
