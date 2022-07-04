# 🏗 Title

> block text 🚀

🧪 regular text:

![image](https://wvrps.mypinata.cloud/ipfs/Qmeq3o4g8hW2GJQGwzmFn6tqageTHfcMgVAmRUNo5W13Uy/WVRP-678.png)

[HTTP Link](https://https://gndg-metadata.vercel.app/api/WVRP-678/)

`grey highlight`

```
code
```
- bullet


## 🏄‍♂️ stumbled upon

#### to add @chainlink\contracts:
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
To get mainnet Polygon LINK token from the Ethereum mainnet, you must follow a 2 step process.

- Bridge your LINK using the Plasma or PoS bridge.
- Swap the LINK for the ERC677 version via the Pegswap, deployed by the Chainlink.

The Polygon bridge brings over an ERC20 version of LINK, and LINK is an ERC677, so we just have to update it with this swap.

