// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";

contract Ido is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public totalDeposited;
    uint256 public numberOfTokenFromIdo;
    uint256 public numberOfTokenDistributed;
    uint256 public idoTotalWeight;
    address public tokenAddress;
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

    event tokenAddressSet(address indexed _idoId, address _tokenAddress);
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

    modifier isEligibleForIdo() {
        require(
            isEligible(),
            "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"
        );
        _;
    }

    function isEligible() public view returns(bool) {
        if (getAdminSetting().checkEligibility(msg.sender)) {
            return balanceOfParticipant[msg.sender] < maxPerUser;
        }
        return false;
    }
    function setIdoToken(address _tokenAddress, uint256 _numberOfToken, uint256 _totalAmountSpent,IERC20 _payCrypto) public onlyAdmin {
        require(isLocked && priceSpentForToken == 0, "Ido should be locked or Price is already set");
        require(getAdminSetting().tokenIsAccepted(address(_payCrypto)), "No enough Token to pay");
        tokenAddress = _tokenAddress;
        numberOfTokenFromIdo = _numberOfToken;
        priceSpentForToken = _totalAmountSpent;
        uint256 totalWeight = getSumOfAllWeight();
        idoTotalWeight = totalWeight;
        // redistribute the extra deposited 
        for (uint i = 0; i < stakers.length; i++) {
            uint256 amountPerUser = priceSpentForToken.div(totalWeight).mul(weightOfParticipant[stakers[i]]).add(getAdminSetting().getTransactionFeesPerBatch());
            if (balanceOfParticipant[stakers[i]] > amountPerUser) {
                // send back extra busd
                _payCrypto.transfer(
                    stakers[i],
                    balanceOfParticipant[stakers[i]].sub(amountPerUser)
                );
                balanceOfParticipant[stakers[i]] = amountPerUser;
            }
        }
        emit tokenAddressSet(address (this), _tokenAddress);
        redistributeIdoToken();
    }

    function idoLockDeposit() public onlyAdmin {
        isLocked = true;
        lockTimestamp = block.timestamp;
        emit idoDepositLocked(address (this));
    }

    function redistributeIdoToken() public {
        //keep in mind that the 1%one percent is not transfer (for the team)
        uint256 onePercent = numberOfTokenFromIdo.div(100);
        uint256 remainingToDistribute = numberOfTokenFromIdo.sub(onePercent).sub(numberOfTokenDistributed);
        uint256 amountToDistributeNow = remainingToDistribute;
        IERC20 tokenToTransfer = IERC20(tokenAddress);
        
        uint256 thisAddressBalance = tokenToTransfer.balanceOf(address(this));

        require(remainingToDistribute > 0 && thisAddressBalance > 0, "not enogth to redistribute");
        // no need to approve because tokens are in this contract
        
        if (thisAddressBalance <= remainingToDistribute) {
            amountToDistributeNow = thisAddressBalance;
        }
        
        
        for (uint i = 0; i < stakers.length; i++) {
            if (balanceOfParticipant[stakers[i]] > 0) {
                uint256 amountPerUser = amountToDistributeNow.div(idoTotalWeight).mul(weightOfParticipant[stakers[i]]);
                tokenToTransfer.transfer(
                    stakers[i],
                    amountPerUser
                );
            }
        }
        // set the new total distributed
        numberOfTokenDistributed = numberOfTokenDistributed.add(amountToDistributeNow);
        // close the ido and send the rest to the team address
        if (amountToDistributeNow == remainingToDistribute) {
            isCompleted = true;
            tokenToTransfer.transfer(
                getAdminSetting().getTeamAddress(),
                onePercent
            );
        }
    }

    function depositForIdo(uint256 _amount, IERC20 _payCrypto) public isEligibleForIdo returns (bool)  {
        // Require amount greater than 0
        require(_amount >= 0 && _amount.add(balanceOfParticipant[msg.sender]) <= maxPerUser && !isLocked, "amount cannot be 0 and should be less than maximum");
        require(getAdminSetting().tokenIsAccepted(address(_payCrypto)) && _payCrypto.balanceOf(msg.sender) >= _amount, "No enough Token to pay");
        // Transfer 
        require(_payCrypto.transferFrom(msg.sender, getAdminSetting().getIdoReceiverAddress(), _amount), "Unable to transfer crypto");

        balanceOfParticipant[msg.sender] = balanceOfParticipant[msg.sender].add(_amount);
        totalDeposited = totalDeposited.add(_amount);

        if (!hasParticipated[msg.sender]) {
            stakers.push(msg.sender);
            hasParticipated[msg.sender] = true;
        }
        weightOfParticipant[msg.sender] = getAdminSetting().getBatchManager().getUserWeight(msg.sender); // because weith can change from ido to IDO we need to keep track of in each IDO
        return true;
    }

    function getSumOfAllWeight() public view returns(uint256) {
        uint256 sum = 0;
        for (uint i = 0; i < stakers.length; i++) {
            if (balanceOfParticipant[stakers[i]] > 0) {
                sum = sum.add(weightOfParticipant[stakers[i]]);
            }
        }
        return sum;
    }
    
    function emergencyTransfer(IERC20 token) public onlySuperAdmin {
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
}
