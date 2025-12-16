// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract nftStaking is Ownable{
    //   - 需要能记录 NFT 合约地址和奖励代币合约地址。
    IERC20 public immutable rewardToken;
    IERC721 public immutable nft;
    //   - 需要一个常量 REWARD_RATE_PER_SECOND 来定义奖励速率（建议设为每小时 10 个代币，并换算成每秒的速率）。
    uint256 public constant REWARD_RATE_PER_SECOND = 2777777777777778 ;
    //   - 需要一个 struct Stake 来存储质押信息（owner 和 timestamp）。
    struct Stake {
        address owner;
        uint256 timestamp;
    }
    //   - 需要一个 mapping(uint256 => Stake) 来通过 tokenId 查找质押信息。
    mapping (uint256 => Stake) stakingInfo;
    
    // - constructor: 构造函数，需要传入并保存 NFT 和奖励代币的合约地址。
    constructor(address _nftAddress, address _rewardTokenAddress, address initialOwner) Ownable(initialOwner) {
        nft = IERC721(_nftAddress);
        rewardToken = IERC20(_rewardTokenAddress);
    }

    function stake(uint256 _tokenId) external {
        require(stakingInfo[_tokenId].owner == address(0),"This token has already staked");
        nft.transferFrom(msg.sender,address(this),_tokenId);
        stakingInfo[_tokenId] = Stake({
            owner: msg.sender,
            timestamp: block.timestamp
        });
    }

    
}