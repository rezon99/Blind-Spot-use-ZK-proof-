// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BlindAuction.sol";

contract AuctionGenerator is Ownable {
	struct Auction {
		address nftContract;
		uint256 tokenId;
	}

	mapping (address => Auction) autcions;

	event AuctionCreated(address indexed auctionContract, uint256 tokenId);

	function createAuction(
		uint256 batchValue,
		uint256 durationMinutes,
		uint256 revealTimeMinutes,
		uint256 tokenId,
		address nftContractAddress
	) external onlyOwner returns (address) {
		BlindAuction auctionContract = new BlindAuction(
			batchValue,
			durationMinutes,
			revealTimeMinutes,
			tokenId,
			nftContractAddress
		);
		emit AuctionCreated(address(auctionContract), tokenId);
		return address(auctionContract);
	}
}
