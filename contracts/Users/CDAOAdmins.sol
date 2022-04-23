// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Managers/IdoManager.sol";
import "../Tokens/CECAToken.sol";
import "../Managers/CapitalManager.sol";

contract CDAOAdmins {
    using Address for address;
    using SafeERC20 for IERC20;

    address private _superAdmin;
    mapping(address => bool) private _adminGrantList;


    uint256 public transactionFeesPerBatch = 0.25 ether; // for ido participation fees
    /**
    * all DAOs  address for different purposes
    */
    address private idoMainAddress; // address eligible for ICO used on BSCPAD AND Other launchpads
    address private idoReceiverAddress; // address to receive IDO amount / when users contributes
    address private teamAddress; // address to receive IDO amount
    address public mainCapitalAddress; // address to receive all capital deposited

    CECAToken public capitalToken;
    CapitalManager public capitalManager;
    IdoManager private idoManager;

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
        OwnershipGranted(_userAddr);
    }

    function isAdmin(address _userAddr) view public returns (bool) {
        return _adminGrantList[_userAddr];
    }

    function isSuperAdmin(address _userAddr) view public returns (bool) {
        return _userAddr == _superAdmin;
    }


    function removerGrantAdmin(address _userAddr) public onlySuperAdmin {
        _adminGrantList[_userAddr] = false;
        OwnershipRemoved(_userAddr);
    }

    function changeSuperAdmin(address _userAddr) public onlySuperAdmin {
        require(isAdmin(_userAddr), "New user most be an administrator");
        _superAdmin = _userAddr;
        emit SuperOwnershipTransferred(address(0), msgSender);
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

    function getCapitalToken() public returns (CECAToken) {
        return capitalToken;
    }

    function getTransactionFeesPerBatch() public returns(uint256){
        return transactionFeesPerBatch;
    }

    /**
     * Managers
     */
    function getCapitalManager() public returns (CapitalManager) {
        return capitalManager;
    }

    function getIdoManager() public returns(IdoManager) {
        return idoManager;
    }

    /** Setters
     */
    function setIdoMainAddress(address _addr) public onlySuperAdmin {
        idoMainAddress = _addr;
    }

    function setIdoReceiverAddress(address _addr) public onlySuperAdmin {
        idoReceiverAddress = _addr;
    }

    function setIdoMainAddress(address _addr) public onlySuperAdmin {
        teamAddress = _addr;
    }

    function setMainCapitalAddress(address _addr) public onlySuperAdmin {
        mainCapitalAddress = _addr;
    }


    function setCapitalToken(CECAToken _addr) public onlySuperAdmin {
        capitalToken = _addr;
    }


    function setCapitalManager(CapitalManager _addr) public onlySuperAdmin {
        capitalManager = _addr;
    }

    function setIdoManager(IdoManager _addr) public onlySuperAdmin {
        idoManager = _addr;
    }

    function setTransactionFeesPerBatch(uint256 _transactionFeesPerBatch) public onlyOwner {
        transactionFeesPerBatch = _transactionFeesPerBatch;
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

    function tokenIsAccepted(address _token) public view returns(bool) {
        return acceptedTokens[_token];
    }
}
