// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "../Users/CDAOAdmins.sol";
import "../Users/CeEduOwnable.sol";
import "../Models/Ido.sol";

contract IdoManager is CeEduOwnable {
    using Address for address;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    string public name;

    CeCaIdo[] public idoInformationList;
    event idoNewIdoAdded(address indexed _idoId);

    constructor() {
        name = 'CEDU_IdoCryptoEduManager';
        CDAOAdmins settings = getAdminSetting();
        settings.setIdoManager(this);
    }

    function initialiseNewIdo(string memory _name, uint256 _maxPerUser) public onlyAdmin returns (bool) {
        CeCaIdo newIdo = new CeCaIdo(_name);
        idoInformationList.push(newIdo);
        emit idoNewIdoAdded(address(newIdo));
        return true;
    }

    function emergencyTransfer(address token) public onlySuperAdmin {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(idoBusdAddress, tokenToTransfer.balanceOf(address(this)));
    }

    function getIdoListSize() public view returns (uint) {
        return idoInformationList.length;
    }

    function transfertMinterShip(address _newMinter) public onlySuperAdmin {
        capitalToken.passMinterRole(_newMinter);
    }
}
