// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract BlindAuction is IERC721Receiver, Ownable {
	uint256 batchValue;
	uint256 tokenId;
	uint256 public auctionRevealTime;
	uint256 public auctionEndTime;
	uint256 public highestBid;
	address public highestBidder;

	bool public auctionEnded;
	bool public revealTimeStarted;

	mapping(address => uint256) public bids;
	mapping(address => bytes32) public commitments;

	IERC721 public nftContract;

	// Constructor: Initialize auction parameters
	constructor(
		uint256 _batchValue,
		uint256 _durationMinutes,
		uint256 _auctionRevealTimeMinutes,
		uint256 _tokenId,
		address nftContractAddress
	) Ownable() {
		batchValue = _batchValue;
		tokenId = _tokenId;
		auctionEndTime = block.timestamp + _durationMinutes * 1 minutes;
		auctionRevealTime =
			auctionEndTime -
			_auctionRevealTimeMinutes *
			1 minutes;
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

	function stringToBytes32(
		string memory source
	) public pure returns (bytes32 result) {
		bytes memory tempEmptyStringTest = bytes(source);
		if (tempEmptyStringTest.length == 0) {
			return 0x0;
		}

		assembly {
			result := mload(add(source, 32))
		}
	}

	function createCommitment(
		address mother,
		bytes32 secret
	) public view returns (bytes32) {
		return keccak256(abi.encodePacked(msg.sender, mother, secret));
	}

	// Check if the NFT contract has approved this contract for transferring any token
	function checkNFTApproval() public view returns (bool) {
		require(address(nftContract) != address(0), "NFT contract not set");
		return nftContract.getApproved(tokenId) == address(this);
	}

	function sendOneEth(
		bytes32 commitment
	) external payable auctionRevealTime_NotEnded {
		require(checkNFTApproval(), "NFT not approved for transfer");
		require(msg.value == batchValue, "Must send exactly batch value");
		commitments[msg.sender] = commitment;
		emit Sent(msg.sender, msg.value);
		emit CommitmentCreated(msg.sender, commitment);
	}

	// End the auction and transfer the item to the highest bidder
	function startRevealTime() public {
		require(
			block.timestamp >= auctionRevealTime,
			"Auction Reveal Time not started yet"
		);
		require(block.timestamp <= auctionEndTime, "Auction ended");

		revealTimeStarted = true;
	}

	function checkForHighestBidder() public {
		require(bids[msg.sender] > highestBid, "your not the highest bidder"); //FIXME what should happend in case of to address to be equal
		highestBid = bids[msg.sender];
		highestBidder = msg.sender;
	}

	function revealSingleCommitment(
		address sender,
		bytes32 secret
	) external auctionNotEnded {
		require(block.timestamp >= auctionRevealTime, "Auction not yet ended");
		require(
			commitments[sender] ==
				keccak256(abi.encodePacked(sender, msg.sender, secret)),
			"Invalid commitment"
		);
		delete commitments[sender]; // Clear commitment after revealing FIXME check for double spending
		bids[msg.sender] += batchValue;
	}

	function revealMultipleCommitment(
		address[] calldata senders,
		bytes32 secret
	) external auctionNotEnded {
		require(block.timestamp >= auctionRevealTime, "Auction not yet ended");

		for (uint256 i = 0; i < senders.length; i++) {
			address sender = senders[i];

			require(
				commitments[sender] ==
					keccak256(abi.encodePacked(msg.sender, secret)),
				"Invalid commitment"
			);
			delete commitments[sender]; // Clear commitment after revealing FIXME check for double spending

			bids[msg.sender] += batchValue;
		}
		checkForHighestBidder();
	}

	// End the auction and transfer the item to the highest bidder
	function endAuction() public {
		require(block.timestamp >= auctionEndTime, "Auction not yet ended");
		require(!auctionEnded, "Auction already ended");

		auctionEnded = true;

		address previousHighestBidder = highestBidder;
		uint256 previousHighestBid = highestBid;

		highestBid = 0;
		highestBidder = address(0);

		// Transfer highest bid amount to the owner
		payable(owner()).transfer(previousHighestBid);

		// Transfer NFT to the highest bidder
		nftContract.transferFrom(owner(), previousHighestBidder, tokenId);
	}

	function claimAsLoser() public {
		require(auctionEnded, "Auction has not ended");
		if (msg.sender != highestBidder) {
			uint256 bidAmount = bids[msg.sender];
			bids[msg.sender] = 0;
			payable(msg.sender).transfer(bidAmount);
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
