pragma solidity >=0.5.0 <0.6.0;

/*
In Lesson 1, you're going to build a "Zombie Factory" to build an army of zombies.

    - Our factory will maintain a database of all zombies in our army
    - Our factory will have a function for creating new zombies
    - Each zombie will have a random and unique appearance

In later lessons, we'll add more functionality, like giving zombies the ability to attack humans or other zombies! But before we get there, we have to add the basic functionality of creating new zombies.
*/

contract ZombieFactory {
    // Declare contract that adds to zombie factory database on the blockchain. 
    // Define parameters and structure of contract.
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
