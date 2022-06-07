import { List } from "antd";
import { useEventListener } from "eth-hooks/events/useEventListener";
import Address from "./Address";

/**
  ~ What it does? ~

  Displays a lists of events

  ~ How can I use? ~

  <Events
    contracts={readContracts}
    contractName="YourContract"
    eventName="SetPurpose"
    localProvider={localProvider}
    mainnetProvider={mainnetProvider}
    startBlock={1}
  />
**/

export default function Events({ contracts, contractName, eventName, localProvider, mainnetProvider, startBlock }) {
  // 📟 Listen for broadcast events
  const events = useEventListener(contracts, contractName, eventName, localProvider, startBlock);

  return (
    <div style={{ width: 600, margin: "auto", marginTop: 32, paddingBottom: 32 }}>
      <h2>{eventName} Events
        <br />
        {eventName === "Owner"
          ? " ⟠ Address | Added"
          : eventName === "SetPurpose"
          ? " ⟠ Address | New Purpose"
          : eventName === "SigsRequired" 
          ? " ⟠ Address | New Sigs Required"
          : "some unknown event headers " }</h2>
      
      <List
        style={{maxWidth:600, margin:"auto",marginTop:32}}
        bordered
        dataSource={events}
        renderItem={item => {

          return (
            <List.Item key={item.blockNumber + "_" + item.args[0] + "_" + item.args[1].toString()}>
            <Address address={item.args[0]} ensProvider={mainnetProvider} size="long" fontSize={16} />
            <div style={{padding:16}}>
              {item.args[1].toString()}
            </div>
          </List.Item>
          );
        }}
      />
    </div>
  );
}
