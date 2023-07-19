pragma solidity ^0.6.7;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
  AggregatorV3Interface public priceFeed; // create global variable

  // initialize constructor to pass variable through Ethereum address
  constructor() public {
    priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
  }

  function getLatestPrice() public view returns (int) {
    // Call function from the constructor and store as price
    (,int price,,,) = priceFeed.latestRoundData();
    return price;
  }

  function getDecimals() public view returns (uint8) {
    // Call function from the constructor and store as decimals
    uint8 decimals = priceFeed.decimals();
    return decimals;
  }
}
