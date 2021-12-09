const NFTBid = artifacts.require("NFTBid");

contract("NFTBid", (accounts) => {
 describe("Testing Contracts Error Cases", function(){ 
  it("Testing smart contract function mintNFT() that mints NFT : Test 2", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.mintNFT(
      "https://example.com/token_uri",
      "NFT Name",
      5000000
    );

    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");
  });

  it("Testing smart contract function SellNFT_byBid() that enable NFT for sell", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.SellNFT_byBid(1, 5500000);

    assert.equal(result.receipt.status, true, "Failed to enable NFT for sell");
  });

  it("Testing metadata transfer for tokens", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.transferFrom(accounts[0],accounts[1],1);
    let result2 = await instance._tokenMeta(1);

    assert.equal(result.receipt.status, true, "Transfer initiation");
    assert.equal(result2.id, 1,"Transfer completetion check : id");
    assert.equal(result2.currentOwner, accounts[1],"Transfer completetion check : new owner");
    assert.equal(result2.directSale, false,"Transfer completetion check : direct sale status");
    assert.equal(result2.bidSale, false,"Transfer completetion check : bid sale status");
    assert.equal(result2.numberOfTransfers, 1 ,"Transfer completetion check : number of transfers");
    
  });






//   it("Testing smart contract function Bid() that enable bidding for NFT to sell", async () => {
//     const instance = await NFTBid.deployed();

//     let result = await instance.Bid(1, { from: accounts[1], value: 7000000 });
//     let result2 = await instance.Bid(1, { from: accounts[2], value: 8000000 });

//     assert.equal(result.receipt.status, true, "Failed to place a bid order no 1");
//     assert.equal(result2.receipt.status, true, "Failed to place a bid order no 2");
//   });

//   it("Testing smart contract function executeBidOrder() that enables owner of NFT to execute the bid order", async () => {
//     const instance = await NFTBid.deployed();

//     let result = await instance.executeBidOrder(1, 0);

//     assert.equal(
//       result.receipt.logs[1].event,
//       "Transfer",
//       "NFT Transfer Failed"
//     );
//   });

 })
 
});
