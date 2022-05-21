import React, { useCallback, useEffect, useState } from "react";
import { Button, List, Divider, Input, Card, DatePicker, Slider, Switch, Progress, Spin } from "antd";
import { SyncOutlined } from "@ant-design/icons";
import { parseEther, formatEther } from "@ethersproject/units";
import { ethers } from "ethers";
import { Address, AddressInput, Balance, Blockie, TransactionListItem } from "../components";
import { useContractReader, useEventListener, usePoller } from "../hooks";

const axios = require("axios");

const DEBUG = false;

export default function Transactions({
  poolServerUrl,
  contractName,
  signaturesRequired,
  address,
  nonce,
  userProvider,
  mainnetProvider,
  localProvider,
  yourLocalBalance,
  price,
  tx,
  readContracts,
  writeContracts,
  blockExplorer,
}) {
  const [transactions, setTransactions] = useState();
  usePoller(() => {
    const getTransactions = async () => {
      if (DEBUG) console.log("🛰 Requesting Transaction List");
      if (DEBUG) console.log("passed in Address", address)
      if (DEBUG) console.log("Contract Address", (readContracts[contractName]?.address))
      if (DEBUG) console.log("poolServerUrl", poolServerUrl)
      if (DEBUG) console.log("localProvider._network.chainId", localProvider?._network.chainId)
      const res = await axios.get(
        poolServerUrl + readContracts[contractName]?.address + "_" + localProvider?._network.chainId,
      );
      const newTransactions = [];
      for (const i in res.data) {
        if (DEBUG) console.log("look through signatures of ",res.data[i])
        const thisNonce = ethers.BigNumber.from(res.data[i].nonce);
        if (DEBUG) console.log("nonce",thisNonce);
        if (thisNonce && nonce && thisNonce.gte(nonce)) {
          const validSignatures = [];
          for (const s in res.data[i].signatures) {
            if (DEBUG) console.log("RECOVER:",res.data[i].signatures[s],res.data[i].hash)
            const signer = await readContracts[contractName].recover(res.data[i].hash, res.data[i].signatures[s]);
            if (DEBUG) console.log("signer", signer);
            const isOwner = await readContracts[contractName].isOwner(signer);
            if (DEBUG) console.log("owner", isOwner);
            if (signer && isOwner) {
              validSignatures.push({ signer, signature: res.data[i].signatures[s] });
            }
          }
          const update = { ...res.data[i], validSignatures };
          console.log("update",update)
          newTransactions.push(update);
          if (DEBUG) console.log("newtransactions", newTransactions);
        }
      }
      if (DEBUG) console.log("New Transactions Before SET", newTransactions);
      if (newTransactions && newTransactions.constructor === Array){
        setTransactions(newTransactions);
      }
      if (DEBUG) console.log("Loaded", newTransactions.length);
    };
    if (readContracts) getTransactions();
  }, 3777);

  const getSortedSigList = async (allSigs, newHash) => {
    if (DEBUG) console.log("allSigs", allSigs);

    const sigList = [];
    for (const s in allSigs) {
      if (DEBUG) console.log("SIG", allSigs[s]);
      const recover = await readContracts[contractName].recover(newHash, allSigs[s]);
      sigList.push({ signature: allSigs[s], signer: recover });
    }

    sigList.sort((a, b) => {
      return ethers.BigNumber.from(a.signer).sub(ethers.BigNumber.from(b.signer));
    });

    if (DEBUG) console.log("SORTED SIG LIST:", sigList);

    const finalSigList = [];
    const finalSigners = [];
    const used = {};
    for (const s in sigList) {
      if (!used[sigList[s].signature]) {
        finalSigList.push(sigList[s].signature);
        finalSigners.push(sigList[s].signer);
      }
      used[sigList[s].signature] = true;
    }

    if (DEBUG) console.log("FINAL SIG LIST:", finalSigList);
    return [finalSigList, finalSigners];
  };

  if (!signaturesRequired) {
    return <Spin />;
  }

  if (DEBUG) console.log("transactions",transactions)

  return (
    <div style={{ maxWidth: 750, margin: "auto", marginTop: 32, marginBottom: 32 }}>
      <h1>
        <b style={{ padding: 16 }}>#{nonce ? nonce.toNumber() : <Spin />}</b>
      </h1>

      <List
        bordered
        dataSource={transactions}
        renderItem={item => {
          if (DEBUG) console.log("ITE88888M", item);

          const hasSigned = item.signers.indexOf(address) >= 0;
          if (DEBUG) console.log("has signed", hasSigned);
          const hasEnoughSignatures = item.signatures.length <= signaturesRequired.toNumber();
          if (DEBUG) console.log("has enough sigs", hasSigned);
          return (
            <TransactionListItem item={item} mainnetProvider={mainnetProvider} blockExplorer={blockExplorer} price={price} readContracts={readContracts} contractName={contractName}>
              <span>
                {item.signatures.length}/{signaturesRequired.toNumber()} {hasSigned ? "✅" : ""}
              </span>
              <Button
                onClick={async () => {
                  if (DEBUG) console.log("item.signatures", item.signatures);

                  const newHash = await readContracts[contractName].getTransactionHash(
                    item.nonce,
                    item.to,
                    parseEther("" + parseFloat(item.amount).toFixed(12)),
                    item.data,
                  );
                  if (DEBUG)  console.log("newHash", newHash);

                  const signature = await userProvider.send("personal_sign", [newHash, address]);
                  if (DEBUG) console.log("signature", signature);

                  const recover = await readContracts[contractName].recover(newHash, signature);
                  if (DEBUG) console.log("recover--->", recover);

                  const isOwner = await readContracts[contractName].isOwner(recover);
                  if (DEBUG)  console.log("isOwner", isOwner);

                  if (isOwner) {
                    const [finalSigList, finalSigners] = await getSortedSigList(
                      [...item.signatures, signature],
                      newHash,
                    );
                    const res = await axios.post(poolServerUrl, {
                      ...item,
                      signatures: finalSigList,
                      signers: finalSigners,
                    });
                  }

                  //tx( writeContracts[contractName].executeTransaction(item.to,parseEther(""+parseFloat(item.amount).toFixed(12)), item.data, item.signatures))
                }}
                type="secondary"
              >
                Sign
              </Button>
              <Button

                key={item.hash}
                
                onClick={async () => {
                  const newHash = await readContracts[contractName].getTransactionHash(
                    item.nonce,
                    item.to,
                    parseEther("" + parseFloat(item.amount).toFixed(12)),
                    item.data,
                  );
                  if (DEBUG) console.log("newHash", newHash);

                  if (DEBUG) console.log("item.signatures", item.signatures);

                  const [finalSigList, finalSigners] = await getSortedSigList(item.signatures, newHash);

                  tx(
                    writeContracts[contractName].executeTransaction(
                      item.to,
                      parseEther("" + parseFloat(item.amount).toFixed(12)),
                      item.data,
                      finalSigList,
                    ),
                  );
                }}
                type={hasEnoughSignatures ? "primary" : "secondary"}
              >
                Exec
              </Button>
          </TransactionListItem>
          );
        }}
      />
    </div>
  );
}
