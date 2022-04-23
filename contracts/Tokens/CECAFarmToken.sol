// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CECAFarmToken is ERC20 {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public minter;


    // todo
    // constructor() ERC20("CryptoEduFakeBUSD", "FUSD")
    constructor() ERC20("CryptoEduFarmToken", "CEFA")
    {
        _mint(msg.sender, 1000000000 * 10 * decimals());
        // 1B Token Minted
        minter = msg.sender;
        //only initially
    }

    event MinterChanged(address indexed from, address to);

    function passMinterRole(address _tokenManger) public returns (bool) {
        require(msg.sender == _tokenManger, 'Error, only owner can change pass minter role');
        minter = _tokenManger;

        emit MinterChanged(msg.sender, _tokenManger);
        return true;
    }

    function mint(address account, uint256 amount) public {
        require(msg.sender == minter, 'Error, msg.sender does not have minter role');
        //CapitalManager
        _mint(account, amount);
    }
}
