//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./CryptoEduCapitalToken.sol";
import "./CeEduOwnable.sol";
import "./CapitalManager.sol";

contract CeCaBatch is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public mainCapitalAddress; // address to receive all capital deposited

    CryptoEduCapitalToken public capitalToken;
    CapitalManager public capitalManager;

    IERC20 public busdToken;

    string public name;
    uint256 public openedTimestamp;
    uint256 public lockTimestamp;
    uint256 public beginWithdrawTimestamp;
    bool public isLocked;
    uint256 public totalDeposited;
    uint256 public totalWithdraw;
    address[] public stakers;
    mapping (address => uint256) public listOfParticipant;
    mapping (address => bool) public hasStaked;
    mapping (address => bool) public isStaking;

    event ev_deposit(address indexed _from, address indexed _btachId, uint256 _value);
    event ev_totalDepositInBatch(address indexed _btachId, uint256 _value);
    event ev_myTotalDeposited(address indexed _from, address indexed _btachId, uint256 _value);
    event ev_totalUsersInBatch(address indexed _btachId, uint256 _value);

    event ev_newBatchAdded(address indexed _btachId);
    event ev_batchLocked(address indexed _btachId);

    constructor(string memory _name, IERC20 _busdToken, address _mainAddress, CapitalManager _capitalManager, bool _locked)
    {
        busdToken = _busdToken;
        mainCapitalAddress = _mainAddress;
        capitalManager = CapitalManager(_capitalManager);
        name = _name ;
        isLocked = _locked;
        openedTimestamp = block.timestamp;
        if (_locked) {
            lockTimestamp = block.timestamp;
        }
    }

    modifier onlyCapitalManager() {
        require(msg.sender == address (capitalManager), "");
        _;
    }

    function depositInCapital(uint256 _amount) public returns (bool) {
        // Require amount greater than 0
        require(_amount >= 0 && !isLocked, "Cant deposit b not lock");
        require(busdToken.balanceOf(msg.sender) >= _amount, "You dont have enougth busd");

        // Transfer BUSD tokens to this contract for staking
        require(busdToken.transferFrom(msg.sender, mainCapitalAddress, _amount), "Unable to transfer BUSD");
        require(capitalManager.sendCeCaToUser(msg.sender, _amount), "Not able to send CECA");

        //deposit _amount in this current batch
        listOfParticipant[msg.sender] = listOfParticipant[msg.sender].add(_amount);
        totalDeposited = totalDeposited.add(_amount);
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }
        hasStaked[msg.sender] = true;
        isStaking[msg.sender] = true;

        emit ev_deposit(msg.sender, address(this), _amount);
        emit ev_myTotalDeposited(msg.sender, address(this), listOfParticipant[msg.sender]);
        emit ev_totalUsersInBatch(address(this), stakers.length);
        emit ev_totalDepositInBatch(address(this), totalDeposited);
        return true;
    }

    function redistributeCapital(address[] memory payees, uint256[] memory shares_) public onlyCapitalManager returns (bool) {
        for (uint i = 0; i < payees.length; i++)
        {
            require(capitalManager.sendCeCaToUser(payees[i], shares_[i]), "Not able to send CECA");
            listOfParticipant[payees[i]] = listOfParticipant[payees[i]].add(shares_[i]);
            totalDeposited = totalDeposited.add(shares_[i]);
            if (!hasStaked[payees[i]]) {
                hasStaked[payees[i]] = true;
                isStaking[payees[i]] = true;
                stakers.push(payees[i]);
            }
        }
        return true;
    }

    function lockBatch() public onlyOwner  returns (bool) {
        require(!isLocked, "Batch is locked already");
        isLocked = true;
        lockTimestamp = block.timestamp;
        beginWithdrawTimestamp = block.timestamp + (365 * (1 days));
        emit ev_batchLocked(address (this));
        return true;
    }

    function withdraw() public {
        require(msg.sender != address(0) && isStaking[msg.sender], "ERC20: burn from the zero address");
        // ceca burn
        require(capitalToken.transferFrom(msg.sender, address(0), listOfParticipant[msg.sender]));
        listOfParticipant[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }

    function myDepositedInBatchForUser(address _userAdd, bool _onlyLocked) public view returns (uint256) {
        if (_onlyLocked) {
            if (isLocked) {
                return listOfParticipant[_userAdd];
            } else {
                return 0;
            }

        }
        return listOfParticipant[_userAdd];
    }

    function getNumberOfParticipantOfBatch() public view returns (uint256){
        return stakers.length;
    }

    function getListOfParticipant(address _user) public returns(uint256) {
        return listOfParticipant[_user];
    }

    function getHasStaked(address _user) public returns(bool) {
        return hasStaked[_user];
    }

    function getIsStaking(address _user) public returns(bool) {
        return isStaking[_user];
    }

    function emergencyTransfer(address token) public onlyOwner  {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(mainCapitalAddress, tokenToTransfer.balanceOf(address(this)));
    }

}
