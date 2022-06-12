
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";

contract MigrationV1V2 is CeEduOwnable{
    using Address for address;

    constructor(address daoAdmin) CeEduOwnable(daoAdmin) {

    }

    //Redistribute token cap to old investors
    function redistributeToOldInvestorPrivate(address payees, uint256 shares_, uint batch_index)  private{
        require(getAdminSetting().getBatchManager().getBatchListSize() > 0 && payees != address(0) && shares_ > 0, "redistributeToOldInvestor: payees and shares length mismatch");
        address[] memory payees_;
        uint256[] memory shares__;
        payees_[0] = payees;
        shares__[0] = shares_;
        getAdminSetting().getBatchManager().getBatch(batch_index).redistributeCapital(payees_, shares__);
    }

    function migrateToV2() public {
        uint256 oldBalance = getAdminSetting().getOldCapitalToken().balanceOf(msg.sender);
        require(oldBalance > 0, "Balance of Old Ceca is less than 0");
        getAdminSetting().getOldCapitalToken().approve(address(this), oldBalance);
        getAdminSetting().getOldCapitalToken().transferFrom(msg.sender, address(0), oldBalance);

        for (uint i = 0; i < getAdminSetting().getOldCapitalManager().getBatchListSize(); i++) {
            if (!getAdminSetting().getOldCapitalManager().batchList(i).getIsStaking(msg.sender)) {
                continue;
            }
            uint256 depositedInOld = getAdminSetting().getOldCapitalManager().batchList(i).getListOfParticipant(msg.sender);
            uint256 depositedInNew = getAdminSetting().getBatchManager().getBatch(i).getBalance(msg.sender);
            uint256 toDistribute = depositedInOld - depositedInNew;
            if (toDistribute > oldBalance) {
                toDistribute = oldBalance;
            }
            if (toDistribute > 0) {
                redistributeToOldInvestorPrivate(msg.sender, toDistribute, i);
                oldBalance -= toDistribute; 
            }
            require(oldBalance > 0, "Balance of Old Ceca is less than 0");
        }
    }
}