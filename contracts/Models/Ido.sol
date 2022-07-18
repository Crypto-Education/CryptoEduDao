// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";

contract Ido is CeEduOwnable {
    using Address for address;
    using SafeERC20 for IERC20;

    uint256 public totalDeposited;
    uint256 public numberOfTokenFromIdo;
    uint256 public numberOfTokenDistributed;
    uint256 public idoTotalWeight;
    IERC20 public tokenToTransfer;
    string public name;
    uint256 public openedTimestamp;
    uint256 public lockTimestamp;
    bool public isLocked;
    bool public isCompleted;
    uint256 public maxPerUser;
    address[] public stakers;
    uint256 public priceSpentForToken;
    mapping (address => bool) public hasParticipated;
    mapping (address => uint256) public balanceOfParticipant;
    mapping (address => uint) public weightOfParticipant;

    uint256 public snapshopsId;

    event tokenAddressSet(address indexed _idoId, IERC20 _tokenAddress);
    event idoDepositLocked(address indexed _idoId);
    event idoNewIdoAdded(address indexed _idoId);

    constructor(string memory _name, uint256 _maxPerUser, address daoAdmin) CeEduOwnable (daoAdmin) {
        name = _name;
        isLocked = false;
        isCompleted = false;
        openedTimestamp = block.timestamp;
        maxPerUser = _maxPerUser;
        emit idoNewIdoAdded(address (this));
    }
    modifier mostHaveTakenSnapShot() {
        require(snapshopsId != 0, "most have taken snap");
        _;
    }

    modifier isEligibleForIdo() {
        require(
            isEligible(),
            "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"
        );
        _;
    }

    function isEligible() public returns(bool) {
        if (getAdminSetting().checkEligibility(msg.sender, snapshopsId, address(0))) {
            return balanceOfParticipant[msg.sender] < maxPerUser;
        }
        return false;
    }

    function depositForIdo(uint256 _amount, IERC20 _payCrypto) public noReEntrancy isEligibleForIdo returns (bool)  {
        // Require amount greater than 0
        require(getAdminSetting().tokenIsAcceptedIdo(address(_payCrypto)) && _payCrypto.balanceOf(msg.sender) >= _amount, "No enough Token to pay");
        require(_amount >= 0 && _amount + balanceOfParticipant[msg.sender] <= maxPerUser && !isLocked, "amount cannot be 0 and should be less than maximum");
        // Transfer 
        // approve
        require(_payCrypto.transferFrom(msg.sender, getAdminSetting().getIdoReceiverAddress(), _amount), "Unable to transfer crypto");

        balanceOfParticipant[msg.sender] += _amount;
        totalDeposited += _amount;

        if (!hasParticipated[msg.sender]) {
            stakers.push(msg.sender);
            hasParticipated[msg.sender] = true;
        }
        weightOfParticipant[msg.sender] = getAdminSetting().getBatchManager().getUserWeight(msg.sender, snapshopsId); // because weith can change from ido to IDO we need to keep track of in each IDO
        return true;
    }

    function setIdoToken(IERC20 _token, uint256 _numberOfToken, uint256 _totalAmountSpent) public noReEntrancy onlyAdmin {
        require(isLocked && priceSpentForToken == 0, "Ido should be locked or Price is already set");
        tokenToTransfer = _token;
        numberOfTokenFromIdo = _numberOfToken;
        priceSpentForToken = _totalAmountSpent;
        idoTotalWeight = getSumOfAllWeight();

        // redistribute the extra deposited 
        for (uint i = 0; i < stakers.length; i++) {
            // to correct
            uint256 amountPerUser = ((priceSpentForToken * 1000 / idoTotalWeight) * (weightOfParticipant[stakers[i]]) / 1000) + getAdminSetting().getTransactionFeesPerBatch();
            if (balanceOfParticipant[stakers[i]] > amountPerUser) {
                // set the extra according to his weight to be used for next ido
                getAdminSetting().getCUSDToken().mint(stakers[i], balanceOfParticipant[stakers[i]] - amountPerUser);
                // real amount considered for this IDO
                balanceOfParticipant[stakers[i]] = amountPerUser;
            }
        }
        emit tokenAddressSet(address (this), _token);
        redistributeIdoToken();
    }

    function idoLockDeposit() public noReEntrancy onlyAdmin {
        isLocked = true;
        lockTimestamp = block.timestamp;
        emit idoDepositLocked(address (this));
    }

    function redistributeIdoToken() public noReEntrancy {
        //keep in mind that the 1% percent is not transfer (for the team)
        uint256 onePercent = numberOfTokenFromIdo / 100;
        uint256 remainingToDistribute = numberOfTokenFromIdo - onePercent - numberOfTokenDistributed;
        uint256 amountToDistributeNow = remainingToDistribute;
        uint256 thisAddressBalance = tokenToTransfer.balanceOf(address(this));

        if (thisAddressBalance == 0) {
            return;
        }
        // no need to approve because tokens are in this contract
        
        if (thisAddressBalance <= remainingToDistribute) {
            amountToDistributeNow = thisAddressBalance;
        }

        for (uint i = 0; i < stakers.length; i++) {
            if (balanceOfParticipant[stakers[i]] > 0) {
                uint256 amountPerUser = amountToDistributeNow / idoTotalWeight * weightOfParticipant[stakers[i]];
                tokenToTransfer.transfer(
                    stakers[i],
                    amountPerUser
                );
            }
        }
        // set the new total distributed
        numberOfTokenDistributed += amountToDistributeNow;
        // close the ido and send the rest to the team address
        if (amountToDistributeNow == remainingToDistribute) {
            isCompleted = true;
            tokenToTransfer.transfer(
                getAdminSetting().getTeamAddress(),
                onePercent
            );
        }
    }

    function getSumOfAllWeight() public view returns(uint256) {
        uint256 sum = 0;
        for (uint i = 0; i < stakers.length; i++) {
            if (balanceOfParticipant[stakers[i]] > 0) {
                sum += weightOfParticipant[stakers[i]];
            }
        }
        return sum;
    }
    
    function emergencyTransfer(IERC20 token) public noReEntrancy onlySuperAdmin {
        token.transfer(getAdminSetting().getIdoReceiverAddress(), token.balanceOf(address(this)));
    }


    function myDepositedInIdo() public view returns (uint256) {
        return balanceOfParticipant[msg.sender];
    }

    function getNumberOfParticipantOfIdo() public view returns (uint256){
        return stakers.length;
    }

    /*
     * Balance of functions to extend smart contract functionnalities
     */
    function getBalanceOfParticipant(address _user) public view  returns(uint256) {
        return balanceOfParticipant[_user];
    }

    function getHasStaked(address _user) public view returns(bool) {
        return hasParticipated[_user];
    }

    function getWeightOfParticipant(address _user) public view returns(uint256) {
        return weightOfParticipant[_user];
    }

    function getStakers() public view returns(address[] memory) {
        return stakers;
    }

    function setMaxUser(uint256 max) public onlyAdmin {
        maxPerUser = max;
    }

    function takeSnapshop() public onlyAdmin {
        snapshopsId = block.timestamp;
        getAdminSetting().takeSnapshop(snapshopsId);
    }
}
