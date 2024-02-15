import { Group } from "@semaphore-protocol/group"
import { Identity } from "@semaphore-protocol/identity"
import { generateProof } from "@semaphore-protocol/proof"
import { expect } from "chai"
import { formatBytes32String } from "ethers/lib/utils"
import { ethers, run } from "hardhat"
// @ts-ignore: typechain folder will be generated after contracts compilation
import { BlindAuction } from "../build/typechain"
import { config } from "../package.json"

describe("BlindAuction", async () => {
    let blindAuctionContract: BlindAuction
    let semaphoreContract: string

    const groupId = "100"
    const group = new Group(groupId)

    const [
        user1_mother_addresse,
        user2_mother_addresses,
        user1_addresses1,
        user1_addresses2,
        user1_addresses3,
        user2_addresses1,
        user2_addresses2
    ] = await ethers.getSigners()

    const user1_identities: Identity[] = []
    const user2_identities: Identity[] = []

    before(async () => {
        const { semaphore } = await run("deploy:semaphore", {
            logs: false
        })
        blindAuctionContract = await run("deploy:blindAuction", {
            logs: false,
            durationMinutes: 10, // Specify auction duration here
            semaphore: semaphore.address,
            group: groupId
        })
        semaphoreContract = semaphore
    })

    it("should create group", async () => {
        // Implement test for users joining the semaphore group
    })
    it("should creates 3 Identity based on user 1 addresses and 2 identity for user2", async () => {
        user1_identities.push(new Identity())
        user2_identities.push(new Identity())
        // Implement test for users joining the semaphore group
        // used later to prove how many times they’ve placed a bid without revealing their actual Ethereum addresses.
        it("FIXME user generates a Semaphore identity for each address", async () => {
            // Implement test for users joining the semaphore group
        })
        // FIXME use linkIdentityToMotherAddr
        // FIXME use getMotherAddressOfIdentity
        
        describe("# joinGroup", () => {
            it("Should allow users to join the group if paid 1 ether", async () => {
                for await (const [i, user] of user1_identities.entries()) {
                    const transaction = blindAuctionContract.joinSemaphoreGroup(user.commitment)

                    group.addMember(user.commitment)

                    await expect(transaction)
                        .to.emit(semaphoreContract, "MemberAdded")
                        .withArgs(groupId, i, user.commitment, group.root)
                }
            })
        })
        // Trapdoor: private, known only by user    in this case 1ETH user address
        // Nullifier: private, known only by user   in this case user mother address that he want to get NFT with it
        // Commitment: public

        // now each address have one identity
        // user claim that he is the owner of the identity so in the time of creating the identity user use it's mother address as the nullifier
        // user cannot claim that he have moltiple identity because for identity creation you need to pay 1 ether so it he can't double spend.

        // semaphore.verifyProof(groupId, merkleTreeRoot, profeOf1ETH, nullifierHash, groupId, proof)

        // With each transaction, the user signs a message with their Ethereum address and a unique nullifier to avoid double-spending, while maintaining privacy.
        it("The user send 1ETH to contract address", async () => {
            // Implement test for users joining the semaphore group
            it("user shouldn't be able to double-spend", async () => {
                // Implement test for users joining the semaphore group
            })
            it("user should be able to prove that he is the owner of that 1ETH", async () => {
                // Implement test for users joining the semaphore group
            })
            it("no one should be able to know who owns the 1ETH before revealing it", async () => {
                // Implement test for users joining the semaphore group
            })
        })
    })

    describe("# joinGroup", () => {
        it("Should allow users to join the group", async () => {
            for await (const [i, user] of identities.entries()) {
                const transaction = blindAuctionContract.joinSemaphoreGroup(user.commitment)

                group.addMember(user.commitment)

                await expect(transaction)
                    .to.emit(semaphoreContract, "MemberAdded")
                    .withArgs(groupId, i, user.commitment, group.root)
            }
        })
    })

    it("should allow users to join the semaphore group", async () => {
        // Implement test for users joining the semaphore group
    })

    it("should allow users to prove how much they bid with prooving they own the identities", async () => {
        // Implement test for users placing blind bids
    })

    it("should verify the total amount sent for each bid is 1 ETH", async () => {
        const wasmFilePath = `${config.paths.build["snark-artifacts"]}/semaphore.wasm`
        const zkeyFilePath = `${config.paths.build["snark-artifacts"]}/semaphore.zkey`
        // Implement test to verify the total amount sent for each bid
    })

    it("if user didn't reveal in the auction_Deadline user after proof their identities he should be able to withdorw it's fond", async () => {
        // Implement test for users revealing their bids
    })

    it("should allow users to reveal their bids", async () => {
        // Implement test for users revealing their bids
    })

    it("should verify the correctness of bid reveal", async () => {
        // Implement test to verify the correctness of bid reveal
    })

    it("should correctly determine the winner of the auction", async () => {
        // Implement test to determine the winner of the auction
    })
})
