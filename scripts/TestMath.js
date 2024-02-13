const { FhenixClient,getPermit } = require("fhenixjs");
const { deployments,ethers } = require("hardhat");
const { Instance } = require("./FHEisntance");

let instance;
// // let permission;
const provider = ethers.provider;
instance = new FhenixClient({provider});

async function TestMath() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];
    console.log(signer.address);
    console.log(accounts[0].address);

    await deployments.fixture(["all"]);

    const TestMath = await deployments.get("TestMath");

    const TEST = await ethers.getContractAt("TestMath",TestMath.address,signer);

    // const MathInstance = Instance(TestMath.address);

    const encryptedValue = await instance.encrypt_uint32(16);

    const SQRT = await TEST.getSQRT(encryptedValue);
}

TestMath().then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});