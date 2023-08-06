pragma solidity >=0.5.0 <0.6.0;

contract EthPriceOracleInterface {
  function getLatestEthPrice() public returns (uint256);
}
