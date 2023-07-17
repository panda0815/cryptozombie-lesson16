pragma solidity >=0.5.0 <0.6.0;

import "./zombiefactory.sol";

contract KittyInterface {
  // Create interface to interact with other contracts to handle multiple return values
  function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
  );
}

contract ZombieFeeding is ZombieFactory {
  // Initialize contract inherited from Zombie Factory using address from Kitty interface

  KittyInterface kittyContract;

  function setKittyContractAddress(address _address) external onlyOwner {
    kittyContract = KittyInterface(_address);
  }

  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(now + cooldownTime);
  }

  function _isReady(Zombie storage _zombie) internal view returns (bool) {
    return (_zombie.readyTime <= now);
  }

  function feedAndMultiply(uint _zombieId, uint _targetDna, string memory _species) public {
    require(msg.sender == zombieToOwner[_zombieId]); /// Verify zombie owner 
    Zombie storage myZombie = zombies[_zombieId]; /// Add zombie id to storage
    require(_isReady(myZombie)); /// Verify zombie had cool down period
    _targetDna = _targetDna % dnaModulus; /// Take only last 16 digits of dna.
    uint newDna = (myZombie.dna + _targetDna) / 2; /// Declare new dna as average.
    if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
      newDna = newDna - newDna % 100 + 99; /// If dna is a cat, replace last two digits with 99 (cats have 9 lives)
    }
    _createZombie("NoName", newDna);
    _triggerCooldown(myZombie);
  }

  function feedOnKitty(uint _zombieId, uint _kittyId) public {
    /// Returns values for new zombies
    uint kittyDna;
    (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }

}