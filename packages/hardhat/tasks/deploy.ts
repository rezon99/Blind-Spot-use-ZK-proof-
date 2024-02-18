import { task, types } from "hardhat/config";

task("deploy", "Deploy a BlindAuction contract")
  .addOptionalParam("durationMinutes", "Duration Minutes", 5, types.int)
  .addOptionalParam("auctionRevealTimeMinutes", "Auction Reveal Time Minutes", 1, types.int)
  .addOptionalParam("tokenId", "NFT token Id", 1, types.int)
  .addOptionalParam("nftContractAddress", "NFT Contract Address", "0x", types.string)
  .addOptionalParam("logs", "Print the logs", true, types.boolean)
  .setAction(async ({ logs, durationMinutes, auctionRevealTimeMinutes, tokenId, nftContractAddress }, { ethers }) => {
    const BlindAuctionFactory = await ethers.getContractFactory("BlindAuction");

    const blindAuctionContract = await BlindAuctionFactory.deploy(
      durationMinutes,
      auctionRevealTimeMinutes,
      tokenId,
      nftContractAddress,
    );

    await blindAuctionContract.deployed();

    if (logs) {
      console.info(`BlindAuction contract has been deployed to: ${blindAuctionContract.address}`);
    }

    return blindAuctionContract;
  });
