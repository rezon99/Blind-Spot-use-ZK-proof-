// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./BlindAuction.sol";

contract AuctionGenerator {
	struct Auction {
		address auction;
		address nftContract;
		uint256 tokenId;
	}

	mapping(address => mapping(uint256 => Auction)) public auctions; // Updated mapping

	event AuctionCreated(address indexed auctionContract, uint256 tokenId);

	function createAuction(
		uint256 batchValue,
		uint256 durationMinutes,
		uint256 revealTimeMinutes,
		uint256 tokenId,
		address nftContractAddress
	) external returns (address) {
		BlindAuction auctionContract = new BlindAuction(
			msg.sender,
			batchValue,
			durationMinutes,
			revealTimeMinutes,
			tokenId,
			nftContractAddress
		);
		// Store the auction details in the mapping
		auctions[msg.sender][tokenId] = Auction(
			address(auctionContract),
			nftContractAddress,
			tokenId
		);
		emit AuctionCreated(address(auctionContract), tokenId);
		return address(auctionContract);
	}

	function getAuctionDetails(
		address user,
		uint256 _tokenId
	)
		external
		view
		returns (address auctionContract, address nftContract, uint256 tokenId)
	{
		Auction memory auction = auctions[user][_tokenId];
		return (auction.auction, auction.nftContract, auction.tokenId);
	}
}
