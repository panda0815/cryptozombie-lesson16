//import truffle assertions
const truffleAssert = require('truffle-assertions')

// import the contract artifact
const ZombieFactory = artifacts.require('./ZombieFactory.sol')

// Test starts here
contract('ZombieFactory', function (accounts) {
  // predefine the contract instance
  let ZombieFactoryInstance

  // before each test, create a new contract instance
  beforeEach(async function () {
    ZombieFactoryInstance = await ZombieFactory.new()

  })


  // Tests for creatRandomZombie function 
  it('should only create one zombie per address', async function () {
    await ZombieFactoryInstance.createRandomZombie("Mike", { 'from': accounts[0] })
    let ownerZombieCounts = await ZombieFactoryInstance.ownerZombieCount(accounts[0])
    assert.equal(ownerZombieCounts, 1, 'One zombie was not created for address 0 ')

  })

  // Test for creatRandomZombie function 
  it('should not be able to create a second zombie per address', async function () {
    await ZombieFactoryInstance.createRandomZombie("Mike", { 'from': accounts[0] })
    await truffleAssert.reverts(ZombieFactoryInstance.createRandomZombie("Mike", { 'from': accounts[0] }))
    // TypeError: Cannot read property "0x62730..."
    let ownerZombieCounts = await ZombieFactoryInstance.ownerZombieCount(accounts[0])
    // error says ZombieFactoryInstance.ownerZombieCount is not a function
    assert.equal(ownerZombieCounts, 1, 'Second zombie was created for address 0 ')
  })


})