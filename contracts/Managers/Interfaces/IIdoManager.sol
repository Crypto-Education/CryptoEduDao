// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IIdoManager {
    function initialiseNewIdo(string memory _name, uint256 _maxPerUser) external  returns (bool);

    function emergencyTransfer(address token) external;

    function getIdoListSize() external view returns (uint);

    function transfertMinterShip(address _newMinter) external;
}
