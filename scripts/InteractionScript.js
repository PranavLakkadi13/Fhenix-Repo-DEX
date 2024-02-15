const { FhenixClient,getPermit } = require("fhenixjs");
const { deployments,ethers } = require("hardhat");
const { Instance } = require("./FHEisntance");

async function PairTest2() {
    const accounts = await ethers.getSigners();
    const signer = accounts[0];

    await deployments.fixture(["all"]);

    const BTC = await deployments.get("MockBTC");
    // const ETH = await deployments.get("MockETH");
    const PAIR = await deployments.get("EncryptedPair")

    const MockBTC = await ethers.getContractAt("IEncryptedERC20","0x16c61EA8AA6c5CD0Cc284329a7fb86410F2B95EC",signer);
    // const MockETH = await ethers.getContractAt("MockETH",ETH.address,signer);
    const PairTest = await ethers.getContractAt("EncryptedPairEuint8","0x0528daFBB2667974d15305feEa19cF290b6eB0dB",signer);

    // const BTCInstance = await Instance(BTC.address);
    // const ETHInstance = await Instance(ETH.address);
    const PAIRInstance = await Instance(PAIR.address);

    const nameBTC = await MockBTC.name();
    // const nameETH = await MockETH.name();

    console.log("The name is ", nameBTC);
    // console.log("The name is ", nameETH);

    await MockBTC.mint(1000);
    // await MockETH.mint(1000);
    console.log("Tokens successfully minted!!!!!")

    const BTCEuintBal = await MockBTC.EuintbalanceOf(accounts[0].address);
    // const ETHEuintBal = await MockETH.EuintbalanceOf(accounts[0].address);

    console.log("The encrypted balance in BTC is " + BTCEuintBal.toString());
    // console.log("The encrypted balance in BTC is " + ETHEuintBal.toString());

    // const BTCEncryptedBalKey = await MockBTC.connect(signer).balanceOf(accounts[0].address,BTCInstance.permission);
    // const BTCBalanceDecrypted = await BTCInstance.instance.unseal(BTC.address,BTCEncryptedBalKey);
    // const ETHEncryptedBalKey = await MockBTC.connect(signer).balanceOf(accounts[0].address,ETHInstance.permission);
    // const ETHBalanceDecrypted = await BTCInstance.instance.unseal(ETH.address,ETHEncryptedBalKey);

    const encryptedAmount = await PAIRInstance.instance.encrypt_uint8(10);
    const encryptedAmount1 = await PAIRInstance.instance.encrypt_uint8(15)
    
    // const ApproveBTC = await MockBTC['approve(address,(bytes))'](PAIR.address,encryptedAmount);
    // console.log("Approved MockBTC Successfully");

    // const ApproveETH = await MockETH['approve(address,(bytes))'](PAIR.address,encryptedAmount1);
    // console.log("Approved MockETH Successfully");

    const BeforeLiquidityAddedBTCBalanceOfAMM = await MockBTC.EuintbalanceOf(PairTest.address);
    console.log("The BTC balance of the AMM before liquidity added is : ", BeforeLiquidityAddedBTCBalanceOfAMM.toString());

    // const BeforeLiquidityAddedETHBalanceOfAMM = await MockETH.EuintbalanceOf(PairTest.address);
    // console.log("The ETH balance of the AMM brfore liquidty added is : ", BeforeLiquidityAddedETHBalanceOfAMM.toString());

    // const LiquidityAdded = await PairTest.addLiquidity(encryptedAmount,encryptedAmount1);
    // console.log("The shares minted: " + LiquidityAdded.toString());

    const AfterLiquidityAddedBTCBalanceOfAMM = await MockBTC.EuintbalanceOf(PAIR.address);
    console.log("The BTC balance of the AMM after liquidity added is : ", AfterLiquidityAddedBTCBalanceOfAMM.toString());

    const BalAMM = await PairTest.balanceOf(signer.address,PAIRInstance.permission);
    console.log("The balance of the signer is ", BalAMM.toString());
    
    // const AfterLiquidityAddedETHBalanceOfAMM = await MockBTC.EuintbalanceOf(PAIR.address);
    // console.log("The ETH balance of the AMM after liquidity added is : ", AfterLiquidityAddedETHBalanceOfAMM.toString());
}

PairTest2().then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});