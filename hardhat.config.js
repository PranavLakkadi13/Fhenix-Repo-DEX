// Plugins
// import "@nomicfoundation/hardhat-toolbox";
// import "fhenix-hardhat-plugin";
// import "fhenix-hardhat-docker";
// import "hardhat-deploy";
// import { HardhatUserConfig } from "hardhat/config";

require("@nomicfoundation/hardhat-toolbox");
require("fhenix-hardhat-plugin");
require("fhenix-hardhat-docker");
require("hardhat-deploy");

module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.19" },
      { version: "0.8.20" },
      { version: "0.6.6" },
    ],
  },
  defaultNetwork : "localfhenix",
  setTimeout: 100000,
}


// const config: HardhatUserConfig = {
//   solidity: "0.8.20",
//   // Optional: defaultNetwork is already being set to "localfhenix" by fhenix-hardhat-plugin
//   defaultNetwork: "localfhenix",
// };

// export default config;
