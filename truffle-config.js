const HDWalletProvider = require('@truffle/hdwallet-provider');

const { mnemonic, BSCSCANAPIKEY} = require('./env.json');
/*
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();*/

module.exports = {
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    bscscan: BSCSCANAPIKEY
  },
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard BSC port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    bsc_testnet: {
      provider: () => new HDWalletProvider(mnemonic.testnet, `https://data-seed-prebsc-1-s1.binance.org:8545`),
      network_id: 97,
      confirmations: 1,
      timeoutBlocks: 5000,
      skipDryRun: true
    },
    kcc_testnet: {
      provider: () => new HDWalletProvider(mnemonic.testnet, `https://rpc-testnet.kcc.network`),
      network_id: 322,
      confirmations: 1,
      timeoutBlocks: 50000,
      skipDryRun: true
    },
    poly_testnet: {
      provider: () => new HDWalletProvider(mnemonic.testnet, `https://rpc-mumbai.matic.today`),
      network_id: 80001,
      confirmations: 1,
      timeoutBlocks: 5000,
      skipDryRun: true
    },
    vel_testnet: {
      provider: () => new HDWalletProvider(mnemonic.testnet, `https://rpc.velaverse.io`),
      network_id: 555,
      confirmations: 1,
      timeoutBlocks: 5000,
      skipDryRun: true
    },
    aur_testnet: {
      provider: () => new HDWalletProvider(mnemonic.testnet, `https://testnet.aurora.dev`),
      network_id: 1313161555,
      confirmations: 1,
      timeoutBlocks: 5000,
      skipDryRun: true
    },
    bsc: {
      provider: () => new HDWalletProvider(mnemonic.bsc, `https://bsc-dataseed1.binance.org`),
      network_id: 56,
      confirmations: 10,
      timeoutBlocks: 5000,
      skipDryRun: true
    },
    etherTestnet: {
      provider: () => new HDWalletProvider(mnemonic.testnet, `https://ropsten.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161`),
      network_id: 3,
      confirmations: 5,
      timeoutBlocks: 5000,
      skipDryRun: true
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "^0.8", // A version or constraint - Ex. "^0.5.0"
      optimizer: {
        enabled: true,
        runs: 50
    }
    }
  }
}