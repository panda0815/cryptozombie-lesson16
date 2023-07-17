pragma solidity >=0.5.0 <0.6.0;

import "./ownable.sol";
import "./safemath.sol";

contract ZombieFactory is ownable {
    // Declare contract parameters that adds to zombie factory database on the blockchain. 

    using SafeMath for uint256;
    using SafeMath32 for uint32;
    using SafeMath16 for uint16;

    event NewZombie(uint zombieId, string name, uint dna);
    
    uint dnaDigits = 16;
    uint dnaModulus = 10 ** dnaDigits;
    uint cooldownTime = 1 days;

    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    Zombie[] public zombies;

    // Add mapping of zombie owner to zombie account
    mapping (uint => address) public zombieToOwner;
    mapping (address => uint) ownerZombieCount;

    function _createZombie(string memory _name, uint _dna) internal {
        // Removes zombie from factory when new one is introduced and gives zombie cool down period
        uint id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime), 0 ,0)) - 1;
        zombieToOwner[id] = msg.sender; /// Map zombie owner to the sender.
        //ownerZombieCount[msg.sender]++; /// Increase Zombie count to owner by 1
        ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1); // safeMath
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(string memory _str) private view returns (uint) {
        // Generate new zombie dna using random has generator.
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        // Returns new zombie; throws error if count is wrong.
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
