// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevsToken is ERC20, Ownable {
    //price of one token
    uint256 public constant tokenPrice = 0.001 ether;
    // tokens per nft
    uint256 public constant tokensPerNFT = 10 * 10**18;
    //max Supoply
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    // instance for nft contract.
    ICryptoDevs CryptoDevsNFT;
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("CryptoDevToken", "CD"){
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether Sent is incorrect");
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max availible total supply"
        );
        // call the internal function from Openzeppelin's ERC20 contract
          _mint(msg.sender, amountWithDecimals);
    }

    function claim() public {
              address sender = msg.sender;
              uint256 balance = CryptoDevsNFT.balanceOf(msg.sender);
              require(balance>0, "You don't own any CryptoDevs NFT's");
              uint256 amount = 0; // track of unclaimed tokenId's

              for(uint256 i = 0; i< balance; i++){
                  uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
                  if(!tokenIdsClaimed[tokenId]){
                      amount += 1;
                      tokenIdsClaimed[tokenId] = true;
                  }
              }
              require(amount > 0, "You have already claimed the tokens");
              // call the internal function from Openzeppelin's ERC20 contract
          // Mint (amount * 10) tokens for each NFT
              _mint(msg.sender, amount * tokensPerNFT);
          }

          receive() external payable {}
          fallback() external payable{}

}