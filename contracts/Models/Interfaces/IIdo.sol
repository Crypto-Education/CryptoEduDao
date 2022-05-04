// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IIdo{
    function isEligible() external returns(bool) ;
    function setIdoToken(address _tokenAddress, uint256 _numberOfToken, uint256 _totalAmountSpent,IERC20 _payCrypto) external ;

    function idoLockDeposit() external ;

    function redistributeIdoToken() external ;

    function depositForIdo(uint256 _amount, IERC20 _payCrypto) external returns (bool) ;

    function getSumOfAllWeight() external returns(uint256);
    
    function emergencyTransfer(address token) external ;
    function myDepositedInIdo() external view returns (uint256);
    function getNumberOfParticipantOfIdo() external view returns (uint256);

    /*
     * Balance of functions to extend smart contract functionnalities
     */
    function getBalanceOfParticipant(address _user) external  returns(uint256);
    function getHasStaked(address _user) external returns(bool);

    function getWeightOfParticipant(address _user) external returns(uint256);
    function getStakers() external returns(address[] memory);
    function setMaxUser(uint256 max) external;
}
