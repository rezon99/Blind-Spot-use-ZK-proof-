// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@semaphore-protocol/contracts/interfaces/ISemaphore.sol";

contract BlindAuction {
    uint256 public totalSupply;
    mapping(address => uint256) private balanceOf;
    address public owner; // Auction owner
    uint256 public auctionEndTime; // Auction end time
    uint256 public highestBid; // Highest bid amount
    address public highestBidder; // Highest bidder

    bool public auction_proof_time; // Auction auction_proof_time flag
    bool public auction_ended; // Auction ended flag

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
    modifier auction_proof_time_NotEnded() {
        require(!auction_proof_time, "auction_proof_time has ended");
        _;
    }
    // Modifier: Auction not ended
    modifier auctionNotEnded() {
        require(!auction_ended, "Auction has ended");
        _;
    }

    // Place a blind bid
    function placeBid(bytes32 _nullifier) public payable auctionNotEnded {
        require(msg.value == 1 ether, "Bid amount must be 1 ETH");
        require(bids[msg.sender].amount == 0, "Already placed a bid");

        bids[msg.sender] = Bid(msg.value, _nullifier, false);
    }

    // Reveal the bid
    function revealBid(uint256 _amount, bytes32 _nullifier) public auctionNotEnded {
        require(bids[msg.sender].amount > 0, "No bid found");
        require(!bids[msg.sender].revealed, "Bid already revealed");
        require(keccak256(abi.encodePacked(_amount, _nullifier)) == bids[msg.sender].nullifier, "Invalid nullifier");

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
        require(!auction_ended, "Auction already ended");

        auction_ended = true;
        payable(owner).transfer(highestBid);
    }

    // Function to join the semaphore group
    function joinSemaphoreGroup(uint256 identityCommitment) external payable auction_proof_time_NotEnded {
        require(msg.value == 1 ether, "You need to pay 1 ether for creating 1 Identity commitment.");
        semaphore.addMember(groupId, identityCommitment);
    }

    // Function to send feedback to the semaphore contract

    // I have a dapp that create 10 address and it will create an identity for each of them with Nullifier of a mother_address.
    // user pays 1ETH for each it's identity creation. now how I can say which identiti blongs to the mother_address?
    mapping(bytes32 => address) public motherAddressOfIdentity;

    // Function to link an identity to the mother address
    function linkIdentityToMotherAddr(bytes32 identity, address motherAddress) public {
        require(msg.sender == motherAddress, "Only the mother address can make this link");
        motherAddressOfIdentity[identity] = motherAddress;
    }

    // Function to retrieve the mother address linked to an identity
    function getMotherAddressOfIdentity(bytes32 identity) public view returns (address) {
        return motherAddressOfIdentity[identity];
    }

    function reveal_Stacked_ETH_Based_On_Identity_Count(
        string[] memory commitments,
        uint256 signal,
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external view {
        // Loop through the commitments to retrieve the mother addresses
        address[] memory motherAddresses = new address[](commitments.length);
        for (uint i = 0; i < commitments.length; i++) {
            bytes32 identity = keccak256(abi.encodePacked(commitments[i]));
            motherAddresses[i] = getMotherAddressOfIdentity(identity);
        }

        // Use the retrieved mother addresses for further processing, such as verifying proofs
        // ...
    }

    function reveal_Stacked_ETH_Based_On_Identity_Count_with_signal(
        string[] memory commitments,
        uint256 signal,
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external {
        // Loop through the commitments to retrieve the mother addresses
        address[] memory motherAddresses = new address[](commitments.length);
        for (uint i = 0; i < commitments.length; i++) {
            bytes32 identity = keccak256(abi.encodePacked(commitments[i]));
            motherAddresses[i] = getMotherAddressOfIdentity(identity);
        }

        // Now that you have the mother addresses, you can use them for further processing, such as verifying proofs
        for (uint j = 0; j < motherAddresses.length; j++) {
            // Perform proof verification using Semaphore protocol or any other relevant verification process
            bool isProofValid = verifyProofWithMotherAddress(
                motherAddresses[j],
                signal,
                merkleTreeRoot,
                nullifierHash,
                proof
            );

            // Use the result of proof verification for further actions
            if (isProofValid) {
                // Take some action if the proof is valid
                // ...
            } else {
                // Handle the case where the proof is not valid
                // ...
            }
        }
    }

    // Function to verify proof using the Semaphore protocol with the mother address
    function verifyProofWithMotherAddress(
        address motherAddress,
        uint256 signal,
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) internal returns (bool) {
        // Implement the logic to verify the proof using the provided parameters and the mother address
        // Example: Call the Semaphore contract to verify the given proof with the specified mother address
        // ...
        // Return true if the proof is valid; otherwise, return false
        // Example: return semaphore.verifyProof(motherAddress, signal, merkleTreeRoot, nullifierHash, proof);
    }

    // bug: if sb knows the mother address he can validate the identities because all of the addresses will be in contract. maby we can private it!
}
