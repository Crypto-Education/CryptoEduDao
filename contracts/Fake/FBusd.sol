// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract FBusd is ERC20, Pausable {
    address public minter;

    constructor() ERC20("Fake Busd", "FBUSD") {
        _mint(msg.sender, 100000000 * 10 ** decimals());
        // 100M Token Minted
        minter = msg.sender;
        //only initially
    }

    event MinterChanged(address indexed from, address to);

    function passMinterRole(address _tokenManger) public returns (bool) {
        require(msg.sender == minter, 'Error, only owner can change pass minter role');
        minter = _tokenManger;

        emit MinterChanged(msg.sender, _tokenManger);
        return true;
    }

    function mint(address account, uint256 amount) public returns (bool){
        require(msg.sender == minter, 'Error, msg.sender does not have minter role');
        //CapitalManager
        _mint(account, amount);
        return true;
    }
}