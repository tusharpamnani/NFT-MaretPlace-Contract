// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Internal imports for NFT OpenZipline
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    // Counter for tracking token IDs
    Counters.Counter private _tokenIds;
    
    // Counter for tracking the number of items sold
    Counters.Counter private _itemsSold;

    // The owner of this contract will be the address that deploys it, and is capable of receiving funds
    address payable owner;

    // This variable represents the listing price in Ether, which is charged by the owner of the marketplace
    // NFT sellers are required to pay this amount to list their NFTs on the marketplace.
    uint256 listingPrice = 0.0025 ether;

    // Mapping to associate token IDs with MarketItem (structure defined below) data
    mapping(uint256 => MarketItem) private idMarketItem;

    // Define a struct named 'MarketItem' to represent NFT marketplace items
    struct MarketItem {
        uint256 tokenId;
        address payable seller; // Address of NFT seller
        address payable owner;  // Address of the current owner of NFT
        uint256 price; // Price of the NFT
        bool sold;  // Is the NFT sold or not
    }

    // Event to log the creation of a new 'MarketItem'
    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // Modifier to restrict access to only the owner of the contract
    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can access this feature");
        _;
    }

    constructor() ERC721("NFT Bazaar", "COFFEE") {
        // Constructor for initializing the contract
        // It inherits from ERC721 and sets the NFT token name to "NFT Bazaar" and symbol to "COFFEE"
        owner = payable(msg.sender); // Assign the deploying address as the owner and make it payable
    }

    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner {
        listingPrice = _listingPrice;
    }

    function getListingPrice() public view returns(uint256) {
        return listingPrice;
    }

    // CREATE NFT TOKEN

    function createToken(string memory tokenURI, uint256 price) public payable returns (uint256) {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    // Function to create an NFT token with a given token URI and price.
    // It increments the token ID counter, mints the token, sets its URI, and creates a market item for it.

    // CREATING MARKET ITEMS (NFT)

    function createMarketItem(uint256 tokenId, uint256 price) private {
        require(price > 0, "Price cannot be less than 0!!");
        require(msg.value == listingPrice, "Price should at least be equal to listing price");

        // Create a MarketItem and associate it with the provided tokenId
        idMarketItem[tokenId] = MarketItem (
            tokenId,    // Set the tokenId for the MarketItem
            payable(msg.sender),    // The seller's address (the caller of the function)
            payable(address(this)), // The contract's address becomes the owner initially
            price,  // Set the price of the NFT
            false   // Initially mark the NFT as not sold
        );

        // Transfer the NFT from the seller to this contract
        _transfer(
            msg.sender,     // The sender (seller)
            address(this),  // This contract becomes the new owner
            tokenId // The tokenId of the NFT
        );

        // Emit an event to log the creation of a new 'MarketItem'
        emit idMarketItemCreated(
            tokenId, 
            msg.sender, 
            address(this), // Contract's address (as the initial owner)
            price, 
            false   // Initially, the NFT is not sold
        );
    }

    // FUNCTION FOR RESALE OF NFT/TOKENS

    function reSellToken(uint256 tokenId, uint256 price) public payable {
        // Ensure that only the item owner can access this function
        require(idMarketItem[tokenId].owner == msg.sender, "Only the item owner can access this function");

        // Verify that the value sent with the transaction matches the listing price
        require(msg.value == listingPrice, "Price must be equal to the listing price");

        // Update the NFT's market item information
        idMarketItem[tokenId].sold = false; // Mark the NFT as unsold
        idMarketItem[tokenId].price = price; // Set the new price for resale
        idMarketItem[tokenId].seller = payable(msg.sender); // Update the seller's address
        idMarketItem[tokenId].owner = payable(address(this)); // Set the contract as the owner

        // Decrement the items sold counter to reflect the NFT is back in the marketplace
        _itemsSold.decrement();

        // Transfer the NFT from the current owner back to this contract for resale
        _transfer(msg.sender, address(this), tokenId);
    }

    // Function to allow Sales

    function createMarketSale(uint256 tokenId) public payable {
        // Get the price of the token from the market item mapping
        uint256 price = idMarketItem[tokenId].price;

        // Check if the sent value (msg.value) matches the price of the token
        require(msg.value == price, "Please enter the asked amount to complete the purchase");

        // Update the owner of the token to the buyer (msg.sender)
        idMarketItem[tokenId].owner = payable(msg.sender);

        // Mark the token as sold
        idMarketItem[tokenId].sold = true;

        // Set the previous owner to address(0), indicating it's no longer owned
        idMarketItem[tokenId].owner = payable(address(0));

        // Increment the counter for sold items
        _itemsSold.increment();

        // Transfer the ownership of the token from this contract to the buyer (msg.sender)
        _transfer(address(this), msg.sender, tokenId);

        // Transfer the listing price to the contract owner
        payable(owner).transfer(listingPrice);

        // Transfer the payment from the buyer to the seller of the token
        payable(idMarketItem[tokenId].seller).transfer(msg.value);
    }

    // GETTING UNSOLD NFT DATA

    function fetchMarketItem() public view returns (MarketItem[] memory) {
        // Get the total number of NFTs and calculate the count of unsold items
        uint256 itemCount = _tokenIds.current();
        uint256 unSoldItemCount = _tokenIds.current() - _itemsSold.current();

        uint256 currentIndex = 0;

        // Create a dynamic array to hold the unsold market items
        MarketItem[] memory items = new MarketItem[](unSoldItemCount);

        // Iterate through all NFTs to find unsold ones and store them in the 'items' array
        for (uint256 i = 0; i < itemCount; i++) {
            if (idMarketItem[i + 1].owner == address(this)) {
                uint256 currentId = i + 1;

                // Get the current market item from the 'idMarketItem' mapping
                MarketItem storage currentItem = idMarketItem[currentId];

                // Store the current market item in the 'items' array
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        // Return an array of unsold market items
        return items;
    }

    // FETCH THE NFT

    function fetchMyNFT() public view returns (MarketItem[] memory) {
        uint256 totalCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        // Count the number of NFTs owned by the caller
        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        // Create a dynamic array to store NFTs owned by the caller
        MarketItem[] memory items = new MarketItem[](itemCount);

        // Iterate through all NFTs to find and store NFTs owned by the caller
        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].owner == msg.sender) {
                uint256 currentId = i + 1;

                // Get the current market item from the 'idMarketItem' mapping
                MarketItem storage currentItem = idMarketItem[currentId];

                // Store the current market item in the 'items' array
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        // Return an array of NFTs owned by the caller
        return items;
    }

    // SINGLE USER ITEMS

    function fetchItemListed() public view returns (MarketItem[] memory) {
        uint256 totalCount = _tokenIds.current();
        uint256 itemCount = 0;
        uint256 currentIndex = 0;

        // Count the number of NFTs listed for sale by the caller
        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        // Create a dynamic array to store NFTs listed for sale by the caller
        MarketItem[] memory items = new MarketItem[](itemCount);

        // Iterate through all NFTs to find and store NFTs listed for sale by the caller
        for (uint256 i = 0; i < totalCount; i++) {
            if (idMarketItem[i + 1].seller == msg.sender) {
                uint256 currentId = i + 1;

                // Get the current market item from the 'idMarketItem' mapping
                MarketItem storage currentItem = idMarketItem[currentId];

                // Store the current market item in the 'items' array
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        // Return an array of NFTs listed for sale by the caller
        return items;
    }
}
 