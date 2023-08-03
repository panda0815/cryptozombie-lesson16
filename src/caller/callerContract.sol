pragma solidity 0.5.0;
import "./EthPriceOracleInterface.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract CallerContract is Ownbable {
    uint256 private ethPrice; // declare price
    EthPriceOracleInterface private oracleInstance; // declare oracle instance
    address private oracleAddress; // provide address of oracle smart contract
    
    event newOracleAddressEvent(address oracleAddress);
    event ReceivedNewRequestIdEvent(uint256 id);
    event PriceUpdatedEvent(uint256 ethPrice, uint256 id);

    function setOracleInstanceAddress (address _oracleInstanceAddress) public onlyOwner {
        oracleAddress = _oracleInstanceAddress; // set oracle address
        oracleInstance = EthPriceOracleInterface(oracleAddress); // instantiate and store results
        emit newOracleAddressEvent(oracleAddress); // fire event
    }
    function updateEthPrice() public {
        uint256 id = oracleInstance.getLatestEthPrice();
        myRequests[id] = true;
        emit ReceivedNewRequestIdEvent(id);
    }
    function callback(uint256 _ethPrice, uint256 _id) public {
        require(myRequests[_id], "This request is not in my pending list.");
        ethPrice = _ethPrice;
        delete myRequests[_id];
        emit PriceUpdatedEvent(_ethPrice, _id);
    }

    modifier onlyOracle() {
      require(msg.sender == oracleAddress, "You are not authorized to call this function.");
      _;
    }
}
