import { Group } from "@semaphore-protocol/group"
import { Identity } from "@semaphore-protocol/identity"
import { generateProof } from "@semaphore-protocol/proof"
import { expect } from "chai"
import { formatBytes32String } from "ethers/lib/utils"
import { ethers, run } from "hardhat"
// @ts-ignore: typechain folder will be generated after contracts compilation
import { BlindAuction } from "../build/typechain"
import { config } from "../package.json"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"

describe("BlindAuction", async () => {
    let blindAuctionContract: BlindAuction
    let semaphoreContract: string

    const groupId = "42"
    const group = new Group(groupId)

    const user1_identities: Identity[] = []
    const user2_identities: Identity[] = []
    let user1_mother_wallet: SignerWithAddress
    let user2_mother_wallet: SignerWithAddress
    let user1_walet1: SignerWithAddress
    let user1_walet2: SignerWithAddress
    let user1_walet3: SignerWithAddress
    let user2_walet1: SignerWithAddress
    let user2_walet2: SignerWithAddress
    before(async () => {
        ;[
            user1_mother_wallet,
            user2_mother_wallet,
            user1_walet1,
            user1_walet2,
            user1_walet3,
            user2_walet1,
            user2_walet2
        ] = await ethers.getSigners()
        const { semaphore } = await run("deploy:semaphore", {
            logs: false
        })
        blindAuctionContract = await run("deploy", {
            logs: false,
            durationMinutes: 10, // Specify auction duration here
            semaphore: semaphore.address,
            group: groupId
        })
        semaphoreContract = semaphore
        // console.log(blindAuctionContract)
    })

    describe("Identity Creation", () => {
        before(async () => {
            // Create identities for user1
            // this will sign the message(mother wallet address) with user1_walet1 private key then it will create an identity with it.
            const user1_identity1 = new Identity(
                await user1_walet1.signMessage(
                    ethers.utils.arrayify(ethers.utils.hashMessage(user1_mother_wallet.address))
                )
            )
            const user1_identity2 = new Identity(
                await user1_walet2.signMessage(
                    ethers.utils.arrayify(ethers.utils.hashMessage(user1_mother_wallet.address))
                )
            )
            const user1_identity3 = new Identity(
                await user1_walet3.signMessage(
                    ethers.utils.arrayify(ethers.utils.hashMessage(user1_mother_wallet.address))
                )
            )

            // Create identities for user2
            const user2_identity1 = new Identity(
                await user2_walet1.signMessage(
                    ethers.utils.arrayify(ethers.utils.hashMessage(user2_mother_wallet.address))
                )
            )
            const user2_identity2 = new Identity(
                await user2_walet2.signMessage(
                    ethers.utils.arrayify(ethers.utils.hashMessage(user2_mother_wallet.address))
                )
            )

            // Push identities to arrays
            user1_identities.push(user1_identity1, user1_identity2, user1_identity3)
            user2_identities.push(user2_identity1, user2_identity2)
        })
        describe("# joinGroup", () => {
            it("Should allow users to join the group if paid 1 ether", async () => {
                // for user 1
                for await (const [i, user] of user1_identities.entries()) {
                    // Ensure that the user sends 1 ether while calling joinSemaphoreGroup
                    const contractBalanceBefore = await ethers.provider.getBalance(blindAuctionContract.address)
                    const transaction = await blindAuctionContract.joinSemaphoreGroup(user.commitment, {
                        value: ethers.utils.parseEther("1.0")
                    })
                    group.addMember(user.commitment)

                    await expect(transaction)
                        .to.emit(semaphoreContract, "MemberAdded")
                        .withArgs(groupId, i, user.commitment, group.root)

                    const contractBalanceAfter = await ethers.provider.getBalance(blindAuctionContract.address)
                    expect(contractBalanceAfter.sub(contractBalanceBefore)).to.equal(
                        ethers.utils.parseEther("1.0"),
                        "contract balance didn't updated currectly."
                    )
                }
            })
        })

        // FIXME use linkIdentityToMotherAddr
        // FIXME use getMotherAddressOfIdentity

        // Trapdoor: private, known only by user    in this case 1ETH user address
        // Nullifier: private, known only by user   in this case user mother address that he want to get NFT with it
        // Commitment: public

        // now each address have one identity
        // user claim that he is the owner of the identity so in the time of creating the identity user use it's mother address as the nullifier
        // user cannot claim that he have moltiple identity because for identity creation you need to pay 1 ether so it he can't double spend.

        // semaphore.verifyProof(groupId, merkleTreeRoot, profeOf1ETH, nullifierHash, groupId, proof)

        // With each transaction, the user signs a message with their Ethereum address and a unique nullifier to avoid double-spending, while maintaining privacy.

        // Implement test for users joining the semaphore group
        // it("user shouldn't be able to double-spend", async () => {
        //     // Implement test for users joining the semaphore group
        // })
        // it("user should be able to prove that he is the owner of that 1ETH", async () => {
        //     // Implement test for users joining the semaphore group
        // })
        // it("no one should be able to know who owns the 1ETH before revealing it", async () => {
        //     // Implement test for users joining the semaphore group
        // })

        // it("should allow users to join the semaphore group", async () => {
        //     // Implement test for users joining the semaphore group
        // })

        // it("should allow users to prove how much they bid with prooving they own the identities", async () => {
        //     // Implement test for users placing blind bids
        // })

        // it("should verify the total amount sent for each bid is 1 ETH", async () => {
        //     const wasmFilePath = `${config.paths.build["snark-artifacts"]}/semaphore.wasm`
        //     const zkeyFilePath = `${config.paths.build["snark-artifacts"]}/semaphore.zkey`
        //     // Implement test to verify the total amount sent for each bid
        // })

        // it("if user didn't reveal in the auction_Deadline user after proof their identities he should be able to withdorw it's fond", async () => {
        //     // Implement test for users revealing their bids
        // })

        // it("should allow users to reveal their bids", async () => {
        //     // Implement test for users revealing their bids
        // })

        // it("should verify the correctness of bid reveal", async () => {
        //     // Implement test to verify the correctness of bid reveal
        // })

        // it("should correctly determine the winner of the auction", async () => {
        //     // Implement test to determine the winner of the auction
        // })
    })
})
