const { FhenixClient,getPermit } = require("fhenixjs");
const { ethers } = require("hardhat");

let instance;
// let permission;
const provider = ethers.provider;
instance = new FhenixClient({provider});

async function Instance(contractAddress) {

  const permit = await getPermit(contractAddress,provider);
  if (!permit) {
    throw new Error("Failed to get permit from FhenixClient");
  }

  instance.storePermit(permit);
  const permission = instance.extractPermitPermission(permit);
  
  console.log("The Instance has been created");
  return {instance,permission};
}

module.exports = {
  Instance
}