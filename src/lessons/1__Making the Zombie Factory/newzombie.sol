pragma solidity >=0.5.0 <0.6.0;

contract ZombieFactory {
    // Declare contract event with defined parameters and their structure.

    event NewZombie(uint zombieId, string name, uint dna);
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;

    struct Zombie {
        string name;
        uint dna;
    }

    Zombie[] public zombies;

    function _createZombie(string memory _name, uint _dna) private {
        // Removes zombie from factory when new one is introduced.
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        // Generate new zombie dna using random has generator.
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // Returns new zombie.
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
    
}
