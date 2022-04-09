//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./CryptoEduFarmToken.sol";
import "./CryptoEduCapitalToken.sol";
import "./IdoCryptoEduManager.sol";
import "./CapitalManager.sol";
import "./CeEduOwnable.sol";

contract CeCaIdo is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address public idoMainAddress; // address eligible for ICO
    address public idoBusdAddress; // address to receive IDO amount
    address private teamAddress; // address to receive IDO amount

    IERC20 private busdToken;
    CryptoEduCapitalToken private capitalToken;
    CapitalManager private capitalManager;
    IdoCryptoEduManager private idoCryptoEduManager;

    uint256 public totalDeposited;
    uint256 public numberOfTokenFromIdo;
    uint256 public numberOfTokenDistributed;
    uint256 public idoTotalWeight;
    uint256 public idoId;
    address public tokenAddress;
    string public name;
    uint256 public openedTimestamp;
    uint256 public lockTimestamp;
    bool public isLocked;
    bool public isCompleted;
    bool public distributionEnded;
    uint256 public maxPerUser;
    address[] public stakers;
    uint256 public priceSpentPerToken;
    mapping (address => bool) public hasParticipated;
    mapping (address => uint256) public listOfParticipant;
    mapping (address => uint) public weightOfParticipant;

    event tokenAddressSet(address indexed _idoId, address _tokenAddress);
    event idoDepositLocked(address indexed _idoId);
    event idoNewIdoAdded(address indexed _idoId);

    constructor(
        CapitalManager _capitalManager,
        CryptoEduCapitalToken _capitalToken,
        IdoCryptoEduManager _idoCryptoEduManager,
        string memory _name,
        uint256 _maxPerUser,
        IERC20 _busdToken,
        address _idoMainAddress,
        address _idoBusdAddress,
        address _teamAddress
    ) {
        capitalManager = _capitalManager;
        capitalToken = _capitalToken;
        idoCryptoEduManager = _idoCryptoEduManager;
        busdToken = _busdToken;
        idoMainAddress = _idoMainAddress;
        idoBusdAddress = _idoBusdAddress;
        teamAddress = _teamAddress;
        name = _name;
        isLocked = false;
        isCompleted = false;
        distributionEnded = false;
        openedTimestamp = block.timestamp;
        maxPerUser = _maxPerUser;
    }

    modifier isEligibleForIdo() {
        bool checkElig = checkEligibility(msg.sender);
        require(
            checkElig == true,
            "Amount deposited in capital is not enough or not having all deposited Ceca in your wallet"
        );
        _;
    }

    function checkEligibility(address sender) public returns(bool) {
        return capitalManager.checkEligibility(sender);
    }

    function isEligible() public returns(bool) {
        if (checkEligibility(msg.sender)) {
            return listOfParticipant[msg.sender] < maxPerUser;
        }
        return false;
    }
    function setIdoToken(address _tokenAddress, uint256 _numberOfToken, uint256 _totalBusdSpent) public onlyOwner {
        require(isLocked, "Ido should be locked");
        require(priceSpentPerToken == 0, "Price is already set");
        tokenAddress = _tokenAddress;
        numberOfTokenFromIdo = _numberOfToken;
        priceSpentPerToken = _totalBusdSpent;
        uint256 totalWeight = getSumOfAllWeight();
        uint256 amountPerWeight = _numberOfToken.div(totalWeight);
        idoTotalWeight = totalWeight;
        // redistribute the extra
        for (uint i = 0; i < stakers.length; i++) {
            //amountPerWeight*weight*_idoPricePerToken-transactionFeesPerBatch
            uint256 amountPerUser = _totalBusdSpent.div(totalWeight).mul(weightOfParticipant[stakers[i]])
            .add(capitalManager.transactionFeesPerBatch());
            if (listOfParticipant[stakers[i]] > amountPerUser) {
                // send back extra busd
                busdToken.transferFrom(
                    msg.sender,
                    stakers[i],
                    listOfParticipant[stakers[i]].sub(amountPerUser)
                );
                listOfParticipant[stakers[i]] = amountPerUser;
            }
        }
        emit tokenAddressSet(address (this), _tokenAddress);
        redistributeIdoToken();
    }

    function idoLockDeposit() public onlyOwner {
        isLocked = true;
        lockTimestamp = block.timestamp;
        emit idoDepositLocked(address (this));
    }

    function redistributeIdoToken() public onlyOwner {
        //keep that the 1%one percent is not transfer (for the team)
        uint256 onePercent = numberOfTokenFromIdo.div(100);
        uint256 remainingToDistribute = numberOfTokenFromIdo.sub(onePercent).sub(numberOfTokenDistributed);
        uint256 amountToDistributeNow = remainingToDistribute;
        IERC20 tokenToTransfer = IERC20(tokenAddress);
        // approve
        if (remainingToDistribute > 0) {
            uint256 mainAddressBalance = tokenToTransfer.balanceOf(msg.sender);
            if (mainAddressBalance < remainingToDistribute) {
                amountToDistributeNow = mainAddressBalance;
            }
            numberOfTokenDistributed.add(amountToDistributeNow);
            for (uint i = 0; i < stakers.length; i++) {
                if (listOfParticipant[stakers[i]] > 0) {
                    uint256 amountPerUser = amountToDistributeNow.div(idoTotalWeight)
                        .mul(weightOfParticipant[stakers[i]]);
                    tokenToTransfer.transferFrom(
                        msg.sender,
                        stakers[i],
                        amountPerUser
                    );
                }
            }
        }
        // close the ido and send the rest to the team address
        if (amountToDistributeNow == remainingToDistribute) {
            isCompleted = true;
            tokenToTransfer.transferFrom(
                msg.sender,
                teamAddress,
                onePercent
            );
        }
    }

    function depositForIdo(uint256 _amount) public isEligibleForIdo returns (bool)  {
        // Require amount greater than 0
        require(_amount >= 0 && _amount.add(listOfParticipant[msg.sender]) <= maxPerUser && !isLocked, "amount cannot be 0 and should be less than maximum");
        require(busdToken.balanceOf(msg.sender) >= _amount, "No enough BUSD");
        // Transfer BUSD tokens to this contract for staking
        require(busdToken.transferFrom(msg.sender, idoBusdAddress, _amount), "Unable to transfer BUSD");

        listOfParticipant[msg.sender] = listOfParticipant[msg.sender].add(_amount);
        totalDeposited = totalDeposited.add(_amount);

        if (!hasParticipated[msg.sender]) {
            stakers.push(msg.sender);
        }
        hasParticipated[msg.sender] = true;
        weightOfParticipant[msg.sender] = capitalManager.getUserWeight(msg.sender);
        emit idoNewIdoAdded(address (this));
        return true;
    }
    function getSumOfAllWeight() public returns(uint256) {
        uint256 sum = 0;
        for (uint i = 0; i < stakers.length; i++) {
            if (listOfParticipant[stakers[i]] > 0) {
                sum = sum.add(weightOfParticipant[stakers[i]]);
            }
        }
        return sum;
    }
    
    function emergencyTransfer(address token) public onlyOwner {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(idoBusdAddress, tokenToTransfer.balanceOf(address(this)));
    }


    function myDepositedInIdo() public view returns (uint256) {
        return listOfParticipant[msg.sender];
    }

    function getNumberOfParticipantOfIdo() public view returns (uint256){
        return stakers.length;
    }

    event idoBusdAddressChanged(address idoBusdAddress, address _address);
    function setIdoBusdAddress(address _address) public onlyOwner {
        emit idoBusdAddressChanged(idoBusdAddress, _address);
        idoBusdAddress = _address;
    }

    event teamAddressChanged(address teamAddress, address _address);
    function setTeamAddress(address _address) public onlyOwner{
        emit teamAddressChanged(teamAddress, _address);
        teamAddress = _address;
    }

    /*
     * List of functions to extend smart contract functionnalities
     */
    function getListOfParticipant(address _user) public returns(uint256) {
        return listOfParticipant[_user];
    }

    function getHasStaked(address _user) public returns(bool) {
        return hasParticipated[_user];
    }

    function getWeightOfParticipant(address _user) public returns(uint256) {
        return weightOfParticipant[_user];
    }
    function getStakers() public returns(address[] memory) {
        return stakers;
    }
}
