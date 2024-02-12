const { ethers } = require('hardhat');
const axios = require('axios');
require('dotenv').config();

// async function mnemonicToAddress() {
//     let words = process.env.MNEMONIC;
  
//     // const mnemonic = ethers.Mnemonic.fromPhrase(words);
//     // if (!mnemonic) {
//     //   throw new Error("No MNEMONIC in .env file");
//     // }
//     // const wallet = ethers.HDNodeWallet.fromMnemonic(mnemonic, `m/44'/60'/0'/0/0`);
  
//     console.log("Ethereum address: " + wallet.address);
//     return wallet.address;
// }

async function callFaucet() {
    const response = await axios.get(`http://localhost:42000/faucet?address=${"0xd7702EB6Ca4C101C918f7d4eaBeDc36e36260482"}`);
    // await fhenixjs.getFunds(address);
    const data = await response.data;
    console.log(`Success!: ${JSON.stringify(data)}`);
}

callFaucet().then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});