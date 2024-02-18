// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC721, Ownable {
	constructor(address initialOwner) ERC721("MyToken", "MTK") Ownable() {}

	function safeMint(uint256 tokenId) public onlyOwner {
		_safeMint(msg.sender, tokenId);
	}
}
