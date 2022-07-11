// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";
import "../Models/Batch.sol";

contract CapitalManager is CeEduOwnable {
    using Address for address;
    using SafeERC20 for IERC20;

    mapping(address => CECAToken) public capitalToken;
    CECAToken[] public capitalTokenTable;

    string public name;
    mapping (address => uint256) public capitalBalance;
    mapping (address => bool) private _blackListAddr;

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
        getCapitalToken(msg.sender).mint(_user, _amount2);
        return true;
    }

    function addToBlackList(address _addr) public onlyCeCaBatchAndSuperAdmin {
        _blackListAddr[_addr] = true;
    }

    function isBlacklisted(address _addr) public view returns(bool) {
        return _blackListAddr[_addr];
    }

    function createCecaTokenForBatch(address _batch, uint _index) public {
        require(msg.sender == address(getAdminSetting().getBatchManager()));
        capitalToken[_batch] = new CECAToken("CryptoEdu Capital Token", string(abi.encodePacked("CECA", new string(_index))));
        capitalToken[_batch].grantRole(capitalToken[_batch].MINTER_ROLE(), address(getAdminSetting().getCapitalManager()));
    }
    
    function getCapitalToken(address relatedBatch) public view returns (CECAToken) {
        return capitalToken[relatedBatch];
    }
}
