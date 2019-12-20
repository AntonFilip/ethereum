pragma solidity ^0.4.24;

import "./Auction.sol";

contract EnglishAuction is Auction {

    uint internal highestBid;
    uint internal initialPrice;
    uint internal biddingPeriod;
    uint internal lastBidTimestamp;
    uint internal minimumPriceIncrement;

    address internal highestBidder;

    constructor(
        address _sellerAddress,
        address _judgeAddress,
        Timer _timer,
        uint _initialPrice,
        uint _biddingPeriod,
        uint _minimumPriceIncrement
    ) public Auction(_sellerAddress, _judgeAddress, _timer) {
        initialPrice = _initialPrice;
        biddingPeriod = _biddingPeriod;
        minimumPriceIncrement = _minimumPriceIncrement;
        lastBidTimestamp = time();
    }

    function bid() public payable {
        bool isFinished = checkAndFinishAuctionIfAuctionIsOver();
        require(!isFinished, "Auction is over, no more bids!");
        require(msg.value >= initialPrice, "Initial price not met!");
        require((msg.value - highestBid) >= minimumPriceIncrement, "Minimum price increment rule not satisfied!");
        highestBidderAddress.transfer(highestBid);
        highestBidderAddress = msg.sender;
        highestBid = msg.value;
        lastBidTimestamp = time();
    }

    function getHighestBidder() public returns (address) {
        checkAndFinishAuctionIfAuctionIsOver();
        if (outcome == Outcome.NOT_FINISHED || outcome == Outcome.NOT_SUCCESSFUL) {
            return address(0);
        }
        return highestBidderAddress;
    }

    function checkAndFinishAuctionIfAuctionIsOver() internal returns (bool) {
        uint timeNow = time();
        if ((timeNow - lastBidTimestamp) >= biddingPeriod) {
            if (highestBid >= initialPrice) {
                finishAuction(Outcome.SUCCESSFUL, highestBidderAddress);
            } else {
                finishAuction(Outcome.NOT_SUCCESSFUL, address(0));
            }
            return true;
        }
        return false;
    }
}
