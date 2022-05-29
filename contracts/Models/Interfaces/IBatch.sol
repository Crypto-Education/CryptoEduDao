// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBatch {
    function depositInCapital(uint256 _amount, IERC20 _payCrypto) external returns (bool);

    function redistributeCapital(address[] memory payees, uint256[] memory shares_) external;

    function lockBatch() external;
    function withdraw() external;

    function myDepositedInBatchForUser(address _userAdd, bool _onlyLocked) external view returns (uint256);

    function getNumberOfParticipantOfBatch() external view returns (uint256);

    function getBalance(address _user) external returns(uint256);

    function getHasStaked(address _user) external returns(bool);

    function getIsStaking(address _user) external returns(bool);

    function emergencyTransfer(address token) external;

    function recoverLostWallet(address _previousAddr, address _newAddr) external;

    function addParticipatedToken(uint256 amount, uint256 unitPrice, address tokenAddr, uint256 idoTimes, bool allClaimed) external;

    function setAllClaimed(address tokenAddr) external;

    function setAmountStillHold(address tokenAddr, uint256 _amount)  external;
}
