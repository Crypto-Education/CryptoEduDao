// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface OldCeCaBatch {
    function getListOfParticipant(address _user) external returns(uint256);

    function getHasStaked(address _user) external returns(bool);

    function getIsStaking(address _user) external returns(bool);

}

interface OldCapitalManager{
    function getBatchListSize() external view returns (uint);
    function batchList(uint) external view returns (OldCeCaBatch);
}