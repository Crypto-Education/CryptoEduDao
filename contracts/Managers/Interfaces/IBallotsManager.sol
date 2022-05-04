// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IBallotsManager {
    function initialiseNewBallot(string memory _name, string[] memory proposalNames) external returns (bool);

    function getBallotListSize() external view returns (uint);
}
