//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "./CapitalManager.sol";
import "./CeEduOwnable.sol";
import "./Ballot.sol";

contract BallotsManager is CeEduOwnable {
    Ballot[] public ballotsList;
    CapitalManager capitalManager;
    string name;
    constructor(CapitalManager _capitalManager) {
        capitalManager = _capitalManager;
        name = 'CEDU_BallotsManager';
    }
    function initialiseNewBallot(string memory _name, string[] memory proposalNames) public onlyOwner returns (bool) {
        Ballot newBallot = new Ballot(capitalManager, _name, proposalNames);
        newBallot.transferOwnership(this.getOwner());
        ballotsList.push(newBallot);
        return true;
    }

    function getBallotListSize() public view returns (uint) {
        return ballotsList.length;
    }
}
