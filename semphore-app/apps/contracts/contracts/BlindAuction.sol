// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "semphore-app/node_modules/@semaphore-protocol/contracts/interfaces/ISemaphore.sol";

contract BlindAuction {
    address public owner; // Auction owner
    uint256 public auctionEndTime; // Auction end time
    uint256 public highestBid; // Highest bid amount
    address public highestBidder; // Highest bidder
    bool public ended; // Auction ended flag

    ISemaphore public semaphore;
    uint256 public groupId;

    // Struct to store user bids
    struct Bid {
        uint256 amount;
        bytes32 nullifier;
        bool revealed;
    }

    // Mapping from user address to their bid
    mapping(address => Bid) public bids;

    // Constructor: Initialize auction parameters
    constructor(uint256 _durationMinutes, address semaphoreAddress, uint256 _groupId) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + _durationMinutes * 1 minutes;
        semaphore = ISemaphore(semaphoreAddress);
        groupId = _groupId;
        semaphore.createGroup(groupId, 20, address(this));
    }

    // Modifier: Auction not ended
    modifier auctionNotEnded() {
        require(!ended, "Auction has ended");
        _;
    }

    // Place a blind bid
    function placeBid(bytes32 _nullifier) public payable auctionNotEnded {
        require(msg.value == 1 ether, "Bid amount must be 1 ETH");
        require(bids[msg.sender].amount == 0, "Already placed a bid");

        bids[msg.sender] = Bid(msg.value, _nullifier, false);
    }

    // Reveal the bid
    function revealBid(
        uint256 _amount,
        bytes32 _nullifier
    ) public auctionNotEnded {
        require(bids[msg.sender].amount > 0, "No bid found");
        require(!bids[msg.sender].revealed, "Bid already revealed");
        require(
            keccak256(abi.encodePacked(_amount, _nullifier)) ==
                bids[msg.sender].nullifier,
            "Invalid nullifier"
        );

        bids[msg.sender].revealed = true;

        if (_amount > highestBid) {
            highestBid = _amount;
            highestBidder = msg.sender;
        }
    }

    // End the auction and transfer the item to the highest bidder
    function endAuction() public {
        require(msg.sender == owner, "Only owner can end the auction");
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!ended, "Auction already ended");

        ended = true;
        payable(owner).transfer(highestBid);
    }

    // Function to join the semaphore group
    function joinSemaphoreGroup(uint256 identityCommitment) external {
        semaphore.addMember(groupId, identityCommitment);
    }

    // Function to send feedback to the semaphore contract
    function sendFeedback(
        uint256 feedback,
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external {
        semaphore.verifyProof(groupId, merkleTreeRoot, feedback, nullifierHash, groupId, proof);
    }
}
