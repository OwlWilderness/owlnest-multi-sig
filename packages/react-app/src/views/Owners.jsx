import React from "react";
import { List, Select, Spin, Button, Input } from "antd";
import { useEventListener } from "eth-hooks/events/useEventListener";
import { Address, AddressInput } from "../components";
import {  useLocalStorage } from "../hooks";
import { useContractReader } from "eth-hooks";
import { useHistory } from "react-router-dom";

//import { Select, Button, List, Divider, Input, Card, DatePicker, Slider, Switch, Progress, Spin } from "antd";

function Owners({ contracts, contractName, eventName, blockExplorer, localProvider, mainnetProvider, startBlock }) {
  const history = useHistory();
  const events = useEventListener(contracts, contractName, eventName, localProvider, startBlock);
  const signaturesRequired = useContractReader(contracts, contractName, "signaturesRequired");

  const [to, setTo] = useLocalStorage("to");
  const [amount, setAmount] = useLocalStorage("amount","0");
  const [methodName, setMethodName] = useLocalStorage("addSigner");
  const [newOwner, setNewOwner] = useLocalStorage("newOwner");
  const [newSignaturesRequired, setNewSignaturesRequired] = useLocalStorage("newSignaturesRequired");
  const [data, setData] = useLocalStorage("data","0x");

  return (
    <div style={{ width: 600, margin: "auto", marginTop: 32, paddingBottom: 32 }}>
       <h2 style={{marginTop:32}}>Signatures Required: {signaturesRequired?signaturesRequired.toNumber():<Spin></Spin>}</h2>
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

{/**select transaction to execute */}
      <div style={{border:"1px solid #cccccc", padding:16, width:600, margin:"auto",marginTop:64}}>
      <h2> Update Signers </h2>
        <div style={{margin:8,padding:8}}>
          <Select value={methodName} style={{ width: "100%" }} onChange={ setMethodName }>
            <Option key="addSigner">addSigner()</Option>
            <Option key="removeSigner">removeSigner()</Option>
          </Select>
        </div>
        <div style={{margin:8,padding:8}}>
          <AddressInput
            autoFocus
            ensProvider={mainnetProvider}
            placeholder="new owner address"
            value={newOwner}
            onChange={setNewOwner}
          />
        </div>        
        <div style={{margin:8,padding:8}}>
          <Button onClick={()=>{
            //console.log("METHOD",setMethodName)
            let calldata = contracts[contractName].interface.encodeFunctionData(methodName,[newOwner])
            //console.log("calldata",calldata)
            setData(calldata)
            setAmount("0")
            setTo(contracts[contractName].address)
            setTimeout(()=>{
              history.push('/create')
            },777)
          }}>
            Create 'Modify Signer' Tx
          </Button>        
          </div>
      </div>
{/**update required signatures */}
<div style={{border:"1px solid #cccccc", padding:16, width:600, margin:"auto",marginTop:64}}>
      <h2> Update Requried Signatures </h2>
      <div style={{margin:8,padding:8}}>
          <Input
            ensProvider={mainnetProvider}
            placeholder="new # of signatures required"
            value={newSignaturesRequired}
            onChange={(e)=>{setNewSignaturesRequired(e.target.value)}}
          />
        </div>
        <div style={{margin:8,padding:8}}>
          <Button onClick={()=>{
            //console.log("METHOD",setMethodName)
            let calldata = contracts[contractName].interface.encodeFunctionData("updateSigsRequired",[newSignaturesRequired])
            //console.log("calldata",calldata)
            setData(calldata)
            setAmount("0")
            setTo(contracts[contractName].address)
            setTimeout(()=>{
              history.push('/create')
            },777)
          }}>
           Create 'Update Signatures Requried' Tx
          </Button>        
          </div>
    </div>
  </div>
);
}

export default Owners;

