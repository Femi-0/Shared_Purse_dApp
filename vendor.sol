// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./shared_purse.sol";

// Learn more about the ERC20 implementation 
// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.7/contracts/access/Ownable.sol";

contract Vendor is Ownable {
  constructor(address tokenAddress) {
    yourToken = SharedPurse(tokenAddress);
  }  

  // Our Token Contract
  SharedPurse yourToken;

  // token price for ETH
  uint256 public tokensPerEth;

  // Event that logs Rate change
  event newRate(uint256 rate );

  // Event that log buy operation
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  /**
  * @notice Allow users to buy token for ETH
  */
  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "Send ETH to buy some tokens");

    uint256 amountToBuy = msg.value * tokensPerEth;

    // check if the Vendor Contract has enough amount of tokens for the transaction
    uint256 vendorBalance = yourToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract does not have enough tokens in its balance");

    // Transfer token to the msg.sender
    (bool sent) = yourToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer token to user");

    // emit the event
    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }

  /**
  * @notice Allow the owner of the contract to withdraw ETH
  */
  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner has not balance to withdraw");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
  }
  /**
  * @notice the owner to withdraw money before change owner
  */
  function getMyBalance() public view returns (uint) {
        return address(this).balance;
    }   
  function transferOwnership(address newOwner) public virtual override onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        require(address(this).balance == 0, "The Balance should be zero before transfer owner");
        _transferOwnership(newOwner);
    }
  /**
  * @notice Allow owner to set Token rate
  */
  function setRate (uint256 new_rate) public onlyOwner{
      tokensPerEth = new_rate;
      emit newRate (tokensPerEth);
  }
}