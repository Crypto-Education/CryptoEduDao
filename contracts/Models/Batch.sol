// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";

contract Batch is CeEduOwnable {
    using Address for address;
    using SafeERC20 for IERC20;

    string public name;
    uint256 public openedTimestamp;
    uint256 public lockTimestamp;
    uint256 public beginWithdrawTimestamp;
    bool public isLocked;
    uint256 public totalDeposited;
    uint256 public totalWithdraw;

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

    event ev_deposit(address indexed _from, address indexed _btachId, uint256 _value);
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

    modifier onlyManagersContracts() {
        require(msg.sender == address (getAdminSetting().getBatchManager())
            || msg.sender == address (getAdminSetting().getCapitalManager())
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
        totalDeposited += _amount;

        emit ev_deposit(msg.sender, address(this), _amount);
        return true;
    }

    function redistributeCapital(address[] memory payees, uint256[] memory shares_) public onlyManagersContracts {
        ICapitalManager capitalManager = getAdminSetting().getCapitalManager();
        for (uint i = 0; i < payees.length; i++)
        {
            require(capitalManager.sendCeCaToUser(payees[i], shares_[i]), "Not able to send CECA");
            totalDeposited += shares_[i];
        }
    }

    function lockBatch(uint date) public onlyAdmin {
        require(!isLocked, "Batch is locked already");
        isLocked = true;
        lockTimestamp = block.timestamp;
        beginWithdrawTimestamp = date;
        emit ev_batchLocked(address (this));
    }

    function exitBatch() public {
        require(msg.sender != address(0) && isStaking(msg.sender), "ERC20: burn from the zero address");
        // ceca burn // need to approuve
        IERC20 capitalToken = getAdminSetting().getCapitalToken(address(this));
        require(capitalToken.transferFrom(msg.sender, address(0), getBalance(msg.sender)));
    }

    function myDepositedInBatchForUser(address _userAdd, bool _onlyLocked) public view returns (uint256) {
        if (_onlyLocked && !isLocked) {
            return 0;
        }
        return getBalance(_userAdd);
    }
    
    function myDepositedInBatchForUser(address _userAdd, bool _onlyLocked, uint256 snap) public returns (uint256) {
        if (_onlyLocked && !isLocked) {
            return 0;
        }
        return getBalance(_userAdd, snap);
    }
    
    function getBalance(address _user, uint256 snap) public returns(uint256) {
        return  getAdminSetting().getCapitalManager().getCapitalToken(address(this)).balanceOfAt(_user, getAdminSetting().getSnapshopFor(snap, address(this)));
    }

    function getBalance(address _user) public view returns(uint256) {
        return  getAdminSetting().getCapitalToken(address(this)).balanceOf(_user);
    }

    function isStaking(address _user) public view returns(bool) {
        return getBalance(_user) > 0;
    }

    function emergencyTransfer(IERC20 token) public onlySuperAdmin  {
        token.transfer(getAdminSetting().getMainCapitalAddress(), token.balanceOf(address(this)));
    }

    function recoverLostWallet(address _previousAddr, address _newAddr) public onlyManagersContracts {
        require(!getAdminSetting().getCapitalManager().isBlacklisted(_previousAddr));
        getAdminSetting().getCapitalManager().addToBlackList(_previousAddr);
        require(getAdminSetting().getCapitalManager().sendCeCaToUser(
            _newAddr, 
            getBalance(_previousAddr)
            ), "Not able to send CECA");
    }
    
    // List of token we participated on IDO for this batch
    function addParticipatedToken(uint256 amount, uint256 unitPrice, address tokenAddr, uint256 idoTimes, bool allClaimed) public onlyAdmin {
        require(tokenInfos[tokenAddr].amount == 0);
        TokenInfo memory newToken = TokenInfo(amount, unitPrice, tokenAddr, idoTimes, allClaimed, amount);
        tokenInfos[tokenAddr] = newToken;
        tokenInfoAddress.push(tokenAddr);
    }

    function setTokenInformation(address tokenAddr, bool allClaimed, uint256 _amount) public onlyAdmin {
        tokenInfos[tokenAddr].allClaimed = allClaimed;
        tokenInfos[tokenAddr].amount = _amount;
    }
}
