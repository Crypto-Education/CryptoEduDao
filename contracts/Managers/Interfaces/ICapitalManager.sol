// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../Tokens/Interfaces/ISERC20.sol";
interface ICapitalManager {

    function emergencyTransfer(address token) external   ;

    function sendCeCaToUser(address _user, uint256 _amount) external  returns (bool);
    
    function setBatchManagerAddress(address _batchManagerAddress) external ;

    function transferMinterShip(address _newMinter) external ;

    function addToBlackList(address _addr) external  ;

    function isBlacklisted(address _addr) external view returns(bool);

    function getCapitalToken(address relatedBatch) external returns(ISERC20);

    function createCecaTokenForBatch(address _batch, uint _index) external;
}
