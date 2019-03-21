const Web3Utils = require('web3-utils')
const HomeBridge = artifacts.require('HomeBridgeErcToNative.sol')
const EternalStorageProxy = artifacts.require('EternalStorageProxy.sol')
const BridgeValidators = artifacts.require('BridgeValidators.sol')
const {ERROR_MSG, ZERO_ADDRESS} = require('./setup');
const {createMessage, sign } = require('./helpers/helpers');
const minPerTx = web3.toBigNumber(web3.toWei(0.01, "ether"));
const requireBlockConfirmations = 8;
const gasPrice = Web3Utils.toWei('1', 'gwei');
const oneEther = web3.toBigNumber(web3.toWei(1, "ether"));
const halfEther = web3.toBigNumber(web3.toWei(0.5, "ether"));
const foreignDailyLimit = oneEther
const foreignMaxPerTx = halfEther


contract('HomeBridge_ERC20_to_Native', async (accounts) => {
  let homeContract, validatorContract, authorities, owner;
  before(async () => {
    validatorContract = await BridgeValidators.new()
    authorities = [accounts[1]]
    owner = accounts[0]
    await validatorContract.initialize(1, authorities, owner)
  })

  describe('#initialize', async() => {
    beforeEach(async () => {
      homeContract = await HomeBridge.new()
      await homeContract.initialize(validatorContract.address, '3', '2', '1', gasPrice, requireBlockConfirmations, foreignDailyLimit, foreignMaxPerTx, owner);
    })
    it('sets variables', async () => {
      
    })
  })
})
