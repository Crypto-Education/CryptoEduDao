//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./CryptoEduCapitalToken.sol";
import "./CapitalManager.sol";
import "./CeEduOwnable.sol";
import "./CeCaIdo.sol";

contract IdoCryptoEduManager is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string public name;
    address public idoMainAddress; // address eligible for ICO
    address public idoBusdAddress; // address to receive IDO amount
    address private teamAddress; // address to receive IDO amount

    IERC20 public busdToken;
    CryptoEduCapitalToken public capitalToken;
    CapitalManager public capitalManager;

    CeCaIdo[] public idoInformationList;

    event tokenAddressSet(uint256 indexed _idoId, address _tokenAddress);
    event idoDepositLocked(uint256 indexed _idoId);
    event idoNewIdoAdded(uint256 indexed _idoId);

    constructor(
        CapitalManager _capitalManager,
        CryptoEduCapitalToken _capitalToken,
        address _busdToken,
        address _idoMainAddress,
        address _idoBusdAddress,
        address _teamAddress
    ) {
        capitalManager = _capitalManager;
        capitalToken = _capitalToken;
        busdToken = IERC20(_busdToken);
        idoMainAddress = _idoMainAddress;
        idoBusdAddress = _idoBusdAddress;
        teamAddress = _teamAddress;
        name = 'CEDU_IdoCryptoEduManager';
    }

    function initialiseNewIdo(string memory _name, uint256 _maxPerUser) public onlyOwner returns (bool) {
        CeCaIdo newIdo = new CeCaIdo(
            capitalManager,
            capitalToken,
            this,
            _name,
            _maxPerUser,
            busdToken,
            idoMainAddress,
            idoBusdAddress,
            teamAddress);
        newIdo.transferOwnership(this.getOwner());
        idoInformationList.push(newIdo);
        return true;
    }

    function emergencyTransfer(address token) public onlyOwner {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(idoBusdAddress, tokenToTransfer.balanceOf(address(this)));
    }

    function getIdoListSize() public view returns (uint) {
        return idoInformationList.length;
    }

    function transfertMinterShip(address _newMinter) public onlyOwner {
        capitalToken.passMinterRole(_newMinter);
    }
}
