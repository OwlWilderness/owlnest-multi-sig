import { useContractReader } from "eth-hooks";
import { ethers } from "ethers";
import React from "react";
import { Link } from "react-router-dom";
import axios from "axios";

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

  const getTokenURI = async () => {

    //const tokenURI = useContractReader(readContracts, "GNDG", "uri", "1");
    console.log("tokenURI",uri);
    try{
      const metadata = await axios.get(uri);
      if(metadata){
        return { ...metadata.data, uri /*, approved: approved === writeContracts.GigaNFT.address */ };
      }
    }catch(e){console.log(e)}

    //console.log("metadata",metadata.data)
    //const approved = await readContracts.GigaNFT.getApproved(id);

  };

  return (
    <div>
      <div style={{ margin: 32 }}>
        <span style={{ marginRight: 8 }}>📝</span>
        Aclhemy Road 2 Web 3 Challenge in Scaffold-Eth{" "}
      </div>

      <div style={{ margin: 32 }}>
        <span style={{ marginRight: 8 }}>🤖</span>
        last wvrp: {lastWvrp} <p></p> current wvrp: 
        <span
          className="highlight"
          style={{ marginLeft: 4, /* backgroundColor: "#f9f9f9", */ padding: 4, borderRadius: 4, fontWeight: "bolder" }}
        >
          {wvrp}
        </span>{" "}

        <p></p>json uri:
        
        <span
          className="highlight"
          style={{ marginLeft: 4, /* backgroundColor: "#f9f9f9", */ padding: 4, borderRadius: 4, fontWeight: "bolder" }}
        >
          {uri}
        </span>

      </div>

      <div style={{ margin: 32 }}>
        <span style={{ marginRight: 8 }}>🛠</span>
        Tinker with the GNDG smart contract using the <Link to="/gndg">"Debug GNDG"</Link> tab.
      </div>
    </div>
  );
}

export default Home;
