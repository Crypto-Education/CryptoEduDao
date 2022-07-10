// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";
import "../Users/CDAOAdmins.sol";
import "../Managers/CapitalManager.sol";

/// @title Voting with delegation.
contract Ballot is CeEduOwnable {
    string public name;
    uint256 public snapshopsId;

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

    mapping(address => Voter) public voters;

    uint public nbVoters;

    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    bool public completed;

    /// Create a new ballot to choose one of `proposalNames`.
    constructor(string memory _name, string[] memory proposalNames, address daoAdmin) CeEduOwnable (daoAdmin) {
        name = _name;
        completed = false;

        
        for (uint i = 0; i < proposalNames.length; i++) {
            proposals.push(Proposal({
            name: proposalNames[i],
            voteCount: 0
            }));
        }
    }

    modifier isEligibleForIdo() {
        require(
            getAdminSetting().checkEligibility(msg.sender),
            "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"
        );
        _;
    }

    
    function vote(uint proposal) public isEligibleForIdo {
        require(!completed && proposal < proposals.length , "Vote is completed or proposal not found");
        Voter storage sender = voters[msg.sender];
        require(!sender.voted, "Already voted.");
        sender.voted = true;
        sender.vote = proposal;
        sender.weight = getAdminSetting().getBatchManager().getUserWeightFromSnapshot(msg.sender, snapshopsId);
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

    
    function winnerName() public view  returns (string memory winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }

    function lockVote() public onlyAdmin {
        completed = true;
    }

    function getProposalSize() public view returns(uint) {
        return proposals.length;
    }

    function canVote() public view returns(bool) {
        return voters[msg.sender].voted == false && completed == false;
    }

    function takeSnapshop() public onlyAdmin {
        snapshopsId = block.timestamp;
        getAdminSetting().takeSnapshop(snapshopsId);
    }
}