const { FhenixClient,getPermit } = require("fhenixjs");
const { deployments,ethers } = require("hardhat");
const { Instance } = require("./FHEisntance");

let instance;
// // let permission;
const provider = ethers.provider;
instance = new FhenixClient({provider});

// async function Instance(contractAddress) {
//   const permit = await getPermit(contractAddress,provider);
//   if (!permit) {
//     throw new Error("Failed to get permit from FhenixClient");
//   }

//   instance.storePermit(permit);
//   const permission = instance.extractPermitPermission(permit);
  
//   console.log("The Instance has been created");
//   return {instance,permission};
// }

async function PairTest() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];
    console.log(signer.address);
    console.log(accounts[0].address);

    await deployments.fixture(["all"]);

    const BTC = await deployments.get("MockBTC");
    const ETH = await deployments.get("MockETH");
    const PAIR = await deployments.get("EncryptedPair")

    const MockBTC = await ethers.getContractAt("MockBTC",BTC.address,signer);
    const MockETH = await ethers.getContractAt("MockETH",ETH.address,signer);
    const PairTest = await ethers.getContractAt("EncryptedPair",PAIR.address,signer);

    // const BTCInstance = await Instance(BTC.address);
    // const ETHInstance = await Instance(ETH.address);
    const PAIRInstance = await Instance(PAIR.address);

    const nameBTC = await MockBTC.name();
    const nameETH = await MockETH.name();

    console.log("The name is ", nameBTC);
    console.log("The name is ", nameETH);

    await MockBTC.mint(1000);
    await MockETH.mint(1000);
    console.log("Tokens successfully minted!!!!!")

    const BTCEuintBal = await MockBTC.EuintbalanceOf(accounts[0].address);
    const ETHEuintBal = await MockETH.EuintbalanceOf(accounts[0].address);

    console.log("The encrypted balance in BTC is " + BTCEuintBal.toString());
    console.log("The encrypted balance in BTC is " + ETHEuintBal.toString());

    // const BTCEncryptedBalKey = await MockBTC.connect(signer).balanceOf(accounts[0].address,BTCInstance.permission);
    // const BTCBalanceDecrypted = await BTCInstance.instance.unseal(BTC.address,BTCEncryptedBalKey);
    // const ETHEncryptedBalKey = await MockBTC.connect(signer).balanceOf(accounts[0].address,ETHInstance.permission);
    // const ETHBalanceDecrypted = await BTCInstance.instance.unseal(ETH.address,ETHEncryptedBalKey);

    const encryptedAmount = await instance.encrypt_uint32(1000);

    console.log(MockBTC);
    
    const ApproveBTC = await MockBTC.approve(PAIR.address,encryptedAmount);
    console.log("Approved MockBTC Successfully");

    const ApproveETH = await MockETH.approve(PAIR.address,encryptedAmount);
    console.log("Approved MockETH Successfully");

    const LiquidityAdded = await PairTest.addLiquidity(encryptedAmount,encryptedAmount);
}

PairTest().then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});