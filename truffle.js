const Wallet = require('ethereumjs-wallet');
const HDWalletProvider = require("truffle-hdwallet-provider");

const vdcUrl = 'http://admin:LivePlanetS3cr3t@rpc.videocoin.network';
const keyfile = require('./manager.json');

const wallet = Wallet.fromV3(keyfile, 'manager');
const privateKeys = [wallet.getPrivateKey().toString('hex')];
const provider = new HDWalletProvider(privateKeys, vdcUrl);

module.exports = {
  networks: {
    alpha: {
      provider: () => provider,
      network_id: '*',   // This network is yours, in the cloud.
      // production: true    // Treats this network as if it was a public net. (default: false)
      gas: 6712388,
    },
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gasPrice: 1000000000
    },
    test: {
      host: "localhost",
      port: 7545,
      network_id: "*",
      gasPrice: 1000000000
    },
    kovan: {
      host: "localhost",
      port: "8591",
      network_id: "*",
      gas: 4700000,
      gasPrice: 1000000000
    },
    core: {
      host: "localhost",
      port: "8777",
      network_id: "*",
      gas: 4700000,
      gasPrice: 1000000000
    },
    sokol: {
      host: "localhost",
      port: "8545",
      network_id: "*",
      gas: 4700000,
      gasPrice: 1000000000
    },
    coverage: {
      host: 'localhost',
      network_id: '*', // eslint-disable-line camelcase
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01,
    },
    ganache: {
      host: 'localhost',
      port: 8545,
      network_id: '*', // eslint-disable-line camelcase
      gasPrice: 1000000000
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  compilers: {
    solc: {
      version: "0.4.24"  // ex:  "0.4.20". (Default: Truffle's installed solc)
    }
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions: {
      currency: 'USD',
      gasPrice: 1
    }
  }
};
