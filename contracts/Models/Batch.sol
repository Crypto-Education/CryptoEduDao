// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";
import "../Tokens/CECAToken.sol";

contract Batch is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string public name;
    uint256 public openedTimestamp;
    uint256 public lockTimestamp;
    uint256 public beginWithdrawTimestamp;
    bool public isLocked;
    uint256 public totalDeposited;
    uint256 public totalWithdraw;
    address[] public stakers;

    struct TokenInfo {
        uint256 amount;
        uint256 unitPrice;
        address tokenAddr;
        uint256 idoTimes;
        bool allClaimed;
        uint256 amountStillHold;
    }
    mapping(address => TokenInfo) public tokenInfos;
    address[] public tokenInfoAddress;

    mapping (address => uint256) public balance;
    mapping (address => bool) public hasStaked;
    mapping (address => bool) public isStaking;

    event ev_deposit(address indexed _from, address indexed _btachId, uint256 _value);
    event ev_totalDepositInBatch(address indexed _btachId, uint256 _value);
    event ev_myTotalDeposited(address indexed _from, address indexed _btachId, uint256 _value);
    event ev_totalUsersInBatch(address indexed _btachId, uint256 _value);

    event ev_newBatchAdded(address indexed _btachId);
    event ev_batchLocked(address indexed _btachId);

    constructor(string memory _name, bool _locked, address daoAdmin) CeEduOwnable (daoAdmin)
    {
        name = _name ;
        isLocked = _locked;
        openedTimestamp = block.timestamp;
        if (_locked) {
            lockTimestamp = block.timestamp;
        }
    }

    modifier onlyBatchManager() {
        require(msg.sender == address (getAdminSetting().getBatchManager())
            || msg.sender == getAdminSetting().getMigratorV1V2()
        , "Not Manager Contract");
        _;
    }

    function depositInCapital(uint256 _amount1, IERC20 _payCrypto) public returns (bool) {
        uint256 _amount = _amount1;
        _amount1 = 0;
        // Require amount greater than 0
        require(_amount >= 0 && !isLocked, "Cant deposit bach is locked or amount ");
        require(getAdminSetting().tokenIsAccepted(address(_payCrypto)) && _payCrypto.balanceOf(msg.sender) >= _amount, "You dont have enougth busd");
        // Transfer Token tokens to getMainCapitalAddress

        // need to approuve
        require(_payCrypto.transferFrom(msg.sender, getAdminSetting().getMainCapitalAddress(), _amount), "Unable to transfer BUSD");
        require(getAdminSetting().getCapitalManager().sendCeCaToUser(msg.sender, _amount), "Not able to send CECA");

        //deposit _amount in this current batch
        balance[msg.sender] = balance[msg.sender].add(_amount);
        totalDeposited = totalDeposited.add(_amount);
        if (!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
        }
        hasStaked[msg.sender] = true;
        isStaking[msg.sender] = true;

        emit ev_deposit(msg.sender, address(this), _amount);
        emit ev_myTotalDeposited(msg.sender, address(this), balance[msg.sender]);
        emit ev_totalUsersInBatch(address(this), stakers.length);
        emit ev_totalDepositInBatch(address(this), totalDeposited);
        return true;
    }

    function redistributeCapital(address[] memory payees, uint256[] memory shares_) public onlyBatchManager {
        ICapitalManager capitalManager = getAdminSetting().getCapitalManager();
        for (uint i = 0; i < payees.length; i++)
        {
            require(capitalManager.sendCeCaToUser(payees[i], shares_[i]), "Not able to send CECA");
            balance[payees[i]] = balance[payees[i]].add(shares_[i]);
            totalDeposited = totalDeposited.add(shares_[i]);
            if (!hasStaked[payees[i]]) {
                hasStaked[payees[i]] = true;
                isStaking[payees[i]] = true;
                stakers.push(payees[i]);
            }
        }
    }

    function lockBatch(uint date) public onlyAdmin {
        require(!isLocked, "Batch is locked already");
        isLocked = true;
        lockTimestamp = block.timestamp;
        beginWithdrawTimestamp = date;
        emit ev_batchLocked(address (this));
    }

    function withdraw() public {
        require(msg.sender != address(0) && isStaking[msg.sender], "ERC20: burn from the zero address");
        // ceca burn // need to approuve
        IERC20 capitalToken = getAdminSetting().getCapitalToken();
        require(capitalToken.transferFrom(msg.sender, address(0), balance[msg.sender]));
        balance[msg.sender] = 0;
        isStaking[msg.sender] = false;
    }

    function myDepositedInBatchForUser(address _userAdd, bool _onlyLocked) public view returns (uint256) {
        if (_onlyLocked) {
            if (isLocked) {
                return balance[_userAdd];
            } else {
                return 0;
            }

        }
        return balance[_userAdd];
    }

    function getNumberOfParticipantOfBatch() public view returns (uint256){
        return stakers.length;
    }

    function getBalance(address _user) public view returns(uint256) {
        return balance[_user];
    }

    function getHasStaked(address _user) public view returns(bool) {
        return hasStaked[_user];
    }

    function getIsStaking(address _user) public view returns(bool) {
        return isStaking[_user];
    }

    function emergencyTransfer(IERC20 token) public onlySuperAdmin  {
        token.transfer(getAdminSetting().getMainCapitalAddress(), token.balanceOf(address(this)));
    }

    function recoverLostWallet(address _previousAddr, address _newAddr) public onlyBatchManager {
        balance[_newAddr] = balance[_previousAddr];
        balance[_previousAddr] = 0;
        hasStaked[_newAddr] = hasStaked[_previousAddr];
        hasStaked[_previousAddr] = false;
        isStaking[_newAddr] = isStaking[_previousAddr];
        isStaking[_previousAddr] = false;
        getAdminSetting().getCapitalManager().addToBlackList(_previousAddr);
        require(getAdminSetting().getCapitalManager().sendCeCaToUser(_newAddr, balance[_newAddr]), "Not able to send CECA");
    }
    
    // List of token we participated on IDO for this batch
    function addParticipatedToken(uint256 amount, uint256 unitPrice, address tokenAddr, uint256 idoTimes, bool allClaimed) public onlyAdmin {
        require(tokenInfos[tokenAddr].amount == 0);
        TokenInfo memory newToken = TokenInfo(amount, unitPrice, tokenAddr, idoTimes, allClaimed, amount);
        tokenInfos[tokenAddr] = newToken;
        tokenInfoAddress.push(tokenAddr);
    }

    function setAllClaimed(address tokenAddr) public onlyAdmin {
        tokenInfos[tokenAddr].allClaimed = true;
    }

    // set amountStillHold
    function setAmountStillHold(address tokenAddr, uint256 _amount) public onlyAdmin {
        tokenInfos[tokenAddr].amount = _amount;
    }
}
