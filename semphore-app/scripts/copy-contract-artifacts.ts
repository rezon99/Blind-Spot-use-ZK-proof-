import * as fs from "fs"

async function main() {
    const contractArtifactsPath = "apps/contracts/build/contracts/contracts/BlindAuction.sol"
    const webAppArtifactsPath = "apps/web-app/contract-artifacts"

    await fs.promises.copyFile(`${contractArtifactsPath}/BlindAuction.json`, `${webAppArtifactsPath}/BlindAuction.json`)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
