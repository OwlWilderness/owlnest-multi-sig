# 🏗 Alchemy Road 2 Web 3 Week 5 on Scaffold-Eth

Debug Contract Using Scaffold-eth Dapp:  https://gndg.surge.sh/

> ERC-1155 on Mumbai 🚀

This implementation mints an ERC-1155 token that uses wvrp nft images to represent a bull or bear market.  Upon upkeep a random number is requested and the uri is set using the last requested random number and the current trend of a chainlink pricefeed.

- contract: https://mumbai.polygonscan.com/address/0xa40b1c58fb12D2b7f664D482cF4A16186f35016f
- verified contract code: https://mumbai.polygonscan.com/address/0xa40b1c58fb12D2b7f664D482cF4A16186f35016f#code
- Scaffold-Eth Debug: https://gndg.surge.sh/
- VRF Subscription: https://vrf.chain.link/mumbai/928
- Keeper: https://keepers.chain.link/mumbai/1940

Based on: https://docs.alchemy.com/alchemy/road-to-web3/weekly-learning-challenges/5.-connect-apis-to-your-smart-contracts-using-chainlink

## To Do
- display image of current nft metadata


## 🏄‍♂️ stumbled upon

### to add @chainlink\contracts:
[scaffold-eth-with-austin-griffith-chainlink-hackathon-workshop](https://blockpaths.com/projects/scaffold-eth-with-austin-griffith-chainlink-hackathon-workshop/)
35:50

```
> cd .\packages\hardhat
> yarn add @chainlink/contracts
```

### Errors
> Error in plugin hardhat-abi-exporter: duplicate output destination: C:\repo\git\gndg\polygon\packages\react-app\src\contracts\ABI\AggregatorV3Interface.json
[Resolve Source](https://github.com/ItsNickBarry/hardhat-abi-exporter)

Update `hardhat-config.js` set `flat: false`
```
  abiExporter: {
    path: "../react-app/src/contracts/ABI",
    runOnCompile: true,
    clear: true,
    flat: false,
    only: [],
    spacing: 2,
    pretty: false,
  },
  ```
  
  
###  Mainnet Polygon LINK token
[source](https://docs.polygon.technology/docs/develop/oracles/chainlink/#:~:text=Chainlink%20enables%20your%20contracts%20to,your%20contract%20to%20consume%20it.)
  
To get mainnet Polygon LINK token from the Ethereum mainnet, you must follow a 2 step process.

- Bridge your LINK using the Plasma or PoS bridge.
- Swap the LINK for the ERC677 version via the Pegswap, deployed by the Chainlink.

The Polygon bridge brings over an ERC20 version of LINK, and LINK is an ERC677, so we just have to update it with this swap.

### Deploying Mock Aggregator on localhost
Create contract MockPriceFeed.sol with the following contents:
```
//SPDX-Licence-Identifer: MIT
pragma solidity ^0.6.4;

import "@chainlink/contracts/src/v0.6/tests/MockV3Aggregator.sol";
```

Create a deploy script like the following
```
//01_deploy_MockPriceFeedjs.js

const { ethers } = require("hardhat");

const localChainId = "31337";


module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  //constructor args(decimal places, initial answer)
  await deploy("MockV3Aggregator", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [ 12, 123456789123 ],
    log: true,
    waitConfirmations: 5,
  });

};
module.exports.tags = ["MockV3Aggregator"];
```

Use MockV3Aggregator.address when deploying on localhost
```
  const MockV3Aggregator = await ethers.getContract("MockV3Aggregator", deployer);
  //MockV3Aggregator.address
```
