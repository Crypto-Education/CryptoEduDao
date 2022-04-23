// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";
import "../Users/CDAOAdmins.sol";
import "../Managers/CapitalManager.sol";

/// @title Voting with delegation.
contract Ballot is CeEduOwnable {
    string public name;
    // This declares a new complex type which will
    // be used for variables later.
    // It will represent a single voter.
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal {
        string name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;

    uint public nbVoters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    bool public completed;

    /// Create a new ballot to choose one of `proposalNames`.
    constructor(string memory _name, string[] memory proposalNames) {
        name = _name;
        completed = false;

        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(Proposal({
            name: proposalNames[i],
            voteCount: 0
            }));
        }
    }

    modifier isEligibleForIdo() {
        bool checkElig = checkEligibility(msg.sender);
        require(
            checkElig,
            "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"
        );
        _;
    }


    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) public isEligibleForIdo {
        require(!completed, "Vote is completed ");
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        CapitalManager capitalManager = settings.getCapitalManager();
        sender.voted = true;
        sender.vote = proposal;
        sender.weight = capitalManager.getUserWeight(msg.sender);
        proposals[proposal].voteCount += sender.weight;
        nbVoters ++;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() public view  returns (string memory winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }

    function lockVote() public onlyAdmin {
        completed = true;
    }

    function getProposalSize() public returns(uint) {
        return proposals.length;
    }

    function canVote() public returns(bool) {
        return voters[msg.sender].voted == false && completed == false;
    }
}