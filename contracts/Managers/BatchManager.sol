// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../Users/CeEduOwnable.sol";
import "../Models/Batch.sol";

contract BatchManager is CeEduOwnable {
    using SafeMath for uint256;
    using Address for address;
    
    string name;
    Batch[] public batchList;

    event ev_batchCreated(Batch _BatchId);
    constructor(address daoAdmin) CeEduOwnable (daoAdmin)
    {
        name = 'CEDU_BatchManager';
        /*CDAOAdmins settings = getAdminSetting();
        settings.setBatchManager(this);*/
    }

    function createAppendBatch(string memory _name, bool _locked) external onlyAdmin returns (bool) {
        Batch newBatch = new Batch(_name, _locked, address(getAdminSetting()));
        batchList.push(newBatch);
        emit ev_batchCreated(newBatch);
        return true;
    }

    function isBatch() public view returns(bool) {
        bool result = false;
        for(uint i; i < batchList.length; i ++) {
            if (address (batchList[i]) == msg.sender) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    //Redistribute token cap to old investors
    function redistributeToOldInvestor(address[] memory payees, uint256[] memory shares_) payable public onlySuperAdmin returns(bool) {
        require(payees.length == shares_.length && batchList.length > 0 && payees.length > 0, "redistributeToOldInvestor: payees and shares length mismatch");
        for (uint i = 0; i < payees.length; i++) {
            require(shares_[i] > 0, "amount cannot be 0");
            require(address(payees[i]) != address(0), "can't sent to 0x address");
        }
        return batchList[0].redistributeCapital(payees, shares_);
    }

    // to remove
    function pushBatch(Batch _ceCaBatch) public isBatchManager {
        batchList.push(_ceCaBatch);
    }

    function getTotalDepositedInAllBatch() public view returns (uint256){
        uint256 sum = 0;
        for (uint i = 0; i < batchList.length; i++) {
            sum = sum.add(batchList[i].totalDeposited());
        }
        return sum;
    }

    function getBatchListSize() public view returns (uint) {
        return batchList.length;
    }
    
    function getTotalInLockedBatch(address _user) private view returns(uint256) {
        uint256 totalInLockedBatch = 0;
        for (uint i = 0; i < batchList.length; i++) {
            totalInLockedBatch = totalInLockedBatch.add(batchList[i].myDepositedInBatchForUser(_user, true));
        }
        return totalInLockedBatch;
    }

    function recoverLostWallet(address _previousAddr, address _newAddr) public onlySuperAdmin {
        for (uint i = 0; i < batchList.length; i++) {
            batchList[i].recoverLostWallet(_previousAddr, _newAddr);
        }
    }

    function checkEligibility(address _user) override public view returns (bool) {

        // eligibilityThreshold
        // must hold ceca and has deposited before
        // ceca balance in wallet
        uint256 totalInLockedBatch = getTotalInLockedBatch(_user);
        return totalInLockedBatch >= getEligibilityThreshold()
        && totalInLockedBatch == getAdminSetting().getCapitalToken().balanceOf(_user)
        && !getAdminSetting().getCapitalManager().isBlacklisted(_user);
    }
    
    function getUserWeight(address _user) public view returns (uint) {
        // get more allocation of has deposited way more earlier
        uint256 totalInLockedBatch = getTotalInLockedBatch(_user);
        return totalInLockedBatch.div(1 ether).div(100);
    }
}
