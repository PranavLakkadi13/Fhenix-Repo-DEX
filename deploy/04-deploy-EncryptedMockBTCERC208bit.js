// const { networkConfig } = require("../helper-hardhat-config");
const { network, ethers } = require("hardhat");
const { deployments } = require("hardhat");

module.exports = async () => {
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const { deploy, log } = deployments;
//   const chainId = network.config.chainId;

  const args = ["Bitcoin","BTC"];

  const MockBTC8bit = await deploy("MockBTC8Bit", {
    from: deployer.address,
    // in this contract, we can choose our initial price since it is a mock
    args: args, // --> constructor args
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });

//   if (
//     !developmentChain.includes(network.name) &&
//     process.env.PolygonScan_API_KEY
//   ) {
//     await verify(DecentralisedStableCoin.address, args);
//   }
  log("deploying the contract on the test network!!!!!");
  log("---------------------------------------------------");

  log("----------------------------------------------");
  log("MockBTC8bit Deployed!!!!!!!");
  log("-----------------------------------------------");
};

module.exports.tags = ["all", "MockBTC8bit"];