pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {
    // Declare contract parameters that adds to zombie factory database on the blockchain. 
    event NewZombie(uint zombieId, string name, uint dna);
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    // Add mapping of zombie owner to zombie account
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) internal {
        // Removes zombie from factory when new one is introduced.
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        /// Map zombie owner to the sender.
        zombieToOwner[id] = msg.sender;
        /// Increase Zombie count to owner by 1
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        // Generate new zombie dna using random has generator.
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // Returns new zombie.
        /// Throws error if count is wrong.
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
