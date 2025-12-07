//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken {
    // 1. 通证的名字
    string public tokenName;

    // 2. 通证的简称
    string public tokenSymbol;

    // 3. 通证的发行数量
    uint public totalSupply;

    // 4. owner的地址
    address public owner;

    // 5. balance address => uint256
    mapping(address => uint256) public balances;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        owner = msg.sender;
    }

    // mint: 获取通证
    function mint() {}
    // transfer： transfer通证
    // balanceOf: 查看某一个地址的通证数量
}