// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";

contract Redistribute is CeEduOwnable {
    string name;
    struct aDistribution {
        uint date;
        IERC20 token;
        uint256[] balances;
        uint[] snapps;
        address batchConcerned;
    }

    mapping(uint => bool) public snapshots;
    mapping(IERC20 => aDistribution) public snapshotsFortoken;
    mapping(address => mapping(IERC20 => uint)) public claimed;

    constructor(address daoAdmin) CeEduOwnable (daoAdmin)
    {
        name = "Redistribute - CECA" ;
    }
    function takeSnapshop() public onlyAdmin returns(uint) {
        snapshots[block.timestamp] = true;
        getAdminSetting().takeSnapshop(block.timestamp);
        return block.timestamp;
    }

    function setRedistribute(IERC20 token, uint256 _added) public {
        uint lastSnap = takeSnapshop();
        uint[] memory t;
        uint256[] memory t2;
        if (snapshotsFortoken[token].date == 0) {
            snapshotsFortoken[token] = aDistribution({
                date : block.timestamp,
                token : token,
                batchConcerned : address(this),
                snapps : t,
                balances : t2
            });
            uint256 totalSupply = token.balanceOf(address(this));
            snapshotsFortoken[token].balances.push(totalSupply - (totalSupply / 10));
            token.transfer(getAdminSetting().getTeamAddress(), totalSupply / 10);
        } else {
            snapshotsFortoken[token].balances.push(_added);
        }
        snapshotsFortoken[token].snapps.push(lastSnap);
    }

    function redistributeTokenToUser(IERC20 token) public{
        require(snapshotsFortoken[token].date != 0, "Redistribute token not set");
        require(claimed[msg.sender][token] < snapshotsFortoken[token].snapps.length, "Redistribute token not set");
        
        uint256 toDistribute = 0;

        // move into each snap and send accordingly 
        for(uint i = 0; i < snapshotsFortoken[token].snapps.length; i++) {
            uint256 snaptIndex = getAdminSetting().getSnapshopFor(snapshotsFortoken[token].snapps[i], snapshotsFortoken[token].batchConcerned);
            uint256 totalSupply = getAdminSetting().getCapitalToken(address(this)).totalSupply() 
                                - getAdminSetting().getCapitalToken(address(this)).balanceOfAt(address(0), snaptIndex);
            toDistribute += snapshotsFortoken[token].balances[i] * (
                getAdminSetting().getCapitalToken(address(this)).balanceOfAt(msg.sender, snaptIndex) * 100 / totalSupply
                ) / 100;
        }
        claimed[msg.sender][token] = snapshotsFortoken[token].snapps.length;
        token.transfer(msg.sender, toDistribute);
    }
}
