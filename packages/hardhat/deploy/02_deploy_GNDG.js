// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

const localChainId = "31337";

// const sleep = (ms) =>
//   new Promise((r) =>
//     setTimeout(() => {
//       console.log(`waited for ${(ms / 1000).toFixed(3)} seconds`);
//       r();
//     }, ms)
//   );

//deploying "YourContract" (tx: 0xcd04a696299250c055d1c2e4a3821eb3ac0456e10c931d7f9fa03574373708b8)...: deployed at 0xa6A4C57281542ef60E10F246586d0424545295CC with 392938 gas
//deploying "MockV3Aggregator" (tx: 0x3acd6b159cdbc4b6d2d07fbcb421c77a10028b918a88e73f28cbae12e462875f)...: deployed at 0xa40b1c58fb12D2b7f664D482cF4A16186f35016f with 440643 gas

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  // Getting a previously deployed contract
  const MockV3Aggregator = await ethers.getContract("MockV3Aggregator", deployer);
  

  //constructor(uint updateInterval, address _priceFeed, uint64 subscriptionId)
  await deploy("GNDG", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [ 10, MockV3Aggregator.address, 139 ],
    //log: true,
    waitConfirmations: 5,
  });

  const GNDG = await ethers.getContract("GNDG", deployer);
  
  await GNDG.transferOwnership("0xc90Ecdf38215b20f4CE7A8A1346E32F78cC3B909");
  /*  await YourContract.setPurpose("Hello");
  
    To take ownership of yourContract using the ownable library uncomment next line and add the 
    address you want to be the owner. 
      //await yourContract.transferOwnership(YOUR_ADDRESS_HERE);

    //const yourContract = await ethers.getContractAt('YourContract', "0xaAC799eC2d00C013f1F11c37E654e59B0429DF6A") //<-- if you want to instantiate a version of a contract at a specific address!
  */

  /*
  //If you want to send value to an address from the deployer
  const deployerWallet = ethers.provider.getSigner()
  await deployerWallet.sendTransaction({
    to: "0x34aA3F359A9D614239015126635CE7732c18fDF3",
    value: ethers.utils.parseEther("0.001")
  })
  */

  /*
  //If you want to send some ETH to a contract on deploy (make your constructor payable!)
  const yourContract = await deploy("YourContract", [], {
  value: ethers.utils.parseEther("0.05")
  });
  */

  /*
  //If you want to link a library into your contract:
  // reference: https://github.com/austintgriffith/scaffold-eth/blob/using-libraries-example/packages/hardhat/scripts/deploy.js#L19
  const yourContract = await deploy("YourContract", [], {}, {
   LibraryName: **LibraryAddress**
  });
  */

  // Verify from the command line by running `yarn verify`

  // You can also Verify your contracts with Etherscan here...
  // You don't want to verify on localhost
  // try {
  //   if (chainId !== localChainId) {
  //     await run("verify:verify", {
  //       address: YourContract.address,
  //       contract: "contracts/YourContract.sol:YourContract",
  //       constructorArguments: [],
  //     });
  //   }
  // } catch (error) {
  //   console.error(error);
  // }
};
module.exports.tags = ["GNDG"];
