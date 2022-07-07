import { useContractReader } from "eth-hooks";
import { ethers } from "ethers";
import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import axios from "axios";
import {Address} from "../components";

/**
 * web3 props can be passed from '../App.jsx' into your local view component for use
 * @param {*} yourLocalBalance balance on current network
 * @param {*} readContracts contracts from current chain already pre-loaded using ethers contract module. More here https://docs.ethers.io/v5/api/contract/contract/
 * @returns react component
 **/
function Home({ yourLocalBalance, readContracts }) {
  // you can also use hooks locally in your component of choice
  // in this case, let's keep track of 'purpose' variable from our contract
  const uri = useContractReader(readContracts, "GNDG", "uri", "1");
  const wvrp = useContractReader(readContracts, "GNDG", "wvrp");
  const lastWvrp = useContractReader(readContracts, "GNDG", "lastWvrp");
  const pricefeed = useContractReader(readContracts, "GNDG", "priceFeed");

  //console.log("tokenURI",uri);
  const [metadata, setMetadata] = useState();

  const getTokenURI = async (uri) => {
    try{
      const metadata = await axios.get(uri);

      if(metadata){
        //return metadata.data
        setMetadata(metadata.data)
        console.log("metadata.data", metadata.data)
        return { ...metadata.data, uri /*, approved: approved === writeContracts.GigaNFT.address */ };
      }
    }catch(e){console.log(e)}

  };

  useEffect(() => {
    if (uri) getTokenURI(uri);
  }, [uri, readContracts]);

  return (
    <div>
      <div style={{ margin: 32 }}>
        <span style={{ marginRight: 8 }}>📝</span>
        <a href="https://mumbai.polygonscan.com/address/0xa40b1c58fb12D2b7f664D482cF4A16186f35016f" target="_blank">ERC-1155 on Mumbai</a> Implementation of <a href="https://docs.alchemy.com/alchemy/road-to-web3/weekly-learning-challenges/5.-connect-apis-to-your-smart-contracts-using-chainlink" target="_blank">
          Aclhemy Road 2 Web 3 Week 5</a>{" "} using <a href="https://github.com/scaffold-eth/scaffold-eth" target="blank">Scaffold-Eth</a> <br></br> (chainlink datafeeds and vrf)
          <p></p> Get Started With Scaffold-Eth @ <a href="https://speedrunethereum.com/" target="_blank">Speed Run Ethereum</a>
      </div>
      <div style={{ margin: 32 }}>
        <span style={{ marginRight: 8 }}>🛠</span>
        Tinker with the GNDG smart contract using the <Link to="/gndg">"Debug GNDG"</Link> tab.
      </div>
      <hr></hr>
      <div style={{ margin: 32 }}>
        gnar and glitch seem to appear during a downward instant 
        <br></br> nay goon and glitching seem to appear during an upward instant
        <p></p> pricefeed: <Address address={pricefeed} fontSize={12} size={'long'}/>
      </div>
      <div style={{ margin: 32 }}>
        <span style={{ marginRight: 8 }}>🤖</span>
        last wvrp: {lastWvrp} <br></br> current wvrp: 
        <span
          className="highlight"
          style={{ marginLeft: 4, /* backgroundColor: "#f9f9f9", */ padding: 4, borderRadius: 4, fontWeight: "bolder" }}
        >
          {wvrp}
        </span>{" "}

        <p></p>{metadata && <img src={metadata.image} width="400" height="400"></img>}
      </div>


      
    </div>
    
  );
}

export default Home;
