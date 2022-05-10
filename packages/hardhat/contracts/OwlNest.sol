// SPDX-License-Identifier: MIT

//  Off-chain signature gathering multisig that streams funds - @austingriffith
//
// started from 🏗 scaffold-eth - meta-multi-sig-wallet example https://github.com/austintgriffith/scaffold-eth/tree/meta-multi-sig
//    (off-chain signature based multi-sig)
//  added a very simple streaming mechanism where `onlySelf` can open a withdraw-based stream
//

pragma solidity >=0.8.0 <0.9.0;
// Not needed to be explicitly imported in Solidity 0.8.x
// pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

//2022Aril25 quantumtekh.eth
//buidlguild challenge 5 - multi-sig wallet
//based on meta-multi-sig (see above)'
//repurpose: multi-sig for OwlWilderness

contract OwlNest {
    using ECDSA for bytes32;

    //events
    event Deposit(address indexed sender, uint amount, uint balance);
    event ExecuteTransaction(address indexed owner, address payable to, uint256 value, bytes data, uint256 nonce, bytes32 hash, bytes result);
    event Owner(address indexed owner, bool added);

    //mappings
    mapping(address => bool) public isOwner;

    //variable declarations
    uint public signaturesRequired;
    uint public nonce;
    uint public chainId;

    //constructor 
    //-inputs: 
    //--chain id, owner list, # required signatures
    //-validations: 
    //--# required signatures  > 0
    //--owners are valid (not null address)
    //--owners are unique
    constructor(uint256 _chainId, address[] memory _owners, uint _signaturesRequired)  {
        
        _updateSigsRequired(_signaturesRequired);
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            _addSigner(owner);
        }
        chainId = _chainId;
    }

    function _addSigner(address newSigner) private {
        require(newSigner != address(0), "_addSigner: zero address");
        require(!isOwner[newSigner], "_addSigner: owner not unique");
        isOwner[newSigner] = true;
        emit Owner(newSigner, isOwner[newSigner]);
    }
    
    function _updateSigsRequired(uint _signaturesRequired) private {
        require(_signaturesRequired > 0, "constructor: must be non-zero sigs required");
        signaturesRequired = _signaturesRequired;
    }

    modifier onlySelf() {
        require(msg.sender == address(this), "Not Self");
        _;
    }


    function addSigner(address newSigner, uint256 newSignaturesRequired) public onlySelf{
        _addSigner(newSigner);
        _updateSigsRequired(newSignaturesRequired);
    }

    function removeSigner(address oldSigner, uint256 newSignaturesRequired) public onlySelf {
        require(isOwner[oldSigner], "removeSigner: not owner");
        _updateSigsRequired(newSignaturesRequired);
        isOwner[oldSigner] = false;
        emit Owner(oldSigner, isOwner[oldSigner]);
    }

    function updateSignaturesRequired(uint256 newSignaturesRequired) public onlySelf {
        _updateSigsRequired(newSignaturesRequired);
    }

    function getTransactionHash(uint256 _nonce, address to, uint256 value, bytes memory data) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), chainId, _nonce, to, value, data));
    }

    function executeTransaction(address payable to, uint256 value, bytes memory data, bytes[] memory signatures)
        public
        returns (bytes memory)
    {
        require(isOwner[msg.sender], "executeTransaction: only owners can execute");
        bytes32 _hash =  getTransactionHash(nonce, to, value, data);
        nonce++;
        uint256 validSignatures;
        address duplicateGuard;
        for (uint i = 0; i < signatures.length; i++) {
            address recovered = recover(_hash, signatures[i]);
            require(recovered > duplicateGuard, "executeTransaction: duplicate or unordered signatures");
            duplicateGuard = recovered;
            if(isOwner[recovered]){
              validSignatures++;
            }
        }

        require(validSignatures>=signaturesRequired, "executeTransaction: not enough valid signatures");

        (bool success, bytes memory result) = to.call{value: value}(data);
        require(success, "executeTransaction: tx failed");

        emit ExecuteTransaction(msg.sender, to, value, data, nonce-1, _hash, result);
        return result;
    }

    function recover(bytes32 _hash, bytes memory _signature) public pure returns (address) {
        return _hash.toEthSignedMessageHash().recover(_signature);
    }

    receive() payable external {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    //
    //  new streaming stuff
    //

    event OpenStream(address indexed to, uint256 amount, uint256 frequency);
    event CloseStream(address indexed to);
    event Withdraw(address indexed to, uint256 amount, string reason);

    struct Stream {
        uint256 amount;
        uint256 frequency;
        uint256 last;
    }
    mapping(address => Stream) public streams;

    function streamWithdraw(uint256 amount, string memory reason) public {
        require(streams[msg.sender].amount > 0, "withdraw: no open stream");
        _streamWithdraw(payable(msg.sender), amount, reason);
    }

    function _streamWithdraw(address payable to, uint256 amount, string memory reason) private {
        uint256 totalAmountCanWithdraw = streamBalance(to);
        require(totalAmountCanWithdraw >= amount,"withdraw: not enough");
        streams[to].last = streams[to].last + ((block.timestamp - streams[to].last) * amount / totalAmountCanWithdraw);
        emit Withdraw( to, amount, reason );
        to.transfer(amount);
    }

    function streamBalance(address to) public view returns (uint256){
      return (streams[to].amount * (block.timestamp-streams[to].last)) / streams[to].frequency;
    }

    function openStream(address to, uint256 amount, uint256 frequency) public onlySelf {
        require(streams[to].amount == 0, "openStream: stream already open");
        require(amount > 0, "openStream: no amount");
        require(frequency > 0, "openStream: no frequency");

        streams[to].amount = amount;
        streams[to].frequency = frequency;
        streams[to].last = block.timestamp;

        emit OpenStream(to, amount, frequency);
    }

    function closeStream(address payable to) public onlySelf {
        require(streams[to].amount > 0, "closeStream: stream already closed");
        _streamWithdraw(to, streams[to].amount, "stream closed");
        delete streams[to];
        emit CloseStream(to);
    }


}
