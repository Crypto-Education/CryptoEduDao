// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "../Users/CeEduOwnable.sol";

contract Wallet is CeEduOwnable {
    // Library usage
    using SafeERC20 for IERC20;
    bool locker;

    address[] public approvers;
    mapping(address => bool) public approversMap;
    uint public quorum;
    struct Transfer {
      uint id;
      uint amount;
      address payable to;
      uint approvals;
      bool sent;
      IERC20 token;
    }

    Transfer[] public transfers;
    mapping(address => mapping(uint => bool)) public approvals;

    constructor(address[] memory _approvers, uint _quorum, address _admin) CeEduOwnable(_admin) {
      approvers = _approvers;
      quorum = _quorum;
      for(uint i; i < _approvers.length; i++) {
          approversMap[_approvers[i]] = true;
      }
    }


    receive() external payable {}

    function getApprovers() external view returns(address[] memory) {
      return approvers;
    }

    function getTransfers() external view returns(Transfer[] memory) {
      return transfers;
    }

    function createTransfer(uint amount, address payable to, address _token) external onlyApprover {
      transfers.push(Transfer(
        transfers.length,
        amount,
        to,
        0,
        false,
        IERC20(_token)
      ));
    }

    function approveTransfer(uint id) external onlyApprover {
      require(approvals[msg.sender][id] == false, 'cannot approve transfer twice');
      approvals[msg.sender][id] = true;
      transfers[id].approvals++;

      if(transfers[id].approvals >= quorum) {
        excecuteTransfer(id);
      }
    }

    function excecuteTransfer(uint id) public onlyApprover quorumMet(id) noReentrancy {
        if (transfers[id].sent == true) {
          return;
        }
        address payable to = transfers[id].to;
        uint amount = transfers[id].amount;

        // we want to sent maint coin
        if (address(transfers[id].token) == address(0)) {
            if (address(this).balance > amount) {
              (bool result,) = to.call{value:amount}("");
              transfers[id].sent = true;
            }
        } else {
          if (transfers[id].token.balanceOf(address(this)) >= amount) {
              transfers[id].token.transfer(address(this), amount);
              transfers[id].sent = true;
          }
        }
    }

    modifier onlyApprover() {
      require(approversMap[msg.sender] == true, 'only approver allowed');
      _;
    }

    modifier quorumMet(uint id) {
      require(transfers[id].approvals >= quorum, 'quorum not yest met');
      _;
    }

    modifier noReentrancy() {
        locker = true;
        _;
        locker = false;
    }
}
