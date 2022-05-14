// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.7.0 <0.9.0;

contract Auction{
    // created my variables
    address payable public beneficiary;
    uint public auctionEndTime;

    // variables for current highest bidder
    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public pendingReturns;

    bool ended = false;

    // whenever we get a higher bid, it replaces the previous highest bid amount
    event HighestBidIncrease(address bidder, uint amount);
    // Once the auction has ended, it will record the highest bidder and the amount they bid 
    event AuctionEnded(address winnder, uint amount);

    constructor(uint _biddingTime, address payable _beneficiary){
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    // This is a function to put bids in the auction
    // first if statement is if the auction is finished, it will not allow anymore bids
    // second if statement is if you place a bid that is lower than the current bid, then it will give you an 
    // third if statement is if the bid is higher than 0, we are going to assign the highest bid to the highest bidder
    function bid() public payable{
        if (block.timestamp > auctionEndTime){
            revert("The Auction is no longer available");
        }
        
        if (msg.value <= highestBid){
            revert("There is a higher or equal bid");
        }

        if (highestBid != 0){
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncrease(msg.sender, msg.value);
    }

    // Allows users to withdraw if their bid if it gets out bid by another user
    function withdraw() public returns(bool){
        uint amount = pendingReturns[msg.sender];
        if(amount > 0){
            pendingReturns[msg.sender] = 0;

            if(!payable(msg.sender).send(amount)){
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    // Sends the highest bid to the beneficiary 
    function auctionEnd() public {
        if (block.timestamp < auctionEndTime){
            revert ("The auction has not ended yet");
        }

        if (ended){
            revert("The function auctionEnded has already been called");
        }

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }
}

