// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";
import "../Tokens/CECAToken.sol";
import "../Models/Batch.sol";

contract CapitalManager is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeMath for uint128;
    using SafeERC20 for IERC20;

    string public name;

    CECAToken public cecaToken;

    mapping (address => uint256) public capitalBalance;
    mapping (address => bool) private _blackListAddr;

    event ev_deposit(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_myTotalDeposited(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_totalUsersInBatch(uint256 indexed _btachId, uint256 _value);
    event ev_newBatchAdded(uint256 indexed _btachId);
    event ev_batchLocked(uint256 indexed _btachId);

    constructor(CECAToken _cecaToken, address daoAdmin) CeEduOwnable (daoAdmin)
    {
        cecaToken = _cecaToken;
        name = 'CEDU_CapitalManager';
        /*CDAOAdmins settings = getAdminSetting();
        settings.setCapitalManager(this);*/
    }

    modifier onlyCeCaBatch() {
        require(getAdminSetting().getBatchManager().isBatch(), "Only CeCa Batch");
        _;
    }

    modifier onlyCeCaBatchAndSuperAdmin() {
        require( getAdminSetting().isSuperAdmin(msg.sender) || getAdminSetting().getBatchManager().isBatch());
        _;
    }

    function emergencyTransfer(address token) public onlySuperAdmin  {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(getAdminSetting().getMainCapitalAddress(), tokenToTransfer.balanceOf(address(this)));
    }

    function myBalanceDeposited() public view returns (uint256) {
        return capitalBalance[msg.sender];
    }

    function sendCeCaToUser(address _user, uint256 _amount) internal onlyCeCaBatch returns (bool) {
        // sent cecaToken to the sender
        return cecaToken.mint(_user, _amount);
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
