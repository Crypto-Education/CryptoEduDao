//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./CeEduOwnable.sol";
import "./CryptoEduCapitalToken.sol";
import "./CeCaBatch.sol";

contract CapitalManager is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public eligibilityThreshold = 100 ether;
    uint256 public transactionFeesPerBatch = 0.25 ether;

    address public mainCapitalAddress; // address to receive all capital deposited
    address public batchCreatorAddress; // address to receive all capital deposited

    CryptoEduCapitalToken public capitalToken;
    IERC20 public busdToken;

    string public name;
    CeCaBatch[] public batchList;

    mapping (address => uint256) public capitalBalance;

    event ev_deposit(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_totalDepositInBatch(uint256 indexed _btachId, uint256 _value);
    event ev_myTotalDeposited(address indexed _from, uint256 indexed _btachId, uint256 _value);
    event ev_totalUsersInBatch(uint256 indexed _btachId, uint256 _value);

    event ev_newBatchAdded(uint256 indexed _btachId);
    event ev_batchLocked(uint256 indexed _btachId);

    constructor(CryptoEduCapitalToken _capitalToken, address _busdToken, address _mainAddress)
    {
        capitalToken = _capitalToken;
        busdToken = IERC20(_busdToken);
        mainCapitalAddress = _mainAddress;
        name = 'CEDU_CapitalManager';
    }

    modifier onlyCeCaBatch() {
        bool result = false;
        for(uint i; i < batchList.length; i ++) {
            if (address (batchList[i]) == msg.sender) {
                result = true;
                break;
            }
        }
        require(result, "Only CeCa Batch");
        _;
    }
    //Redistribute token cap to old investors
    function redistributeToOldInvestor(address[] memory payees, uint256[] memory shares_) payable public onlyOwner returns(bool) {
        require(payees.length == shares_.length && batchList.length > 0, "redistributeToOldInvestor: payees and shares length mismatch");
        require(payees.length > 0, "redistributeToOldInvestor: no payees");

        for (uint i = 0; i < payees.length; i++) {
            require(shares_[i] > 0, "amount cannot be 0");
            require(address(payees[i]) != address(0), "can't sent to 0x address");
        }
        return batchList[0].redistributeCapital(payees, shares_);
    }

    modifier isBatchCreator() {
        require(msg.sender == batchCreatorAddress, "Should be Batch Creator" );
        _;
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

    function emergencyTransfer(address token) public onlyOwner  {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(mainCapitalAddress, tokenToTransfer.balanceOf(address(this)));
    }

    function getBatchListSize() public view returns (uint) {
        return batchList.length;
    }

    function myBalanceDeposited() public view returns (uint256) {
        return capitalBalance[msg.sender];
    }

    function sendCeCaToUser(address _user, uint256 _amount) public onlyCeCaBatch returns (bool) {
        bool result = false;
        // sent capitalToken to the sender
        return capitalToken.mint(_user, _amount);
    }
    function checkEligibility(address _user) public returns (bool) {

        // eligibilityThreshold
        // must hold ceca and has deposited before
        // ceca balance in wallet
        uint256 totalInLockedBatch = getTotalInLockedBatch(_user);
        return totalInLockedBatch >= eligibilityThreshold
        && totalInLockedBatch == capitalToken.balanceOf(_user);

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

    function setEligibilityThreshold(uint256 _eligibilityThreshold) public onlyOwner {
        eligibilityThreshold = _eligibilityThreshold;
    }

    function setTransactionFeesPerBatch(uint256 _transactionFeesPerBatch) public onlyOwner {
        transactionFeesPerBatch = _transactionFeesPerBatch;
    }

    function setBatchCreatorAddress(address _batchCreatorAddress) public onlyOwner {
        batchCreatorAddress = _batchCreatorAddress;
    }

    function transferMinterShip(address _newMinter) public onlyOwner{
        capitalToken.passMinterRole(_newMinter);
    }
}
