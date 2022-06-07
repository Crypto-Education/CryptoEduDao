// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CDAOAdmins.sol";
import "../Users/CeEduOwnable.sol";
import "../Models/Ido.sol";

contract IdoManager is CeEduOwnable {
    using Address for address;
    using SafeERC20 for IERC20;

    string public name;

    Ido[] public idoInformationList;
    event idoNewIdoAdded(address indexed _idoId);

    constructor(address daoAdmin) CeEduOwnable (daoAdmin) {
        name = 'CEDU_IdoCryptoEduManager';
        /*CDAOAdmins settings = getAdminSetting();
        settings.setIdoManager(this);*/
    }

    function initialiseNewIdo(string memory _name, uint256 _maxPerUser) public onlyAdmin returns (bool) {
        Ido newIdo = new Ido(_name, _maxPerUser, address(getAdminSetting()));
        idoInformationList.push(newIdo);
        emit idoNewIdoAdded(address(newIdo));
        return true;
    }

    function emergencyTransfer(address token) public onlySuperAdmin {
        IERC20 tokenToTransfer = IERC20(token);
        tokenToTransfer.transfer(getAdminSetting().getMainCapitalAddress(), tokenToTransfer.balanceOf(address(this)));
    }

    function getIdoListSize() public view returns (uint) {
        return idoInformationList.length;
    }

    function transfertMinterShip(address _newMinter) public onlySuperAdmin {
        getAdminSetting().getCapitalManager().transferMinterShip(_newMinter);
    }
    

    function getIdo(uint index) public view returns(address) {
        return address(idoInformationList[index]);
    }
}
