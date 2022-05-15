import React from "react";
import { List } from "antd";
import { useEventListener } from "eth-hooks/events/useEventListener";
import { Address } from "../components";

function Owners({ contracts, contractName, eventName, blockExplorer, localProvider, mainnetProvider, startBlock }) {

  const events = useEventListener(contracts, contractName, eventName, localProvider, startBlock);

  return (
    <div style={{ width: 600, margin: "auto", marginTop: 32, paddingBottom: 32 }}>
    <h2> Owners </h2>
    <List
        style={{maxWidth:600,margin:"auto",marginTop:32}}
        bordered
      dataSource={events}
      renderItem={item => {
        return (
          <List.Item key={item.blockNumber + "_" + item.args.sender + "_" + item.args[1].toString()}>
            <Address address={item.args[0]} ensProvider={mainnetProvider} size="long" fontSize={16} />
            <div style={{padding:16}}>
              {item.args[1]?"👍":"👎"}
            </div>
          </List.Item>
        );
      }}
    />
  </div>
);
}

export default Owners;

