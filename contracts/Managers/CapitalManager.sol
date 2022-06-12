// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";
import "../Models/Batch.sol";

contract CapitalManager is CeEduOwnable {
    using Address for address;
    using SafeERC20 for IERC20;

    string public name;
    mapping (address => uint256) public capitalBalance;
    mapping (address => bool) private _blackListAddr;

    event ev_deposit(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_myTotalDeposited(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_totalUsersInBatch(uint256 indexed _btachId, uint256 _value);
    event ev_newBatchAdded(uint256 indexed _btachId);
    event ev_batchLocked(uint256 indexed _btachId);

    constructor(address daoAdmin) CeEduOwnable (daoAdmin)
    {
        name = 'CEDU_CapitalManager';
    }

    modifier onlyCeCaBatch() {
        require(getAdminSetting().getBatchManager().isBatch(msg.sender), "Only CeCa Batch");
        _;
    }

    modifier onlyCeCaBatchAndSuperAdmin() {
        require( getAdminSetting().isSuperAdmin(msg.sender) || getAdminSetting().getBatchManager().isBatch(msg.sender));
        _;
    }

    function emergencyTransfer(address token) public onlySuperAdmin  {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(getAdminSetting().getMainCapitalAddress(), tokenToTransfer.balanceOf(address(this)));
    }

    function sendCeCaToUser(address _user, uint256 _amount) payable public onlyCeCaBatch returns(bool) {
        uint256 _amount2 = _amount;
        _amount = 0;
        // sent cecaToken to the sender
        getAdminSetting().getCapitalToken().mint(_user, _amount2);
        return true;
    }

    function addToBlackList(address _addr) public onlyCeCaBatchAndSuperAdmin {
        _blackListAddr[_addr] = true;
    }

    function isBlacklisted(address _addr) public view returns(bool) {
        return _blackListAddr[_addr];
    }
}
