const HDWalletProvider = require('@truffle/hdwallet-provider');

//const { mnemonic, BSCSCANAPIKEY} = require('./env.json');
/*
const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();*/

module.exports = {
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    //bscscan: BSCSCANAPIKEY
  },
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard BSC port (default: none)
      network_id: "*",       // Any network (default: none)
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