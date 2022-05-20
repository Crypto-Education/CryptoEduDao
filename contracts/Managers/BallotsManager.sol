// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";
import "../Models/Ballot.sol";

contract BallotsManager is CeEduOwnable{
    Ballot[] public ballotsList;
    string name;
    
    constructor(address daoAdmin) CeEduOwnable (daoAdmin)  {
        name = 'CEDU_BallotsManager';
    }

    function initialiseNewBallot(string memory _name, string[] memory proposalNames) public onlyAdmin returns (bool) {
        Ballot newBallot = new Ballot(_name, proposalNames, address(getAdminSetting()));
        ballotsList.push(newBallot);
        return true;
    }

    function getBallotListSize() public view returns (uint) {
        return ballotsList.length;
    }
} 
