//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract simpleAuction{
    //---state variable---

    //合约拥有者
    address public owner;

    //受益人
    address payable beneficiary;

    //拍卖时间
    uint256 public biddingTime;

    //出价截止时间
    uint256 public biddingDue;

    //最高价格
    uint256 public highestBidPrice;

    //最高出价人
    address public highestBidder;

    bool public ended; 

    //---event---

    //1.有人出更高价格
    event highestBidIncreased (address bidder, uint amount);

    //2.竞拍时间截止
    event endAuction (address winner, uint amount);

    //3.拍卖取消
    event cancellAuction ();

    //---modifier---

    //1.竞拍进行中
    modifier duringBidding() {
        require(block.timestamp < biddingDue, "Auction is overdue");
        _;
    }

    //2.竞拍结束或结束后
    modifier biddingOverdue() {
        require(block.timestamp >= biddingDue, "Bidding haven't ended yet");
        _;
    }

    //3.合约拥有者权限
    modifier ownerAbility() {
        require(msg.sender == owner, "This function is only available for contract owner");
        _;
    }

    //---function---

    // 1.构造函数：在部署合约时，需要设定受益人地址和拍卖的截止时间。
    constructor(uint _biddingTime, address payable _beneficiary){
        owner = msg.sender;
        beneficiary = _beneficiary;
        biddingDue = block.timestamp + _biddingTime;
    }

    //2.bid（）：仅能在出价阶段被调用进行出价
    function bid() external payable duringBidding{
        require(msg.value > highestBidPrice, "You have to bid a value higher than current highestBid");

        if ( highestBidder != address(0)) {
            payable (highestBidder).transfer(highestBidPrice);
        }

        highestBidder = msg.sender;
        highestBidPrice = msg.value;

        emit highestBidIncreased(msg.sender, msg.value);
    }

    //3.auctionEnd()：仅能在结束之前被调用来结束拍卖。拍卖只能被结束一次
    function auctionEnd() external biddingOverdue{
        require(!ended, "auctionEnd has already been called");

        // 标记拍卖为已结束
        ended = true;

        // 将最高出价金额转给受益人
        beneficiary.transfer(highestBidPrice);

        // 触发事件
        emit endAuction(highestBidder, highestBidPrice);
    }
    
    //4.cancelAuction（）：仅能被合约拥有者；在任何时候可调用。
    function cancelAuction() external ownerAbility{
        require(!ended, "The auction has already ended.");
        ended = true;
        if (highestBidder != address(0)) {
            payable(highestBidder).transfer(highestBidPrice);
        }

        emit cancellAuction();
    }
}