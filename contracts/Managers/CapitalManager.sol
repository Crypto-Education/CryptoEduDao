// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Users/CeEduOwnable.sol";
import "../Tokens/CECAToken.sol";
import "../Models/Batch.sol";

contract CapitalManager is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeMath for uint128;
    using SafeERC20 for IERC20;

    string public name;
    address public mainCapitalAddress; // address to receive all capital deposited
    address public batchManagerAddress; // address to receive all capital deposited

    CECAToken public cecaToken;
    IERC20 public busdToken;

    mapping (address => uint256) public capitalBalance;
    mapping (address => bool) private _blackListAddr;

    event ev_deposit(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_myTotalDeposited(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_totalUsersInBatch(uint256 indexed _btachId, uint256 _value);
    event ev_newBatchAdded(uint256 indexed _btachId);
    event ev_batchLocked(uint256 indexed _btachId);

    constructor(CECAToken _cecaToken) 
    {
        cecaToken = _cecaToken;
        name = 'CEDU_CapitalManager';
        CDAOAdmins settings = getAdminSetting();
        settings.setCapitalManager(this);
    }

    modifier onlyCeCaBatch() {
        require(isBatch(), "Only CeCa Batch");
        _;
    }

    modifier onlyCeCaBatchAndSuperAdmin() {
        require(isSuperAdmin() || isBatch());
        _;
    }

    modifier isBatchManager() {
        require(msg.sender == batchManagerAddress, "Should be Batch Creator" );
        _;
    }

    function emergencyTransfer(address token) public onlySuperAdmin  {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(mainCapitalAddress, tokenToTransfer.balanceOf(address(this)));
    }

    function myBalanceDeposited() public view returns (uint256) {
        return capitalBalance[msg.sender];
    }

    function sendCeCaToUser(address _user, uint256 _amount) internal onlyCeCaBatch returns (bool) {
        bool result = false;
        // sent cecaToken to the sender
        return cecaToken.mint(_user, _amount);
    }
    

    function setBatchManagerAddress(address _batchManagerAddress) public onlySuperAdmin {
        batchManagerAddress = _batchManagerAddress;
    }

    function transferMinterShip(address _newMinter) public onlySuperAdmin{
        cecaToken.passMinterRole(_newMinter);
    }

    function addToBlackList(address _addr) public onlyCeCaBatchAndSuperAdmin {
        _blackListAddr[_addr] = true;
    }

    function isBlacklisted(address _addr) public view returns(bool) {
        return _blackListAddr[_addr];
    }
}
