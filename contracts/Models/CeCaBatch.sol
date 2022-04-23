//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Tokens/CECAToken.sol";
import "../Users/CeEduOwnable.sol";
import "../Managers/CapitalManager.sol";

contract CeCaBatch is CeEduOwnable {
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
    mapping (address => uint256) public balance;
    mapping (address => bool) public hasStaked;
    mapping (address => bool) public isStaking;

    event ev_deposit(address indexed _from, address indexed _btachId, uint256 _value);
    event ev_totalDepositInBatch(address indexed _btachId, uint256 _value);
    event ev_myTotalDeposited(address indexed _from, address indexed _btachId, uint256 _value);
    event ev_totalUsersInBatch(address indexed _btachId, uint256 _value);

    event ev_newBatchAdded(address indexed _btachId);
    event ev_batchLocked(address indexed _btachId);

    constructor(string memory _name, bool _locked)
    {
        name = _name ;
        isLocked = _locked;
        openedTimestamp = block.timestamp;
        if (_locked) {
            lockTimestamp = block.timestamp;
        }
    }

    modifier onlyCapitalManager() {
        CDAOAdmins settings = getAdminSetting();
        require(msg.sender == address (settings.getCapitalManagerAddress()), "");
        _;
    }

    function depositInCapital(uint256 _amount, IERC20 _payCrypto) public returns (bool) {
        // Require amount greater than 0
        require(_amount >= 0 && !isLocked, "Cant deposit bach is locked or amount ");
        require(tokenIsAccepted(_payCrypto) && _payCrypto.balanceOf(msg.sender) >= _amount, "You dont have enougth busd");
        // Transfer Token tokens to getMainCapitalAddress staking

        CDAOAdmins settings = getAdminSetting();
        CapitalManager capitalManager = settings.getCapitalManager();

        require(_payCrypto.transferFrom(msg.sender, settings.getMainCapitalAddress(), _amount), "Unable to transfer BUSD");
        require(capitalManager.sendCeCaToUser(msg.sender, _amount), "Not able to send CECA");

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

    function redistributeCapital(address[] memory payees, uint256[] memory shares_) public onlyCapitalManager returns (bool) {
        CDAOAdmins settings = getAdminSetting();
        CapitalManager capitalManager = settings.getCapitalManager();
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

    function getBalance(address _user) public returns(uint256) {
        return balance[_user];
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

    function recoverLostWallet(address _previousAddr, address _newAddr) internal {
        balance[_newAddr] = balance[_previousAddr];
        balance[_previousAddr] = 0;
        hasStaked[_newAddr] = hasStaked[_previousAddr];
        hasStaked[_previousAddr] = false;
        isStaking[_newAddr] = isStaking[_previousAddr];
        isStaking[_previousAddr] = 0;
        capitalManager.addToBlackList(_previousAddr);
    }


}
