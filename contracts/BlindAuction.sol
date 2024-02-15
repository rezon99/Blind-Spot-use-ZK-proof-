// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.0;

interface IVerifier {
    function verifyProof(
        bytes memory _proof,
        uint256[] memory _input
    ) external returns (bool);
}

contract BlindAuction {
    address payable public beneficiary;
    IVerifier public verifier; // The verifier contract for ZK proofs
    uint public biddingEnd;
    uint public revealEnd;
    bool public ended;
    uint public highestBid;
    address public highestBidder;

    // This represents the total eth contributed by each bidder without revealing individual amounts
    mapping(address => uint) public contributions;
    // This will represent commitments which are a hash of the amount + secret
    mapping(address => bytes32) public commitments;
    // Nullifiers are used to prevent double spending
    mapping(bytes32 => bool) public nullifiers;

    event BidMade(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(uint _biddingTime, uint _revealTime, IVerifier _verifier) {
        beneficiary = payable(msg.sender);
        verifier = _verifier;
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    modifier onlyBefore(uint _time) {
        require(
            block.timestamp < _time,
            "Action can only be performed before a certain time."
        );
        _;
    }

    modifier onlyAfter(uint _time) {
        require(
            block.timestamp >= _time,
            "Action can only be performed after a certain time."
        );
        _;
    }

    function bid(bytes32 _commitment) public payable onlyBefore(biddingEnd) {
        // Each bid should be exactly 1 ether
        require(msg.value == 1 ether, "Must send exactly 1 Ether");
        commitments[msg.sender] = _commitment;
        contributions[msg.sender] += msg.value;
        emit BidMade(msg.sender, msg.value);
    }

    function reveal(
        uint _bid,
        bytes32 _nullifier,
        bytes32 _secret,
        bytes memory _proof
    ) public onlyAfter(biddingEnd) onlyBefore(revealEnd) {
        bytes32 commitment = keccak256(abi.encodePacked(_bid, _secret));
        // Verifies the commitment matches
        require(
            commitments[msg.sender] == commitment,
            "Bid does not match commitment"
        );
        // Verifies the proof of the provided bid amount
        require(verifier.verifyProof(_proof, [_bid]), "Invalid proof");
        // Check if the nullifier has been used
        require(!nullifiers[_nullifier], "Nullifier has been used");

        nullifiers[_nullifier] = true;

        if (_bid > highestBid) {
            highestBid = _bid;
            highestBidder = msg.sender;
        }
    }

    function auctionEnd() public onlyAfter(revealEnd) {
        require(!ended, "Auction end has already been called");
        ended = true;
        beneficiary.transfer(highestBid);
        contributions[highestBidder] -= highestBid;
        emit AuctionEnded(highestBidder, highestBid);
    }

    // Function to withdraw your contributions except the winning bid
    function withdraw() public {
        uint amount = contributions[msg.sender];
        if (amount > 0) {
            contributions[msg.sender] = 0;
            if (!payable(msg.sender).send(amount)) {
                contributions[msg.sender] = amount;
            }
        }
    }
}
