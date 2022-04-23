//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Users/CeEduOwnable.sol";
import "../Tokens/CECAToken.sol";
import "../Models/CeCaBatch.sol";

contract CapitalManager is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeMath for uint128;
    using SafeERC20 for IERC20;

    string public name;
    uint256 public eligibilityThreshold = 100 ether;
    address public mainCapitalAddress; // address to receive all capital deposited
    address public batchCreatorAddress; // address to receive all capital deposited

    CECAToken public cecaToken;
    IERC20 public busdToken;
    CeCaBatch[] public batchList;

    mapping (address => uint256) public capitalBalance;
    mapping (address => bool) private _blackListAddr;

    event ev_deposit(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_totalDepositInBatch(uint256 indexed _btachId, uint256 _value);
    event ev_myTotalDeposited(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_totalUsersInBatch(uint256 indexed _btachId, uint256 _value);
    event ev_newBatchAdded(uint256 indexed _btachId);
    event ev_batchLocked(uint256 indexed _btachId);

    constructor(CECAToken _cecaToken)
    {
        cecaToken = _cecaToken;
        name = 'CEDU_CapitalManager';
    }

    modifier onlyCeCaBatch() {
        require(isBatch(), "Only CeCa Batch");
        _;
    }

    modifier onlyCeCaBatchAndSuperAdmin() {
        require(isSuperAdmin() || isBatch());
        _;
    }

    modifier isBatchCreator() {
        require(msg.sender == batchCreatorAddress, "Should be Batch Creator" );
        _;
    }

    function isBatch() private {
        bool result = false;
        for(uint i; i < batchList.length; i ++) {
            if (address (batchList[i]) == msg.sender) {
                result = true;
                break;
            }
        }
    }
    //Redistribute token cap to old investors
    function redistributeToOldInvestor(address[] memory payees, uint256[] memory shares_) payable public onlySuperAdmin returns(bool) {
        require(payees.length == shares_.length && batchList.length > 0 && payees.length > 0, "redistributeToOldInvestor: payees and shares length mismatch");
        for (uint i = 0; i < payees.length; i++) {
            require(shares_[i] > 0, "amount cannot be 0");
            require(address(payees[i]) != address(0), "can't sent to 0x address");
        }
        return batchList[0].redistributeCapital(payees, shares_);
    }

    function pushBatch(CeCaBatch _ceCaBatch) public isBatchCreator {
        batchList.push(_ceCaBatch);
    }

    function getTotalDepositedInAllBatch() public view returns (uint256){
        uint256 sum = 0;
        for (uint i = 0; i < batchList.length; i++) {
            sum = sum.add(batchList[i].totalDeposited());
        }
        return sum;
    }

    function emergencyTransfer(address token) public onlySuperAdmin  {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(mainCapitalAddress, tokenToTransfer.balanceOf(address(this)));
    }

    function getBatchListSize() public view returns (uint) {
        return batchList.length;
    }

    function myBalanceDeposited() public view returns (uint256) {
        return capitalBalance[msg.sender];
    }

    function sendCeCaToUser(address _user, uint256 _amount) internal onlyCeCaBatch returns (bool) {
        bool result = false;
        // sent cecaToken to the sender
        return cecaToken.mint(_user, _amount);
    }
    function checkEligibility(address _user) public returns (bool) {

        // eligibilityThreshold
        // must hold ceca and has deposited before
        // ceca balance in wallet
        uint256 totalInLockedBatch = getTotalInLockedBatch(_user);
        return totalInLockedBatch >= eligibilityThreshold
        && totalInLockedBatch == cecaToken.balanceOf(_user)
        && !isBlacklisted(_user);

    }
    function getTotalInLockedBatch(address _user) private returns(uint256) {
        uint256 totalInLockedBatch = 0;
        for (uint i = 0; i < batchList.length; i++) {
            totalInLockedBatch = totalInLockedBatch.add(batchList[i].myDepositedInBatchForUser(_user, true));
        }
        return totalInLockedBatch;
    }

    function getUserWeight(address _user) public returns (uint){
        // get more allocation of has deposited way more earlier
        uint256 totalInLockedBatch = getTotalInLockedBatch(_user);
        return totalInLockedBatch.div(1 ether).div(100);
    }

    function setEligibilityThreshold(uint256 _eligibilityThreshold) public onlySuperAdmin {
        eligibilityThreshold = _eligibilityThreshold;
    }

    function setBatchCreatorAddress(address _batchCreatorAddress) public onlySuperAdmin {
        batchCreatorAddress = _batchCreatorAddress;
    }

    function transferMinterShip(address _newMinter) public onlySuperAdmin{
        cecaToken.passMinterRole(_newMinter);
    }

    function addToBlackList(address _addr) public onlyCeCaBatchAndSuperAdmin {
        _blackListAddr[_addr] = true;
    }

    function isBlacklisted(address _addr) public view returns(bool) {
        return _blackListAddr[_addr];
    }

    function recoverLostWallet(address _previousAddr, address _newAddr) public onlySuperAdmin {
        for (uint i = 0; i < batchList.length; i++) {
            batchList[i].recoverLostWallet(_previousAddr, _newAddr);
        }
    }
}
