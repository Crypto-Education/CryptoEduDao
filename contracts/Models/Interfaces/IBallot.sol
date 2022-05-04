// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;


interface IBallot{

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) external ;

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() external view returns (uint winningProposal_);

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() external view  returns (string memory winnerName_);
    function lockVote() external;

    function getProposalSize() external returns(uint) ;
    function canVote() external returns(bool);
}