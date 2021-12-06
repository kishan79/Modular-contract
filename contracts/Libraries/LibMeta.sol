// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibMeta {

    struct TokenMeta {
        uint256 id;
        uint256 price;
        string name;
        string uri;
        bool directSale;
        bool bidSale;
        bool status;
        address mintedBy;
        address currentOwner;
        address previousOwner;
        uint256 numberOfTransfers;
    }

    function transfer(TokenMeta storage token ) public{
        token.previousOwner = token.currentOwner;
        token.currentOwner = msg.sender;
        token.numberOfTransfers += 1;
        token.price = msg.value;
    } 
}