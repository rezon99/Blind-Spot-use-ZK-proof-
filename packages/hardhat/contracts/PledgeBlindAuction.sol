// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// in this Action user send a collateral then in reveal time will open it's commitment and show how much he wanna pay. If he couldn't pay in the payment duration he will lose his money.
contract PledgeBlindAuction is IERC721Receiver, Ownable {
    uint256 tokenId;
    uint256 public auctionRevealTime;
    uint256 public auctionEndTime;
    uint256 public paymentDuration;
    uint256 public highestBid;
    address public highestBidder;

    bool public auctionEnded;
    bool public revealTimeStarted;
    bool public paymentDurationEnded;
    bool public winnerPaid;


    mapping(address => uint256) public bids;
    mapping(address => bytes32) public commitments;

    IERC721 public nftContract;

    // Constructor: Initialize auction parameters
    constructor(
        uint256 _durationMinutes,
        uint256 _auctionRevealTimeMinutes,
        uint256 _paymentDuration,
        uint256 _tokenId,
        address nftContractAddress
    ) Ownable(msg.sender) {
        tokenId = _tokenId;
        auctionEndTime = block.timestamp + _durationMinutes * 1 minutes;
        auctionRevealTime = auctionEndTime - _auctionRevealTimeMinutes * 1 minutes;
        paymentDuration = auctionEndTime + _paymentDuration * 1 minutes;
        nftContract = IERC721(nftContractAddress);
    }

    // FIXME how to approve the nft in 1 transaxtion with multy call?

    modifier auctionRevealTime_NotEnded() {
        require(!revealTimeStarted, "Reveal time has ended");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "Auction has ended");
        _;
    }

    event Sent(address indexed sender, uint amount);
    event CommitmentCreated(address indexed sender, bytes32 commitment);

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function createCommitment(uint256 _bidAmount, bytes32 secret) public view returns (bytes32) {
        return keccak256(abi.encodePacked(msg.sender, _bidAmount, secret));
    }

    // Check if the NFT contract has approved this contract for transferring any token
    function checkNFTApproval() public view returns (bool) {
        require(address(nftContract) != address(0), "NFT contract not set");
        return nftContract.getApproved(tokenId) == address(this);
    }

    function sendPledgeEth()public {}

    function send1Eth(bytes32 commitment) external payable auctionRevealTime_NotEnded {
        require(checkNFTApproval(), "NFT not approved for transfer");
        require(msg.value == 1 ether, "Must send exactly 1 ETH");
        commitments[msg.sender] = commitment;
        emit Sent(msg.sender, msg.value);
        emit CommitmentCreated(msg.sender, commitment);
    }

    // End the auction and transfer the item to the highest bidder
    function startRevealTime() public {
        require(block.timestamp >= auctionRevealTime, "Auction Reveal Time not started yet");
        require(block.timestamp <= auctionEndTime, "Auction ended");

        revealTimeStarted = true;
    }

    function checkForHighestBidder() public {
        require(bids[msg.sender] > highestBid, "your not the highest bidder"); //FIXME what should happend in case of to address to be equal
        highestBid = bids[msg.sender];
        highestBidder = msg.sender;    
    }

    function revealCommitment(uint256 _bidAmount, bytes32 secret) external auctionNotEnded {
        require(block.timestamp >= auctionRevealTime, "Auction not yet ended");
        require(commitments[msg.sender] == keccak256(abi.encodePacked(msg.sender, _bidAmount, secret)), "Invalid commitment");
        delete commitments[msg.sender]; // Clear commitment after revealing FIXME check for double spending
        bids[msg.sender] = _bidAmount;
        checkForHighestBidder();
    }

    // End the auction and transfer the item to the highest bidder
    function endAuction() public {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(!auctionEnded, "Auction already ended");

        auctionEnded = true;
    }

    function claimAsLoser() public {
        require(auctionEnded, "Auction has not ended");
        if (msg.sender != highestBidder) {
            uint256 bidAmount = bids[msg.sender];
            bids[msg.sender] = 0;
            payable(msg.sender).transfer(bidAmount * 1e18);
        }
    }

    function payPledgeAmount() public payable {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(block.timestamp <= paymentDuration, "Payment Duration ended");
        require(msg.sender == highestBidder, "Your not the highest bidder.");
        require(msg.value + 1 ether == highestBid, "You should pay the amount as you pledge minus 1 ETH.");

        // Transfer highest bid amount to the owner
        payable(owner()).transfer(highestBid * 1e18);

        // Transfer NFT to the highest bidder
        nftContract.transferFrom(owner(), highestBidder, tokenId);

        winnerPaid = true;
    }

    function endPaymentDuration() public {
        require(block.timestamp >= auctionEndTime, "Payment Duration not yet ended");
        require(!paymentDurationEnded, "Payment Duration already ended");
        paymentDurationEnded = true;
        if (!winnerPaid) {
            payable(owner()).transfer(1 ether);
        }
    }

    // End the auction and transfer the item to the highest bidder

    // ERC721 callback function
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
