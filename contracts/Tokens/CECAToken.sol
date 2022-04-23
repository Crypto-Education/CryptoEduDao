//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Pausable.sol";

contract CECAToken is ERC20, ERC20Detailed, ERC20Mintable, ERC20Pausable {
    address public minter;

    constructor() public payable ERC20("CryptoEduCapitalToken", "CECA") {
        minter = msg.sender;
    }

    event MinterChanged(address indexed from, address to);

    function passMinterRole(address _tokenManger) public returns (bool) {
        require(msg.sender == minter, 'Error, only owner can change pass minter role');
        minter = _tokenManger;

        emit MinterChanged(msg.sender, _tokenManger);
        return true;
    }

    function mint(address account, uint256 amount) public returns (bool) {
        require(msg.sender == minter, 'Error, msg.sender does not have minter role');
        //CapitalManager
        _mint(account, amount);
        return true;
    }
}
