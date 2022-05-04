// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// ERC721URIStorage 具有基于存储的令牌 URI 管理的 ERC721 令牌。
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
/// 防重入攻击
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Marketplace is ReentrancyGuard {
    // 收取费用账号
    address payable public immutable feeAccount;
    // 费用百分比
    uint256 public immutable feePercent;
    uint256 public itemCount;

    constructor(uint256 _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }
}
