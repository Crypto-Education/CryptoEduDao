// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../../Models/Interfaces/IBatch.sol";

interface IBatchManager {

    function createAppendBatch(string memory _name, bool _locked) external returns (bool) ;

    function isBatch() external view returns(bool);

    //Redistribute token cap to old investors
    function redistributeToOldInvestor(address[] memory payees, uint256[] memory shares_) payable external returns(bool);

    function pushBatch(IBatch _ceCaBatch) external;

    function getTotalDepositedInAllBatch() external view returns (uint256);

    function getBatchListSize() external view returns (uint);
    function getTotalInLockedBatch(address _user) external returns(uint256);

    function recoverLostWallet(address _previousAddr, address _newAddr) external;

    function checkEligibility(address _user) external returns (bool);
    
    function getUserWeight(address _user) external returns (uint);

    function getBatch(uint index) external returns(IBatch);
}