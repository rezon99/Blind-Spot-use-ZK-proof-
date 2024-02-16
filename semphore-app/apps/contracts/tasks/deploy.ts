import { task, types } from "hardhat/config"

task("deploy", "Deploy a BlindAuction contract")
    .addOptionalParam("semaphore", "Semaphore contract address", undefined, types.string)
    .addOptionalParam("group", "Group id", "42", types.string)
    .addOptionalParam("logs", "Print the logs", true, types.boolean)
    .setAction(async ({ logs, semaphore: semaphoreAddress, group: groupId }, { ethers, run }) => {
        if (!semaphoreAddress) {
            const { semaphore } = await run("deploy:semaphore", {
                logs
            })

            semaphoreAddress = semaphore.address
        }

        if (!groupId) {
            groupId = process.env.GROUP_ID
        }

        const BlindAuctionFactory = await ethers.getContractFactory("BlindAuction")

        const blindAuctionContract = await BlindAuctionFactory.deploy(10, semaphoreAddress, groupId)

        await blindAuctionContract.deployed()

        if (logs) {
            console.info(`BlindAuction contract has been deployed to: ${blindAuctionContract.address}`)
        }

        return blindAuctionContract
    })
