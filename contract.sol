// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _listingIds;

    // Listing structure to store NFT sale details
    struct Listing {
        address nftContract;
        uint256 tokenId;
        address seller;
        address owner;
        uint256 price;
        bool isActive;
    }

    // Mapping to store all listings
    mapping(uint256 => Listing) public listings;

    // Events to log marketplace activities
    event NFTListed(
        uint256 listingId,
        address nftContract,
        uint256 tokenId,
        address seller,
        uint256 price
    );

    event NFTSold(
        uint256 listingId,
        address nftContract,
        uint256 tokenId,
        address seller,
        address buyer,
        uint256 price
    );

    event ListingCanceled(uint256 listingId);

    // Fees
    uint256 public constant MARKETPLACE_FEE_PERCENTAGE = 2; // 2% marketplace fee

    // List an NFT for sale
    function listNFT(
        address _nftContract, 
        uint256 _tokenId, 
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");

        // Transfer NFT to marketplace contract
        IERC721 nft = IERC721(_nftContract);
        require(nft.ownerOf(_tokenId) == msg.sender, "You must own the NFT");
        require(nft.isApprovedForAll(msg.sender, address(this)) || 
                nft.getApproved(_tokenId) == address(this), 
                "Marketplace must be approved to transfer NFT");

        // Increment listing ID and create new listing
        _listingIds.increment();
        uint256 newListingId = _listingIds.current();

        listings[newListingId] = Listing({
            nftContract: _nftContract,
            tokenId: _tokenId,
            seller: msg.sender,
            owner: address(this),
            price: _price,
            isActive: true
        });

        // Transfer NFT to marketplace
        nft.transferFrom(msg.sender, address(this), _tokenId);

        // Emit listing event
        emit NFTListed(newListingId, _nftContract, _tokenId, msg.sender, _price);
    }

    // Buy a listed NFT
    function buyNFT(uint256 _listingId) external payable nonReentrant {
        Listing storage listing = listings[_listingId];
        
        require(listing.isActive, "Listing is not active");
        require(msg.value >= listing.price, "Insufficient payment");

        // Calculate marketplace fee
        uint256 marketplaceFee = (listing.price * MARKETPLACE_FEE_PERCENTAGE) / 100;
        uint256 sellerProceeds = listing.price - marketplaceFee;

        // Transfer payment to seller
        payable(listing.seller).transfer(sellerProceeds);

        // Transfer NFT to buyer
        IERC721 nft = IERC721(listing.nftContract);
        nft.transferFrom(address(this), msg.sender, listing.tokenId);

        // Mark listing as inactive
        listing.isActive = false;
        listing.owner = msg.sender;

        // Emit sale event
        emit NFTSold(
            _listingId, 
            listing.nftContract, 
            listing.tokenId, 
            listing.seller, 
            msg.sender, 
            listing.price
        );

        // Refund any excess payment
        if (msg.value > listing.price) {
            payable(msg.sender).transfer(msg.value - listing.price);
        }
    }

    // Cancel a listing
    function cancelListing(uint256 _listingId) external nonReentrant {
        Listing storage listing = listings[_listingId];
        
        require(listing.seller == msg.sender, "Only seller can cancel listing");
        require(listing.isActive, "Listing is not active");

        // Transfer NFT back to seller
        IERC721 nft = IERC721(listing.nftContract);
        nft.transferFrom(address(this), msg.sender, listing.tokenId);

        // Mark listing as inactive
        listing.isActive = false;

        // Emit cancellation event
        emit ListingCanceled(_listingId);
    }

    // Withdraw marketplace fees (only by contract owner)
    function withdrawFees() external {
        // Note: Implementation of owner access control would be added here
        payable(msg.sender).transfer(address(this).balance);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}