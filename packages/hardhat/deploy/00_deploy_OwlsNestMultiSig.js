// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

const localChainId = "31337";

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  await deploy("OwlsNestMultiSig", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    //[deployer, "0x7f68704858cb70df2cddf8cf1bab8ec5708b023d", "0x97843608a00e2bbc75ab0c1911387e002565dede", "0x1a4c2b35c9b4cc9f9a833a43dbe3a78fdb80bb54"]
    from: deployer,
    args: [ localChainId, ["0x6BD4B849220EF05b0320c086213aa102D96Bd003"], 1],
    log: true,
    waitConfirmations: 5,
  });

  // Getting a previously deployed contract
  //const OwlsNestMultiSig = await ethers.getContractAt("OwlsNestMultiSig", deployer);

};
module.exports.tags = ["OwlsNestMultiSig"];
