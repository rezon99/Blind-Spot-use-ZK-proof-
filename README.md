# Blind-Spot-use-ZK-proof-

Auction uses ZK proof to hide the amount somma of bids and allows the winner to purchase NFT for his bid.


I want to create a create a blind auction dapp.
for maintaining the privacy user should send it's bid with up to 50 different address to contract address. for example user want to bid 10ETH so he need to pay 1ETH with 10 different address on 40 other spot would be 0.

for user will use it's semaphore Identity to prove that he paid 10 time.

so send 1 eth and in tx message sign it with your address and nullifier to be able to prove that you paid 1 ether

how to connect different addresses?

each time that some one pay 1 eth to contract address contract will add it to Semphore group.
user need to provide group id for auction.

reveal time
user should reveal its identities and provide an address to send the nft to him if he won or send it's ETH back if he lost 

so it would be 10 different identity that paid 1 eth. then at the end users reveal their identity by signing a transaction and show that how many ether their paid. anyone who paid more would be the winner.



## break down


Creating a blind auction DApp with privacy considerations is an interesting challenge! Let's break down the steps to achieve this:

1. **Smart Contract Design**:
    - You'll need a smart contract that handles the auction logic, including bid submission, verification, and winner determination.
    - Define a struct to store each user's bids, including the amount and the associated addresses.
    - Use a mapping to associate group IDs with user bids.

2. **Bid Submission**:
    - Users submit their bids by sending 1 ETH from up to 50 different addresses.
    - Each bid includes the user's address and a unique nullifier (a random value).
    - The contract verifies that the total amount sent is 1 ETH.

3. **Semaphore Identity**:
    - Users prove their bids using their semaphore identity.
    - When submitting a bid, users sign a message containing their address and nullifier.
    - The contract verifies the signature against the user's address.

4. **Grouping Bids**:
    - Each time someone pays 1 ETH to the contract address, the contract adds it to a semaphore group.
    - The group ID is associated with the auction.

5. **Revealing Bids**:
    - At the end of the auction, users reveal their identity by signing a transaction.
    - They provide the number of ETH they paid (e.g., 10 times 1 ETH).
    - The contract verifies the revealed amount against the stored bids.

6. **Determining the Winner**:
    - The user who paid the most ETH wins the auction.
    - The contract transfers the auctioned item to the winner.

7. **Privacy Considerations**:
    - Users' bids are private during the auction.
    - The semaphore identity ensures that only valid bids are considered.
    - The nullifier prevents double-spending.

8. **Connecting Different Addresses**:
    - To connect different addresses, you can use an interface between two smart contracts.
    - Deploy a separate contract (e.g., `XYZ`) that contains the relevant methods.
    - In your auction contract (e.g., `ABC`), store the address of the deployed `XYZ` contract.
    - Call the methods of `XYZ` from `ABC` using the stored address.
