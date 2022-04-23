//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8;

import "@openzeppelin/contracts/utils/Address.sol";
import "./CeEduOwnable.sol";
import "./CapitalManager.sol";
import "./CeCaBatch.sol";

contract BatchCreator is CeEduOwnable {

    using Address for address;
    address public mainCapitalAddress; // address to receive all capital deposited

    CapitalManager public capitalManager;
    CryptoEduCapitalToken public capitalToken;
    IERC20 public busdToken;
    string name;

    constructor(CapitalManager _capitalManager, address _busdToken, address _mainAddress)
    {
        capitalManager = _capitalManager;
        busdToken = IERC20(_busdToken);
        mainCapitalAddress = _mainAddress;
        name = 'CEDU_BatchCreator';
    }
    event ev_batchCreated(CeCaBatch _ceCaBatchId);
    function createAppendBatch(string memory _name, bool _locked) external onlyOwner returns (bool) {
        CeCaBatch newBatch = new CeCaBatch(_name, busdToken, mainCapitalAddress, capitalManager, _locked);
        newBatch.transferOwnership(this.getOwner());
        capitalManager.pushBatch(newBatch);
        emit ev_batchCreated(newBatch);
        return true;
    }
}
