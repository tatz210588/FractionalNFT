# Fractional NFT Contract

The actual contract solidity can be found under the "contracts" folder.

Following are the business flow of this smart contract. For the sake of simplicity the original NFT holder is named as "KING", the fractional owners are combinedly named as "citizens", and a random wallet is named as "JACK".

### The contract has been deployed and verified on Rinkeby Network and the same can be verified at:

### https://rinkeby.etherscan.io/address/0xFe8ccBa4F2d85Bd27c6587b75441129a16EE6963#code

User Story:

1. King owns an NFT and he wants to share the ownership with citizens.
2. King deploys the FranctionalNFT contract and obtains a contract address.
3. King then runs the "SetApproveForAll" method of his NFT and makes this newly obtained address(in Step2) as his operator.
4. King runs the "initialize" function and passes his NFT contract address, NFT token address, and the number of shares of ERC20 tokens he wants to generate.
5. Once he runs this function, the NFT is now transferred from King to this contract and the king now owns all the ERC20 token, he generated in Step 4.
6. Notable fact is that this function can be run only once and that too by the KING himself, thus no one including the King hinself can re-mint more such ERC20 tokens.
7. The King now distributes the ERC20 to all citizens, so that the citizens can now become a part owner of the NFT.
8. The King now decides that he wants to sell the NFT and earn some money. Ofcourse, since the citizens are also part-owners, they will undoubtedly get the profit share if they redeem their coins.
9. The KING runs the "putForSale" method and passes a new price of the NFT and the contract implements the Dutch Auction Mechanism(The Auction begins at a high price and then price keeps dropping unless someone seals the auction or unless it is cancelled).
10. For our scenario, the contract will reduce 1ETHER price of the NFT after the passage of every 24 hours.
11. Whenever someone wants to purchase the NFT, he may run "checkCurrentPrice" method to see the latest price, as per Dutch Auction Mechanism.
12. When the price, after subsequent dropping reaches 0, the NFT will not be available for sale anymore and the KING will have the freedom to relist the NFT once again at a different or same price.
13. Now one day, while the NFT is on sale, Jack comes and purchases the NFT, using the "purchase" function.
14. Contract, once it receives the required ETHER, it transfers the NFT to Jack.
15. The citizens can now use the "redeem" method to get their share of Ether from the sale, based on the number of tokens they wish to redeem.
