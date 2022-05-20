// SPDX-License-Identifier: MIT
// WARNING this contract has not been independently tested or audited
// DO NOT use this contract with funds of real value until officially tested and audited by an independent expert or group

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Users/CeEduOwnable.sol";

contract CecaFarming is CeEduOwnable {
    
    // Library usage
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bool internal locked;
    uint256 rate;

    // userAddress => stakingBalance
    mapping(address => uint256) public stakingBalance;
    // userAddress => isStaking boolean
    mapping(address => bool) public isStaking;
    // userAddress => timeStamp
    mapping(address => uint256) public startTime;
    // userAddress => tokenBalance
    mapping(address => uint256) public tokenBalance;

    string public name = "TokenFarm";

    modifier notIsLocked() {
        require (locked == false);
        _;
    }

    event Stake(address indexed from, uint256 amount);
    event Unstake(address indexed from, uint256 amount);
    event YieldWithdraw(address indexed to, uint256 amount);

    constructor(address daoAdmin) CeEduOwnable (daoAdmin) {}

    function stake(uint256 amount) public notIsLocked{
        require(
            amount > 0 &&
            getAdminSetting().getCapitalToken().balanceOf(msg.sender) >= amount, 
            "You cannot stake zero tokens");
            
        if(isStaking[msg.sender] == true){
            uint256 toTransfer = calculateYieldTotal(msg.sender);
            tokenBalance[msg.sender] = tokenBalance[msg.sender].add(toTransfer);
        } else {
            isStaking[msg.sender] = true;
        }

        getAdminSetting().getCapitalToken().transferFrom(msg.sender, address(this), amount);
        stakingBalance[msg.sender] = stakingBalance[msg.sender].add(amount);
        startTime[msg.sender] = block.timestamp;
        emit Stake(msg.sender, amount);
    }

    function unstake(uint256 amount) public {
        require(
            isStaking[msg.sender] = true &&
            stakingBalance[msg.sender] >= amount, 
            "Nothing to unstake"
        );
        //uint256 yieldTransfer = calculateYieldTotal(msg.sender);
        startTime[msg.sender] = block.timestamp; // bug fix
        uint256 balanceTransfer = amount;
        amount = 0;
        stakingBalance[msg.sender] = stakingBalance[msg.sender].sub(balanceTransfer);
        getAdminSetting().getCapitalToken().transfer(msg.sender, balanceTransfer);
        withdrawYield();
        if(stakingBalance[msg.sender] == 0) {
            isStaking[msg.sender] = false;
        }
        emit Unstake(msg.sender, balanceTransfer);
    }

    function withdrawYield() public {
        uint256 toTransfer = calculateYieldTotal(msg.sender);

        require(
            toTransfer > 0 ||
            tokenBalance[msg.sender] > 0,
            "Nothing to withdraw"
            );
            
        if(tokenBalance[msg.sender] != 0){
            uint256 oldBalance = tokenBalance[msg.sender];
            tokenBalance[msg.sender] = 0;
            toTransfer += oldBalance;
        }

        startTime[msg.sender] = block.timestamp;
        getAdminSetting().getDaoToken().mint(msg.sender, toTransfer);
        emit YieldWithdraw(msg.sender, toTransfer);
    }

    function calculateYieldTime(address user) public view returns(uint256){
        uint256 end = block.timestamp;
        uint256 totalTime = end - startTime[user];
        return totalTime;
    }

    function calculateYieldTotal(address user) public view returns(uint256) {
        uint256 time = calculateYieldTime(user);
        return rate.div(100).mul(stakingBalance[user]).div(365 days).mul(time);
    } 

    /// @dev Transfer accidentally locked ERC20 tokens.
    /// @param token - ERC20 token address.
    /// @param amount of ERC20 tokens to remove.
    function transferAccidentallyLockedTokens(IERC20 token, uint256 amount) public onlySuperAdmin {
        require(address(token) != address(0), "Token address can not be zero");
        // This function can not access the official timelocked tokens; just other random ERC20 tokens that may have been accidently sent here
        require(token != getAdminSetting().getDaoToken(), "Token address can not be ERC20 address which was passed into the constructor");
        // Transfer the amount of the specified ERC20 tokens, to the owner of this contract
        token.safeTransfer(getAdminSetting().getMainCapitalAddress(), amount);
    }

    function toggleLocker() public onlyAdmin {
        locked = !locked;
    }
}
