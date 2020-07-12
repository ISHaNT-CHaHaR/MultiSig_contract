pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

contract Wallet {
    address[] approvers; // for the array of addresses that are going to apprive ethereum address
    uint256 public quorum; // the limit to spend ethereum when approved.

    struct Transfer {
        uint256 id;
        uint256 amount;
        address payable to;
        uint256 approvals;
        bool sent;
    }

    Transfer[] public transfers;

    mapping(address => mapping(uint256 => bool)) public approvals;

    constructor(address[] memory _approvers, uint256 _quorum) public {
        approvers = _approvers;
        quorum = _quorum;
    }

    function getApproves() external view returns (address[] memory) {
        return approvers;
    }

    // these functions are craeted because we want get functions to return the whole array.
    function getTransfers() external view returns (Transfer[] memory) {
        return transfers;
    }

    function createTransfer(uint256 amount, address payable to) external {
        transfers.push(Transfer(transfers.length, amount, to, 0, false));
    }

    function approveTransfer(uint256 id) external {
        require(transfers[id].sent == false, "Transfer has already been sent.");
        require(
            approvals[msg.sender][id] == false,
            "Cannot approve Transfer twice"
        );

        approvals[msg.sender][id] = true;
        transfers[id].approvals++;

        if (transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint256 amount = transfers[id].amount;
            to.transfer(amount);
        }
    }

    receive() external payable {}

    modifier onlyApprover() {
        bool allowed = false;
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed ==  true, 'Only  Approver allowed!');
        
    }
}
