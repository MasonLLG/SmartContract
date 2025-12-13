// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 1. 导入 OpenZeppelin 的 ERC20 标准合约和 Ownable 权限控制合约
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GeminiCoin
 * @dev 一个基础的 ERC20 代币，继承了 OpenZeppelin 的标准实现。
 * - 拥有者 (deployer) 可以在开始时铸造初始供应量。
 * - 拥有者也可以后续增发代币。
 */
contract GeminiCoin is ERC20, Ownable {
    
    /**
     * @dev 构造函数，在部署时被调用。
     * @param initialOwner 合约的初始拥有者地址。
     * @param initialSupply 初始铸造的代币数量（不包含小数位）。
     */
    constructor(address initialOwner, uint256 initialSupply) 
        ERC20("GeminiCoin", "GMC") // 设置代币名称和符号
        Ownable(initialOwner) // 设置合约拥有者
    {
        // 铸造初始供应量给拥有者
        _mint(initialOwner, initialSupply * (10 ** decimals()));
    }

    /**
     * @notice 允许合约拥有者增发代币。
     * @param to 接收代币的地址。
     * @param amount 要铸造的代币数量（不包含小数位）。
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount * (10 ** decimals()));
    }
}