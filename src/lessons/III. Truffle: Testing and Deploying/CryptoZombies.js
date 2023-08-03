// import the contract artifact
const CryptoZombies = artifacts.require("CryptoZombies");

const utils = require("./helpers/utils");
const time = require("./helpers/time");
// npm -g install chai 
var expect = require("chai").expect;
const zombieNames = ["Zombie 1", "Zombie 2"];

// Test Starts here
contract("CryptoZombies", (accounts) => {
    // initialize owners
    let [alice, bob] = accounts;

    // Initialize contract before each test
    let contractInstance;
    beforeEach(async () => {
        // add await for async functions
        contractInstance = await CryptoZombies.new();
    });

    // add tests
    it("should be able to create a new zombie", async () => {
        const result = await contractInstance.createRandomZombie(zombieNames[0], {
            from: alice,
        });
        // verify owner of the zombie
        expect(result.receipt.status).to.equal(true); // assert.equal(result.receipt.status, true);
        expect(result.logs[0].args.name).to.equal(zombieNames[0]); // assert.equal(result.logs[0].args.name, zombieNames[0]);
    });
    it("should not allow two zombies", async () => {
        // pass zombie name and owner to function
        await contractInstance.createRandomZombie(zombieNames[0], { from: alice });
        await utils.shouldThrow(
            contractInstance.createRandomZombie(zombieNames[1], { from: alice })
        );
    });
    
    // add contexts
    context("with the single-step transfer scenario", async () => {
        it("should transfer a zombie", async () => {
            // call create random zombie function
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
            // declare zombieId
            const zombieId = result.logs[0].args.zombieId.toNumber();
            // call transfer from alice to bob after approve function
            await contractInstance.transferFrom(alice, bob, zombieId, {from: alice});
            const newOwner = await contractInstance.ownerOf(zombieId);
            // assert zombie count is same
            expect(newOwner).to.equal(bob); //assert.equal(newOwner, bob);
        });
    });
    context("with the two-step transfer scenario", async () => {
        it("should approve and then transfer a zombie when the approved address calls transferFrom", async () => {
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
            const zombieId = result.logs[0].args.zombieId.toNumber();
            await contractInstance.approve(bob, zombieId, {from: alice});
            await contractInstance.transferFrom(alice, bob, zombieId, { from: bob });
            const newOwner = await contractInstance.ownerOf(zombieId);
            expect(newOwner).to.equal(bob); //assert.equal(newOwner, bob);
        });
        it("should approve and then transfer a zombie when the owner calls transferFrom", async () => {
            const result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
            const zombieId = result.logs[0].args.zombieId.toNumber();
            await contractInstance.approve(bob, zombieId, { from: alice });
            await contractInstance.transferFrom(alice, bob, zombieId, {from: alice});
            const newOwner = await contractInstance.ownerOf(zombieId);
            expect(newOwner).to.equal(bob); //assert.equal(newOwner, bob);
        });
    });
    it("zombies should be able to attack another zombie", async () => {
        let result;
        result = await contractInstance.createRandomZombie(zombieNames[0], {from: alice});
        const firstZombieId = result.logs[0].args.zombieId.toNumber();
        result = await contractInstance.createRandomZombie(zombieNames[1], {from: bob});
        const secondZombieId = result.logs[0].args.zombieId.toNumber();
        // increase time to allow for cool down period
        await time.increase(time.duration.days(1));
        await contractInstance.attack(firstZombieId, secondZombieId, {from: alice});
        expect(result.receipt.status).to.equal(true); // assert.equal(result.receipt.status, true);
    });
});