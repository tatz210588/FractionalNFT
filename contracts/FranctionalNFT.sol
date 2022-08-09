// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import 'hardhat/console.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


/// @title Frantional NFT Contract
/// @author Tathagat Saha a.k.a Tatz
/// @notice A Contract to break the NFT721 ownership to multiple owners with redeemable ERC20 tokens
/// @dev All function calls are currently implemented without side effects and ReentracyGuard has been
/// put in places, to check reentrancy attacks. All methods have been tried to kept external to reduce
/// gas costs whereever possible.
contract FranctionalNFT is ERC20, Ownable, ERC20Permit, ERC721Holder, ReentrancyGuard {

    IERC721 public collection;
    uint256 public tokenId;
    bool public initialized = false;
    bool public forSale = false;
    uint256 public listingPrice;
    bool public canRedeemNow = false;
    uint256 public timeOfListing;

    constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") ReentrancyGuard(){}

    /// @notice Takes in the NFT from owner and returns equivalent tokens to the owner.
    /// @dev The owner can redistribute the token to shareholders.
    /// @param _collection The NFT address
    /// @param _tokenId The NFT Token ID
    /// @param _amount The amount of ERC20 tokens required
    function initialize(address _collection, uint256 _tokenId, uint256 _amount) external onlyOwner nonReentrant {
        require(!initialized ,'Already initialized');
        require(_amount > 0, "It is unfair to convert the NFT to zero tokens");
        collection = IERC721(_collection);
        collection.safeTransferFrom(msg.sender,address(this),_tokenId);
        tokenId = _tokenId;
        initialized = true;
        _mint(msg.sender, _amount);
    }

    /// @dev Should be used for putting the NFT for sale.   
    /// @param price The new price of NFT to be sold 
    function putForSale(uint256 price) external onlyOwner nonReentrant{
        require(forSale == false, 'The NFT is already on sale');
        listingPrice = price;
        forSale = true;
        timeOfListing = block.timestamp;
    }

    //// @notice Shows the current live price of the NFT. 
    /// @dev Dutch Auction Mechanism has been implemented with reduction of 1ETH every day.
    function checkCurrentPrice() public view returns(uint256){
        require(forSale,"Not for Sale");
        uint256 timeLapsed = block.timestamp - timeOfListing;
        uint256 noOfDaysPassed = timeLapsed / 1 days;
        if(listingPrice <= noOfDaysPassed){
            return 0;
        }else{
            return listingPrice - noOfDaysPassed;
        }
    }

    //// @notice Purchase the NFT if you think the price is right.
    //// @dev Once someone purchases, the canRedeem flag will be enaled
    function purchase() external payable nonReentrant{
        require(forSale && checkCurrentPrice() > 0,"Sorry, This is not for sale");
        require(msg.value >= checkCurrentPrice(),"Sorry, you need more money to buy this NFT");
        collection.transferFrom(address(this),msg.sender,tokenId);
        forSale = false;
        canRedeemNow = true;
    }

    //// @notice Shareholders may redeem their tokens. 
    /// @dev Once someone redeems, first burn mechanism operates, which checks if user has the tokens in the 
    /// first place. Once burn is completed, the amount of quivalent ETH will be transferred. This order of
    /// execution has been designed as a 2nd layer to prevent reentrancy
    function redeem(uint256 _amount) external nonReentrant{
        require(canRedeemNow,"Redemption not yet available");
        uint256 totalEther = address(this).balance;
        uint256 toRedeem = _amount * totalEther / totalSupply();
        _burn(msg.sender,_amount);  //order should be maintained to prevent reentrancy
        payable(msg.sender).transfer(toRedeem);
    } 
}
