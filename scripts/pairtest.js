const { fhenixjs } = require("fhenixjs");
const { deployments,ethers } = require("hardhat");

async function PairTest() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];

    await deployments.fixture(["all"]);

    const BTC = await deployments.get("MockBTC");
    const ETH = await deployments.get("MockETH")

    const MockBTC = await ethers.getContractAt("MockBTC",BTC.address,signer);
    const MockETH = await ethers.getContractAt("MockETH",ETH.address,signer);

    const nameBTC = await MockBTC.name();
    const nameETH = await MockETH.name();

    console.log("The name is ", nameBTC);
    console.log("The name is ", nameETH);

    await MockBTC.mint(1000);
    await MockETH.mint(1000);
    console.log("Tokens successfully minted!!!!!")

    
}

PairTest().then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});