//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//1. 创建一个收款函数
//2. 记录投资人并且查看
//3. 在锁定期内，达到目标值，生产商可以提款
//4. 在锁定期内，没有达到目标值，投资人可以退款

contract FundMe {
    mapping (address => uint256) public fundersToAmount;

    uint256 constant MINIMUM_VALUE = 100 * 10 ** 18;

    AggregatorV3Interface internal dataFeed;

    uint256 constant TARGET = 1000 * 10 ** 18;

    address public owner;

    uint256 deploymentTimestamp;
    uint256 lockTime;

    constructor() {
        // sepolia testnet
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
    }

    function fund() external payable {
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH");
        fundersToAmount[msg.sender] = msg.value;
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundId */
            ,
            int256 answer,
            /*uint256 startedAt*/
            ,
            /*uint256 updatedAt*/
            ,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd (uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return ethAmount * ethPrice / ( 10**8 );
    }

    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "this function can only be called by owner");
        owner = newOwner;
    }

    function getFund() external {
        require(convertEthToUsd(address(this).balance) >= TARGET, "Target is not reached");
        require(msg.sender == owner, "this function can only be called by owner");
        //transfer
        //payable(msg.sender).transfer(address(this).balance);
        //send
        //call
        bool success;
        (success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "transfer tx failed");
        fundersToAmount[msg.sender] = 0;
    }

    function refund() external {
        require(convertEthToUsd(address(this).balance) < TARGET, "Target is reached");
        require(fundersToAmount[msg.sender] != 0, "there is no fund for you");
        bool success;
        (success,) = payable(msg.sender).call{value: fundersToAmount[msg.sender]}("");
        require(success, "transfer tx failed");
        fundersToAmount[msg.sender] = 0;
    }
}