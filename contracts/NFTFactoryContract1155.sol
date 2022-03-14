// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTStorage1155.sol";
import "./Libraries/LibShare.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./TokenERC1155.sol";
import "./PNDC_ERC1155.sol";

contract NFTFactoryContract1155 is
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC1155HolderUpgradeable,
    NFTV1Storage1155
{
    using Counters for Counters.Counter;

    // function initialize() initializer public {
    //     OwnableUpgradeable.__Ownable_init();
    //     ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    //     ERC1155HolderUpgradeable.__ERC1155Holder_init();
    // }

    event TokenMetaReturn(LibMeta1155.TokenMeta data, uint256 id);


// Change in BuyNFT LibMeta Function

    function BuyNFT(uint256 _saleId, uint256 _amount) external payable nonReentrant {
        LibMeta1155.TokenMeta memory meta = _tokenMeta[_saleId];
    
        LibShare.Share[] memory royalties;

        if(meta.collectionAddress == PNDC1155Address) {
            royalties = PNDC_ERC1155(PNDC1155Address).getRoyalties(meta.tokenId);
        }

        else {
            royalties = TokenERC1155(meta.collectionAddress).getRoyalties(meta.tokenId);
        }

        require(meta.status == true,"2");
        require(msg.sender != address(0) && msg.sender != meta.currentOwner,"3");
        require(meta.bidSale == false,"4");
        require(meta.numberOfTokens >= _amount,"7");
        require(msg.value >= (meta.price * _amount),"8");

        LibMeta1155.transfer(_tokenMeta[_saleId], _amount);

        uint256 sum = msg.value;
        uint256 val = msg.value;
        uint256 fee = msg.value / 100;

        for(uint256 i = 0; i < royalties.length; i ++) {
            uint256 amount = (royalties[i].value * val ) / 10000;
            royalties[i].account.transfer(amount);
            sum = sum - amount;
        }

        payable(meta.currentOwner).transfer(sum - fee);
        payable(feeAddress).transfer(fee);
        ERC1155(meta.collectionAddress).safeTransferFrom(
            address(this), 
            msg.sender, 
            meta.tokenId, 
            _amount, 
            ""
            );

    }

    function sellNFT(address _collectionAddress, uint256 _tokenId, uint256 _price, uint256 _amount) 
    external 
    nonReentrant
    {   
        require(_collectionAddress != address(0), "9");
        uint256 bal = ERC1155(_collectionAddress).balanceOf(msg.sender, _tokenId);
        require(bal >= _amount,"7");

        _tokenIdTracker.increment();

        //needs approval on frontend
        ERC1155(_collectionAddress).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");

        LibMeta1155.TokenMeta memory meta = LibMeta1155.TokenMeta(
            _collectionAddress,
            _tokenId,
            _amount,
            _price,
            true,
            false,
            true,
            msg.sender
        );

         _tokenMeta[_tokenIdTracker.current()] = meta;

        emit TokenMetaReturn(meta, _tokenIdTracker.current());

    }

    function cancelSale(uint256 _saleId) external nonReentrant{

        require(msg.sender == _tokenMeta[_saleId].currentOwner,"1");
        require(_tokenMeta[_saleId].status == true,"2");

        _tokenMeta[_saleId].status = false;
        ERC1155(_tokenMeta[_saleId].collectionAddress).safeTransferFrom(
            address(this), 
            _tokenMeta[_saleId].currentOwner, 
            _tokenMeta[_saleId].tokenId, 
            _tokenMeta[_saleId].numberOfTokens, 
            ""
            );

    }

}