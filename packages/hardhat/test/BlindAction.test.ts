import { BlindAuction, MyToken } from "../typechain-types";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";

describe("BlindAuction", () => {
    let owner: SignerWithAddress;
    let user1_mother_wallet: SignerWithAddress;
    let user2_mother_wallet: SignerWithAddress;
    let user1_wallet1: SignerWithAddress;
    let user1_wallet2: SignerWithAddress;
    let user1_wallet3: SignerWithAddress;
    let user2_wallet1: SignerWithAddress;
    let user2_wallet2: SignerWithAddress;
    let myToken: MyToken;
    let blindAuction: BlindAuction;
    let user1Secret: string;
    let user2Secret: string;

    beforeEach(async () => {
        [
            owner,
            user1_mother_wallet,
            user2_mother_wallet,
            user1_wallet1,
            user1_wallet2,
            user1_wallet3,
            user2_wallet1,
            user2_wallet2,
        ] = await ethers.getSigners();

        // Deploy MyToken contract
        const MyTokenFactory = await ethers.getContractFactory("MyToken");
        myToken = await MyTokenFactory.deploy(owner);
        await myToken.waitForDeployment();

        // Mint an NFT with tokenId=1
        await myToken.safeMint(1);

        // Deploy BlindAuction contract
        const BlindAuctionFactory = await ethers.getContractFactory("BlindAuction");
        blindAuction = await BlindAuctionFactory.deploy(10, 7, 1, await myToken.getAddress());
        await blindAuction.waitForDeployment();

        // Approve transfer to BlindAuction contract address
        await myToken.approve(blindAuction.getAddress(), 1);

        // User 1: Convert string to bytes32 and store it in user1Secret
        const user1SecretString = "User1Secret";
        user1Secret = ethers.encodeBytes32String(user1SecretString);

        // User 2: Convert string to bytes32 and store it in user2Secret
        const user2SecretString = "User2Secret";
        user2Secret = ethers.encodeBytes32String(user2SecretString);
    });

    it("should allow creating commitments for user1", async () => {
        // User1 Mock Addresses: Create commitments
        const user1mock1Commitment = await blindAuction.createCommitment(user1_mother_wallet.address, user1Secret, {
            from: user1_wallet1.address,
        });
        expect(user1mock1Commitment).to.be.a("string");

        const user1mock2Commitment = await blindAuction.createCommitment(user1_mother_wallet.address, user1Secret, {
            from: user1_wallet2.address,
        });
        expect(user1mock2Commitment).to.be.a("string");

        const user1mock3Commitment = await blindAuction.createCommitment(user1_mother_wallet.address, user1Secret, {
            from: user1_wallet3.address,
        });
        expect(user1mock3Commitment).to.be.a("string");
    });

    it("should allow creating commitments for user2", async function () {
        const user2mock1Commitment = await blindAuction.createCommitment(user2_mother_wallet.address, user2Secret, {
            from: user2_wallet1.address,
        });
        expect(user2mock1Commitment).to.be.a("string");

        const user2mock2Commitment = await blindAuction.createCommitment(user2_mother_wallet.address, user2Secret, {
            from: user2_wallet2.address,
        });
        expect(user2mock2Commitment).to.be.a("string");
    });
});
