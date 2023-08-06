const axios = require('axios')
const BN = require('bn.js')
const common = require('./utils/common.js')
const SLEEP_INTERVAL = process.env.SLEEP_INTERVAL || 2000
const PRIVATE_KEY_FILE_NAME = process.env.PRIVATE_KEY_FILE || './oracle/oracle_private_key'
const CHUNK_SIZE = process.env.CHUNK_SIZE || 3
const MAX_RETRIES = process.env.MAX_RETRIES || 5
// store build artifacts as oracle json (ie bytecode versions of smart contracts)
const OracleJSON = require('./oracle/build/contracts/EthPriceOracle.json')
var pendingRequests = []

async function getOracleContract(web3js) {
    // instantiate contract with network ID and return contract instance
    const networkId = await web3js.eth.net.getId()
    return new web3js.eth.Contract(OracleJSON.abi, OracleJSON.networks[networkId].address)
}

async function retrieveLatestEthPrice() {
    // return ether price from Binance API
    const resp = await axios({
        url: 'https://api.binance.com/api/v3/ticker/price',
        params: {
            symbol: 'ETHUSDT'
        },
        method: 'get'
    })
    return resp.data.price
}

async function filterEvents (oracleContract, web3js) {
    // filter ether price events related to latest ether price
    oracleContract.events.GetLatestEthPriceEvent(async (err, event) => {
        if (err) {
            console.error('Error on event', err)
            return
        }
        await addRequestToQueue(event)
    })

    oracleContract.events.SetLatestEthPriceEvent(async (err, event) => {
        if (err) {
            console.error('Error on event', err)
            return
        }
        // Do something with filtered events
    })
}

async function addRequestToQueue(event) {
    // stores callerAddress and id when triggered by latest ether price
    const callerAddress = event.returnValues.callerAddress
    const id = event.returnValues.id
    pendingRequests.push({callerAddress, id})
}

async function processQueue(oracleContract, ownerAddress) {
    // process pending request in chunks
    let processedRequests = 0
    while (pendingRequests.length > 0 && processedRequests < CHUNK_SIZE) {
        const req = pendingRequests.shift() // store first element of request in array
        await processRequest(oracleContract, ownerAddress, req.id, req.callerAddress)
        processedRequests++
    }
}

async function processRequest (oracleContract, ownerAddress, id, callerAddress) {
    // retries if there is error processing request and exits after max retries
    let retries = 0
    while (retries < MAX_RETRIES) {
        try {
            // interacts with Binance public API to return latest ether price
            const ethPrice = await retrieveLatestEthPrice()
            await setLatestEthPrice(oracleContract, callerAddress, ownerAddress, ethPrice, id)
            return
        } catch (error) {
            // pass 0 if reached max retries
            if (retries === MAX_RETRIES - 1) {
                await setLatestEthPrice(oracleContract, callerAddress, ownerAddress, '0', id)
                return
            }
            retries++
        }
    }
}

async function setLatestEthPrice(oracleContract, callerAddress, ownerAddress, ethPrice, id) {
    // remove decimal and create multiplier to not lose information from truncated decimal points
    ethPrice = ethPrice.replace('.', '')
    const multiplier = new BN(10 ** 10, 10)
    const ethPriceInt = (new BN(parseInt(ethPrice), 10)).mul(multiplier)
    const idInt = new BN(parseInt(id))
    try {
        await oracleContract.methods.setLatestEthPrice(ethPriceInt.toString(), callerAddress, idInt.toString()).send({from: ownerAddress})
    } catch (error) {
        console.log('Error encountered while calling setLatestEthPrice.')
        // Do some error handling
    }
}

async function init () {
    // initialize oracle to start listening for events
    const {ownerAddress, web3js, client} = common.loadAccount(PRIVATE_KEY_FILE_NAME)
    const oracleContract = await getOracleContract(web3js)
    filterEvents(oracleContract, web3js)
    return {oracleContract, ownerAddress, client}
}

(async () => {
    const {oracleContract, ownerAddress, client} = await init()
    process.on('SIGINT', () => {
        console.log('Calling client.disconnect()')
        client.disconnect()
        process.exit()
    })
    setInterval(async () => {
        // creates delay for each iteration
        await processQueue(oracleContract, ownerAddress)
    }, SLEEP_INTERVAL)
})()
