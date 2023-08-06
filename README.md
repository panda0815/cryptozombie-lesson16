# CryptoZombies
This implements lessons from [CryptoZombies](https://cryptozombies.io), a free interactive code school that teaches you to write smart contracts in Solidity through building your own crypto-collectables game. 

The app is built in [Truffle](http://truffleframework.com) for testing and blockchain pipeline deployment using Ethereum Virtual Machine.

## Lesson Notes

### I | Solidarity: Beginner to Intermediate Contracts

#### 1. Solidarity Basics
Solidity's code is encapsulated in contracts. A contract is the fundamental building block of Ethereum decetralized applications. Contracts store state variables that are written to the Ehtereum blockchain (unlike data stored in memory).

In the first lesson, contracts are introduced along with
- pragma version compiler declaration
- structs and arrays for complex data type
    - add data to array with .push()
- function declarations
    - We have `visibility modifiers` that control when and where the function can be called from:
        - public can be called anywhere, both internally and externally.
        - private means it's only callable from other functions inside the contract
        - internal is like private but can also be called by contracts that inherit from this one
        - external can only be called outside the contract
    - We also have `state modifiers`, which tell us how the function interacts with the BlockChain:
        - view tells us that by running the function, no data will be saved/changed
        - pure tells us that not only does the function not save any data to the blockchain, but it also doesn't read any data from the blockchain
            - Both of these don't cost any gas to call if they're called externally from outside the contract (but they do cost gas if called internally by another function).
    - Then we have `custom modifiers`. For these we can define custom logic to determine how they affect a function.
- keccak256 and typecasting
- event declarations to interact with D-app's frontend to perform actions when events occur
- introduces web3 library for how frontend interacts with smart contracts

#### 2. Beyond the Basics
In this lesson, additional solidity concepts are introduced, including 
- array mappings 
- addresses to identify a user or smart contract
- identify messenger with msg.sender
- throw error with require to verify certain conditions are true before running a function
- import and iheritance for referencing other contracts
- interface for interacting with contracts on the blockchain you do not own
    - looks like defining a contract, but only declaring functions that we wnat to interact with, ie doens't require `{ }` body to define a function
- storage vs memory
    - State variables (variables declared outside functions) are by default storage and written permanently to the blockchain.
    - Variables declared inside functions are memory and will disappear when the function call ends.

#### 3. Advanced Concepts
- immutability of contracts
- ownable contracts (similar to admin rights)
    - NOTE: OpenZeppelin is a library of secure and community-vetted smart contracts that you can use in your own DApps.
- constructors are an optional special function with the same name as the contract. It is executed only one time, when the contract is first created.
- a modifier is like a function, but can't be called directly
    - by attaching the modifier's name at the end of a function definition, the code inside the modifier is run first before executing the function, eg a modifier can add a require check (such as checking the ownership of a contract)
    - function modifiers are kind of similar to decorators in Flask or JavaScript. They're used to modify other functions, usually to check some requirements prior to execution.
- Gas and Storage Costs
    ```
    In Solidity, your users have to pay every time they execute a function on your DApp using a currency called gas. Users buy gas with Ether (the currency on Ethereum), so your users have to spend ETH in order to execute functions on your DApp.

    How much gas is required to execute a function depends on how complex that function's logic is. Each individual operation has a gas cost based roughly on how much computing resources will be required to perform that operation (e.g. writing to storage is much more expensive than adding two integers). The total gas cost of your function is the sum of the gas costs of all its individual operations.

    Because running functions costs real money for your users, code optimization is much more important in Ethereum than in other programming languages. If your code is sloppy, your users are going to have to pay a premium to execute your functions — and this could add up to millions of dollars in unnecessary fees across thousands of users.

    Ethereum is like a big, slow, but extremely secure computer. When you execute a function, every single node on the network needs to run that same function to verify its output — thousands of nodes verifying every function execution is what makes Ethereum decentralized, and its data immutable and censorship-resistant.

    The creators of Ethereum wanted to make sure someone couldn't clog up the network with an infinite loop, or hog all the network resources with really intensive computations. So they made it so transactions aren't free, and users have to pay for computation time as well as storage.   

    Here are two general strategies for saving gas with uints inside structs:
        - Use the smallest integer sub-types you can get away with.
        - Cluster identical data types together (put them next to each other) so that Solidity can minimize the required storage space. For example, a struct with fields uint c; uint32 a; uint32 b; will cost less gas than a struct with fields uint32 a; uint c; uint32 b; because the uint32 fields are clustered together.

    View functions don't cost gas when called externally by a user. This is because view functions don't actually change anything on the blockchain – they only read the data. So marking a function with view tells web3.js that it only needs to query your local Ethereum node to run the function, and it doesn't actually have to create a transaction on the blockchain (which would need to be run on every single node, and cost gas).

    However, if a view function is called internally from another function in the same contract that is not a view function, it will still cost gas. This is because the other function creates a transaction on Ethereum, and will still need to be verified from every node. So view functions are only free when they're called externally.

    Using storage is one of the more expensive operations in Solidity, particularly writes.

    This is because every time you write or change a piece of data, it’s written permanently to the blockchain. Forever! Thousands of nodes across the world need to store that data on their hard drives, and this amount of data keeps growing over time as the blockchain grows. So there's a cost to doing that.

    In order to keep costs down, you want to avoid writing data to storage except when absolutely necessary. Sometimes this involves seemingly inefficient programming logic — like rebuilding an array in memory every time a function is called instead of simply saving that array in a variable for quick lookups.

    In most programming languages, looping over large data sets is expensive. But in Solidity, this is much cheaper than using storage if it's in an external view function, since view functions don't cost your users any gas. (And gas costs your users real money!).

    You can use the memory keyword with arrays to create a new array inside a function without needing to write anything to storage. The array will only exist until the end of the function call, and this is a lot cheaper gas-wise than updating an array in storage — free if it's a view function called externally.
    ```


#### 4. Payments
Unlike API functions to a web server, when a payable function is called from the DApp's JavaScript front-end for monetary transer, the call and payment happen simultaneously. This is because the money (Ether), the data (transaction payload), and the contract code itself all live on Ethereum.

#### 5. ERC721 and Crypto-Collectibles
A token on Ethereum is basically just a smart contract that follows some common rules — namely it implements a standard set of functions that all other token contracts share. So basically a token is just a contract that keeps track of who owns how much of that token, and some functions so those users can transfer their tokens to other addresses.

For crypto-collectibles, ERC721 tokens are not interchangeable since each one is assumed to be unique, and are not divisible. You can only trade them in whole units, and each one has a unique ID. So these are a perfect fit for making unique collectibles tradeable. Note that using a standard like ERC721 gives us the benefit of not needing to implement the auction or escrow logic within our contract that determines how players can trade / sell our collectibles.

To prevent over- or under-flows, OpenZeppelin has created a library called SafeMath that checks typecasting and math operation issues by default.

### II | Chainlink: Data Feeds and Computation
Chainlink is a framework for decentralized oracle networks (DONs), and is a way to get data in from multiple sources across multiple oracles. This DON aggregates data in a decentralized manner and places it on the blockchain in a smart contract (often referred to as a "price reference feed" or "data feed") for us to read from. So all we have to do, is read from a contract that the Chainlink network is constantly updating for us!

Using Chainlink Data Feeds is a way to cheaply, more accurately, and with more security gather data from the real world in this decentralized context. Since the data is coming from multiple sources, multiple people can partake in the ecosystem and it becomes even cheaper than running even a centralized oracle. The Chainlink network uses a system called Off-Chain Reporting to reach a consensus on data off-chain, and report the data in a cryptographically proven single transaction back on-chain for users to digest.

There is so much more to Chainlink Oracles than what we've just covered here, and we are going to go over how this all works, as well as some other incredibly powerful features. The next lesson demonstrates how to work with Truffle, Hardhat, Front Ends, DeFi, and more that bring Chainlink Data Feeds to life even more. Once you learn some of those concepts, you can come back to the Truffle Starter Kit, Hardhat Starter Kit, and Brownie Starter Kit (Chainlink Mix), to build sophisticated smart contract applications in development suites.

### III | Testing and Deploying DApps with Oracle and Truffle

#### Deploying DApps with Truffle
Install Truffle and additional packages once (requires node.js installed)
    ```
    npm install truffle -g
    npm install truffle-hdwallet-provider
    npm install loom-truffle-provider
    ``````

Initialize Truffle
    ```truffle init```

Run compiler to translate contracts into bytecode and build artifacts
    ```truffle compile```

Deploy Contract (try with --network rinkeby, --network loom_testnet, --network basechain)
    ```truffle migrate```

Run
    ```npm run dev```



#### Testing Smart Contracts with Truffle
Create new test file
    ```touch test/CryptoZombies.js.```



Test
    ```truffle test```



#### How to Build an Oracle
##### Create the migration files
To deploy the oracle contract, you must create a file called the ./oracle/migrations/2_eth_price_oracle.js with the following content:

    ```
    const EthPriceOracle = artifacts.require('EthPriceOracle')
    module.exports = function (deployer) {
        deployer.deploy(EthPriceOracle)
    }
    ```

Similarly, to deploy the caller contract, you must create a file called ./caller/migrations/02_caller_contract.js with the following content:

    ```
    const CallerContract = artifacts.require('CallerContract')
    module.exports = function (deployer) {
        deployer.deploy(CallerContract)
    }
    ```


Update package.json file -> add scripts to package.json to automatically update when deployed
    ```cd oracle && npx truffle migrate --network extdev --reset -all && cd ..```
    ```cd caller && npx truffle migrate --network extdev --reset -all && cd ..```

deploy all 
    ```npm run deploy:all```

initialize project
    ```npm init -y```

install dependencies
    ```npm i truffle openzeppelin-solidity loom-js loom-truffle-provider bn.js axios```

start oracle
    ```node EthPriceOracle.js.```

start client 
    ```node Client.js```


