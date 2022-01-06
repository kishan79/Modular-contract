// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Auction/Bid1155.sol";
import "./Libraries/LibERC1155.sol";
import "./Libraries/LibCollection1155.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract TokenFactory1155 is UUPSUpgradeable, NFTBid1155 {

    using Counters for Counters.Counter;

    event ERC1155Deployed(address indexed _from, address _tokenAddress);

    function initialize(address _address) initializer public {
        PNDC1155Address = _address;
        NFTFactoryContract1155.initialize();
        __UUPSUpgradeable_init();
    }

    function deployERC1155(
        string memory _uri, 
        string memory description, 
        LibShare.Share[] memory royalties) 
        external 
        nonReentrant{

        collectionIdTracker.increment();

        address collectionAddress = LibERC1155.deployERC1155(_uri, royalties);

        LibCollection1155.CollectionMeta memory meta = LibCollection1155.CollectionMeta(
            _uri,
            collectionAddress,
            msg.sender,
            description
        );

        collections[collectionIdTracker.current()] = meta;
        

        ownerToCollections[msg.sender].push(collectionIdTracker.current());
        collectionToOwner[collectionAddress] = msg.sender;

        emit ERC1155Deployed(msg.sender, collectionAddress);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

}