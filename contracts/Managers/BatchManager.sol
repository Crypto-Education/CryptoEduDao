// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";
import "../Models/Batch.sol";


contract BatchManager is CeEduOwnable {
    using Address for address;
    string name;

    mapping (address => bool) mapBatchAddresses;
    Batch[] public batchList;

    mapping(address => Batch) public batchListMap;
    event ev_batchCreated(Batch _BatchId);
    constructor(address daoAdmin) CeEduOwnable (daoAdmin)
    {
        name = 'CEDU_BatchManager';
    }

   function createAppendBatch(string memory _name, bool _locked) external onlyAdmin {
        Batch newBatch = new Batch(_name, _locked, address(getAdminSetting()));
        batchList.push(newBatch);
        mapBatchAddresses[address(newBatch)] = true;
        batchListMap[address(newBatch)] = newBatch;
        getAdminSetting().getCapitalManager().createCecaTokenForBatch(address(newBatch), batchList.length);
        emit ev_batchCreated(newBatch);
    }

    function isBatch(address callerI) public view returns(bool) {
        return mapBatchAddresses[callerI];
    }

    function getTotalDepositedInAllBatch() public view returns (uint256){
        uint256 sum = 0;
        for (uint i = 0; i < batchList.length; i++) {
            sum += batchList[i].totalDeposited();
        }
        return sum;
    }

    function getBatch(uint index) public view returns(Batch) {
        return batchList[index];
    }

    function getBatchListSize() public view returns(uint) {
        return batchList.length;
    }
    
    function getTotalInLockedBatch(address _user) public view returns(uint256) {
        uint256 totalInLockedBatch = 0;
        for (uint i = 0; i < batchList.length; i++) {
            totalInLockedBatch += batchList[i].myDepositedInBatchForUser(_user, true);
        }
        return totalInLockedBatch;
    }

    event sendElementBatchM(uint nb);
    function getTotalInLockedBatch(address _user, uint snap) public returns(uint256) {
        uint256 totalInLockedBatch = 0;
        for (uint i = 0; i < batchList.length; i++) {
            totalInLockedBatch += batchList[i].myDepositedInBatchForUser(_user, true, snap);
        }
        return totalInLockedBatch;
    }

    function getTotalInLockedBatch(address _user, uint snap, address _batchIndex) public returns(uint256) {
        
        //return 0;
        return batchListMap[_batchIndex].myDepositedInBatchForUser(_user, true, snap);
    }

    function recoverLostWallet(address _previousAddr, address _newAddr) public onlySuperAdmin {
        for (uint i = 0; i < batchList.length; i++) {
            batchList[i].recoverLostWallet(_previousAddr, _newAddr);
        }
    }
    
   
    function getUserWeight(address _user) public view returns (uint) {
        // get more allocation of has deposited way more earlier
        return  getTotalInLockedBatch(_user) / getAdminSetting().getEligibilityThreshold(); 
    }

    function  getUserWeight(address _user, uint snap) public returns (uint) {
        return getTotalInLockedBatch(_user, snap) / getAdminSetting().getEligibilityThreshold(); 
    }

    function getPercentageUserWeight(address _user) public view returns (uint) {
        // get more allocation of has deposited way more earlier
        return getTotalInLockedBatch(_user) * 100 / getTotalDepositedInAllBatch();
    }
}
