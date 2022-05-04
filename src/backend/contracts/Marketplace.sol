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

    struct Item {
        uint256 itemId;
        IERC721 nft;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    event Offered(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );

    event Bought(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer
    );

    mapping(uint256 => Item) public items;

    constructor(uint256 _feePercent) {
        feeAccount = payable(msg.sender);
        feePercent = _feePercent;
    }

    /// @dev 创建商品
    function makeItem(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero.");
        itemCount++;
        _nft.transferFrom(msg.sender, address(this), _tokenId);

        items[itemCount] = Item(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );

        emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
    }

    /// @dev 购买商品
    function purchaseItem(uint256 _itemId) external payable nonReentrant {
        uint256 _totalPrice = getTotalPrice(_itemId);
        Item storage item = items[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "item doesn't exist.");
        require(
            msg.value >= _totalPrice,
            "not enough ether to cover item price and market fee."
        );
        require(!item.sold, "item already sold.");

        item.seller.transfer(item.price);
        feeAccount.transfer(_totalPrice - item.price);
        item.sold = true;
        item.nft.transferFrom(address(this), msg.sender, item.tokenId);
        emit Bought(
            _itemId,
            address(item.nft),
            item.tokenId,
            item.price,
            item.seller,
            msg.sender
        );
    }

    /// @dev 获取商品总价
    function getTotalPrice(uint256 _itemId) public view returns (uint256) {
        return (items[_itemId].price * (100 + feePercent)) / 100;
    }
}
