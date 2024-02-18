# Blind Auction DApp

## Overview

This project implements a Blind Auction DApp where users can participate in an auction while maintaining their privacy by submitting bids with multiple addresses.

## Features

- **Multiple Addresses**: Users can create and use multiple addresses, each containing a specific amount of Ether for bidding.
- **Auction Configuration**: The auction generator contract allows setting parameters such as batch value, auction duration, reveal time, Token ID, and NFT contract address.
- **Commitment Phase**: Users pay 1 Ether with each address to create commitments during the commitment phase.
- **Reveal Phase**: Users reveal their commitments to show their bids during the reveal phase.
- **End of Auction**: The auction concludes after the reveal phase. The highest bidder receives the NFT, and losers can refund their bids.

## User Journey

- **Slide 5**: Users create multiple addresses with specific Ether amounts. User 1 creates 1 main address and 3 mock addresses, each with 1 Ether. User 2 creates 2 addresses with 1 Ether each. User 1 wins if an auction occurs after the revealing phase.
- **Slide 6**: Constructor parameters include batch value, auction duration, reveal time, Token ID, and NFT contract address.
- **Slide 7**: The contract begins with NFT approval. Users pay 1 Ether with each address for commitments. Call startRevealTime to begin the revealing phase.
- **Slide 8**: Users reveal commitments during the reveal duration. Call endAuction to finalize the auction. The highest bidder receives the NFT, and losers can refund their bids.

## Getting Started

To run the Blind Auction DApp:

1. Clone the repository.
2. Install dependencies with `npm install`.
3. Deploy the contracts to your preferred Ethereum network.
4. Interact with the DApp using a compatible Ethereum wallet or development environment.

## Contributing

Contributions to this project are welcome! Please check the [CONTRIBUTING.md](CONTRIBUTING.md) file for more information.

## Deployed contract address

[Auction Generator contract on Scroll seplia ](https://sepolia.scrollscan.com/tx/0xf918fa2b6ba16ec948eb668026b212390669350de03aa0231f8c13b0f94769b3)

## License

This project is licensed under the [MIT License](LICENSE).
