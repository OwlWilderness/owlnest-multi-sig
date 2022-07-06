# 🏗 Alchemy Road 2 Web 3 Week 5 on Scaffold-Eth

> ERC-1155 on Mumbai 🚀

This implementation mints an ERC-1155 token that uses wvrp nft images to represent a bull or bear market.  Upon upkeep a random number is requested and the uri is set using the last requested random number and the current trend of a chainlink pricefeed.

- contract: https://mumbai.polygonscan.com/address/0xa40b1c58fb12D2b7f664D482cF4A16186f35016f
- verified contract code: https://mumbai.polygonscan.com/address/0xa40b1c58fb12D2b7f664D482cF4A16186f35016f#code
- Scaffold-Eth Debug: https://gndg.surge.sh/
- VRF Subscription: https://vrf.chain.link/mumbai/928
- Keeper: https://keepers.chain.link/mumbai/1940

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


