# NFT Marketplace Smart Contract

This is a smart contract implementation for an NFT marketplace built on Ethereum using Solidity. The marketplace allows users to list, buy, and cancel listings of non-fungible tokens (NFTs). It also includes marketplace fees for each sale and functionality for fee withdrawals by the contract owner.

## Contract Overview

- **NFT Listing**: Users can list their NFTs for sale on the marketplace.
- **NFT Purchase**: Users can buy listed NFTs.
- **Listing Cancellation**: Sellers can cancel their NFT listings.
- **Marketplace Fee**: A 2% fee is charged on every sale.
- **Fee Withdrawal**: The contract owner can withdraw the accumulated marketplace fees.

## Smart Contract Features

- **NFT Listing**: Sellers can list their NFTs for sale by transferring them to the contract and specifying a price.
- **NFT Purchase**: Buyers can purchase NFTs by paying the specified price. The contract deducts the marketplace fee and transfers the remaining funds to the seller.
- **Listing Cancellation**: Sellers can cancel their listings and retrieve their NFTs if the listing is still active.
- **Marketplace Fee**: The marketplace charges a 2% fee for each transaction, which is deducted before the funds are sent to the seller.
- **Fee Withdrawal**: The contract owner has the ability to withdraw the accumulated fees from the marketplace.

## Contract Breakdown

### Data Structures

- **Listing Struct**: Stores the details of a listed NFT:
  - `nftContract`: The address of the NFT contract.
  - `tokenId`: The ID of the token being listed.
  - `seller`: The address of the seller.
  - `owner`: The address of the marketplace contract, which holds the NFT.
  - `price`: The sale price of the NFT.
  - `isActive`: A boolean indicating whether the listing is active.

### Events

- **NFTListed**: Emitted when a new NFT is listed for sale.
- **NFTSold**: Emitted when an NFT is sold.
- **ListingCanceled**: Emitted when a listing is canceled.

### Functions

1. **listNFT**:
   - Lists an NFT for sale by transferring the NFT to the marketplace contract.
   - Requires approval for the contract to transfer the NFT.
   - Emits the `NFTListed` event.

2. **buyNFT**:
   - Allows users to buy a listed NFT by paying the specified price.
   - The marketplace fee is deducted, and the remaining amount is transferred to the seller.
   - Transfers the NFT to the buyer.
   - Emits the `NFTSold` event.

3. **cancelListing**:
   - Allows sellers to cancel their listing and retrieve the NFT.
   - Emits the `ListingCanceled` event.

4. **withdrawFees**:
   - Allows the contract owner to withdraw the accumulated marketplace fees.

5. **receive**:
   - A fallback function to allow the contract to accept Ether.

## Fees

- The marketplace charges a 2% fee on each sale. The fee is automatically deducted from the sale price, and the remaining amount is sent to the seller.

## Security

- The contract inherits from `ReentrancyGuard` to protect against reentrancy attacks during transactions like buying and canceling listings.
- The contract ensures that the NFT is owned by the seller and that the marketplace contract has permission to transfer the NFT before a listing is created.

## How to Use the Contract

1. **Listing an NFT**:
   - The seller approves the marketplace contract to transfer their NFT.
   - The seller calls the `listNFT` function with the NFT contract address, token ID, and price.

2. **Buying an NFT**:
   - The buyer calls the `buyNFT` function with the listing ID and pays the specified price.
   - The marketplace transfers the NFT to the buyer and sends the seller proceeds after deducting the marketplace fee.

3. **Canceling a Listing**:
   - The seller calls the `cancelListing` function with the listing ID to cancel the listing and retrieve the NFT.

4. **Withdrawing Fees**:
   - The contract owner calls the `withdrawFees` function to withdraw the accumulated fees.

## Example

### List an NFT

```solidity
nftMarketplace.listNFT(nftContractAddress, tokenId, price);
```

### Buy an NFT

```solidity
nftMarketplace.buyNFT(listingId, { value: price });
```

### Cancel a Listing

```solidity
nftMarketplace.cancelListing(listingId);
```

### Withdraw Fees

```solidity
nftMarketplace.withdrawFees();
```

## Dependencies

- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts):
  - `IERC721`: Interface for ERC721 NFTs.
  - `ReentrancyGuard`: Protection against reentrancy attacks.
  - `Counters`: Utility for safely incrementing counters (used for listing IDs).

## License

This contract is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

---

This README provides an overview of the NFT marketplace smart contract, its functionality, and how to interact with it. The contract enables NFT listings, purchases, and cancellations, while also implementing a marketplace fee and providing an owner withdrawal mechanism.