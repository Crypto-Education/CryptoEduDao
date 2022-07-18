// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISERC20 is IERC20 {
    function snapshot() external returns(uint256);

    function mint(address to, uint256 amount) external;

    function unpause() external;
    
    function pause() external;

    function balanceOfAt(address account, uint256 snapshotId) external view returns (uint256);

    function totalSupplyAt(uint256 snapshotId) external view returns (uint256);
}