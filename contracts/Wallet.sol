pragma solidity >=0.6.0;
pragma experimental ABIEncoderV2;

contract Wallet {
    address[] approvers; // for the array of addresses that are going to apprive ethereum address
    uint256 public quorum; // the limit to spend ethereum when approved.

    struct Transfer {
        //  DS for all transfers
        uint256 id; // a unique Id
        uint256 amount; // amount to be sent
        address payable to; // the address which u want to send
        uint256 approvals; // No. of approvals sent.
        bool sent; // state for the transaction which is sent or not.
    }

    Transfer[] public transfers; // array for different Transfers

    mapping(address => mapping(uint256 => bool)) public approvals; //  mappings of address to ID to transfer booleans.

    constructor(address[] memory _approvers, uint256 _quorum) public {
        approvers = _approvers;
        quorum = _quorum;
    }

    function getApproves() external view returns (address[] memory) {
        return approvers; // returns array of approvers.
    }

    // these functions are craeted because we want get functions to return the whole array.
    function getTransfers() external view returns (Transfer[] memory) {
        return transfers; // returns all array of tansfers
    }

    function createTransfer(uint256 amount, address payable to) external {
        transfers.push(Transfer(transfers.length, amount, to, 0, false)); //
    } // push to array of tansfers.

    function approveTransfer(uint256 id) external {
        require(transfers[id].sent == false, "Transfer has already been sent.");
        require(
            approvals[msg.sender][id] == false,
            "Cannot approve Transfer twice"
        );
        // This function is for approving and send amount to address which is approved.

        approvals[msg.sender][id] = true;
        transfers[id].approvals++;

        if (transfers[id].approvals >= quorum) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint256 amount = transfers[id].amount;
            to.transfer(amount);
        }
    }

    receive() external payable {} // receiving Ethers

    modifier onlyApprover() {
        bool allowed = false;
        for (uint256 i = 0; i < approvers.length; i++) {
            if (approvers[i] == msg.sender) {
                allowed = true;
            }
        }

        require(allowed == true, "Only  Approver allowed!");

        _;
    }
}
