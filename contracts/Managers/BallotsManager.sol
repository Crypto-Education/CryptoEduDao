//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "../Users/CeEduOwnable.sol";
import "../Models/Ballot.sol";

contract BallotsManager is CeEduOwnable {
    Ballot[] public ballotsList;
    string name;
    constructor() {
        name = 'CEDU_BallotsManager';
    }
    function initialiseNewBallot(string memory _name, string[] memory proposalNames) public onlyAdmin returns (bool) {
        Ballot newBallot = new Ballot(_name, proposalNames);
        ballotsList.push(newBallot);
        return true;
    }

    function getBallotListSize() public view returns (uint) {
        return ballotsList.length;
    }
}
