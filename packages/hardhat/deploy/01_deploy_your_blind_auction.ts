import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployAuctionGenerator: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  // const durationMinutes = 20;
  // const auctionRevealTimeMinutes = 15;
  // const tokenId = 1;
  // const nftContractAddress = MyToken.address;
  // await deploy("BlindAuction", {
  //   from: deployer,

  //   args: [durationMinutes, auctionRevealTimeMinutes, tokenId, nftContractAddress],
  //   log: true,
  //   // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
  //   // automatically mining the contract deployment transaction. There is no effect on live networks.
  //   autoMine: true,
  // });
  await deploy("AuctionGenerator", {
    from: deployer,
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  // const MyTokenDeployed = await hre.ethers.getContract<Contract>("MyToken", deployer);
  // const BlindAuctionDeployed = await hre.ethers.getContract<Contract>("BlindAuction", deployer);
};

export default deployAuctionGenerator;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags AuctionGenerator
deployAuctionGenerator.tags = ["AuctionGenerator"];
