# NFT Marketplace Smart Contract

This Solidity smart contract represents a decentralized NFT (Non-Fungible Token) marketplace where users can create, buy, and sell NFTs. The marketplace is built on the Ethereum blockchain and follows the ERC-721 standard for NFTs.

## Features

1. **Creating NFTs:**
   - Users can create new NFTs by calling the `createToken` function, providing a token URI and a price.
   - Each NFT is uniquely identified by a token ID.

2. **Listing NFTs for Sale:**
   - When a user creates an NFT, it is automatically listed for sale in the marketplace.
   - The NFT owner pays a listing price in Ether to list their NFT.

3. **Reselling NFTs:**
   - NFT owners can choose to resell their tokens by calling the `reSellToken` function, updating the price for resale.
   - The NFT is transferred back to the marketplace for resale.

4. **Buying NFTs:**
   - Users can purchase NFTs listed in the marketplace by calling the `createMarketSale` function and sending the specified amount of Ether.
   - The seller receives the payment, and the NFT ownership is transferred to the buyer.

5. **Marketplace Information:**
   - Users can fetch information about unsold NFTs using the `fetchMarketItem` function.
   - Users can retrieve a list of NFTs they own with the `fetchMyNFT` function.
   - The `fetchItemListed` function provides a list of NFTs listed for sale by the caller.

6. **Owner Control:**
   - The marketplace owner can update the listing price using the `updateListingPrice` function.

## Getting Started

1. **Contract Deployment:**
   - Deploy the smart contract to the Ethereum blockchain.
   - The contract is initialized with the name "NFT Bazaar" and symbol "COFFEE."

2. **Creating NFTs:**
   - Users can create NFTs by calling the `createToken` function with a token URI and a price.

3. **Buying and Selling:**
   - NFTs are automatically listed for sale upon creation.
   - Users can buy NFTs by calling `createMarketSale` and sending the specified amount of Ether.
   - NFT owners can resell their tokens using the `reSellToken` function.

4. **Marketplace Information:**
   - Use the various `fetch` functions to retrieve information about NFTs in the marketplace.

5. **Owner Operations:**
   - The owner of the marketplace can update the listing price using `updateListingPrice`.

## Functions

- `createToken(string memory tokenURI, uint256 price)`: Create a new NFT and list it for sale.
- `reSellToken(uint256 tokenId, uint256 price)`: Resell an NFT listed in the marketplace.
- `createMarketSale(uint256 tokenId)`: Execute the purchase of a listed NFT.
- `fetchMarketItem()`: Retrieve information about unsold NFTs.
- `fetchMyNFT()`: Get a list of NFTs owned by the caller.
- `fetchItemListed()`: Get a list of NFTs listed for sale by the caller.
- `updateListingPrice(uint256 _listingPrice)`: Update the listing price by the marketplace owner.
- `getListingPrice()`: Retrieve the current listing price.

## Ownership and Payments

- The contract owner, initially set to the deployer's address, can update the listing price.
- Sellers pay a listing price to list their NFTs.
- Buyers pay the listed price, which is transferred to the seller.
- The contract owner receives the listing price for each successful sale.

## Disclaimer

This smart contract is provided as-is and may be subject to security risks. Users should exercise caution and perform thorough testing before deploying to a live network.

### License

This smart contract is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
