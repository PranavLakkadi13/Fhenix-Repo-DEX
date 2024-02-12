// const { networkConfig } = require("../helper-hardhat-config");
const { network, ethers } = require("hardhat");
const { deployments } = require("hardhat");

module.exports = async () => {
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const { deploy, log } = deployments;
  // const chainId = network.config.chainId;

  const args = ["BITCOIN","BTC"];

  const MockBTC = await deploy("MockBTC", {
    from: deployer.address,
    args: args, 
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
  log("MockBTC Deployed!!!!!!!");
  log("-----------------------------------------------");
};

module.exports.tags = ["all", "MockBTC"];