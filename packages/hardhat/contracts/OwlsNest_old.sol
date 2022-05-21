pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract OwlsNestOLD {
    using ECDSA for bytes32;

    //events
    event SetPurpose(address sender, string purpose);
    event Owner(address owner, bool added);
    event SigsRequired(uint newSigsRequired );
    event ExecuteTransaction(address owner, address payable to, uint256 value, bytes data, uint256 nonce, bytes32 hash, bytes result);

    //variables
    string public purpose = "Supporting Wilderness Conservation";
    uint256 public signaturesRequired;
    uint256 public nonce = 1;
    uint public chainId;
    uint public ownerCount = 0;



    //mappings
    mapping (address => bool) public owners;

    constructor(uint _chianId, address[] memory _owners, uint _signaturesRequired)  {
            _updateSigsRequired(_signaturesRequired);
            for (uint i = 0; i < _owners.length; i++) {
                address owner = _owners[i];
                _addSigner(owner);
            }
            chainId = _chianId;
    }
    
//public functions
    function transferFunds(address _to, uint256 _amount) public onlySelf nonZeroAddr(_to) {
        require(_amount > 0, "transferFunds: zero amount");
        require(address(this).balance >= _amount, "transferFunds: amount exceeds available balance");
        (bool ok, ) = address(this).call{value: _amount}("");
        require(ok, "could not transfer ether");
    }

    function addSigner(address newSigner) public onlySelf {
        _addSigner(newSigner);
    }

    function removeSigner(address oldSigner) public onlySelf {
        _removeSigner(oldSigner);
    }
    
    function updateSigsRequired(uint256 newSigsRequired) public onlySelf {
        _updateSigsRequired(newSigsRequired);
    }

    function setPurpose(string memory newPurpose) public {
        purpose = newPurpose;
        //console.log(msg.sender,"set purpose to",purpose);
        emit SetPurpose(msg.sender, purpose);
    }
    
    function getTransactionHash(uint256 _nonce, address to, uint256 value, bytes memory data) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), chainId, _nonce, to, value, data));
    }

    function recover(bytes32 _hash, bytes memory _signature) public pure returns (address) {
        return _hash.toEthSignedMessageHash().recover(_signature);
    }

//private functions
    function _removeSigner(address oldSigner) private nonZeroAddr(oldSigner) {
        require(!owners[oldSigner], "_removeSigner: not a signer");
        _updteSigner(oldSigner, false);
    }


    function _addSigner(address newSigner) private nonZeroAddr(newSigner) {
        require(!owners[newSigner], "_addSigner: already an owner");
        _updteSigner(newSigner, true);
    }

    function _updteSigner(address signer, bool add) private {
      owners[signer] = add;
      emit Owner(signer, owners[signer]);
    }

  function _updateSigsRequired(uint256 _signaturesRequired) private {
      require(_signaturesRequired > 0, "constructor: must be non-zero sigs required");
      signaturesRequired = _signaturesRequired;
      emit SigsRequired(_signaturesRequired);
  }

    function executeTransaction(address payable to, uint256 value, bytes memory data, bytes[] memory signatures)
        public
        returns (bytes memory)
    {
        require(owners[msg.sender], "executeTransaction: only owners can execute");
        bytes32 _hash =  getTransactionHash(nonce, to, value, data);
        nonce++;
        uint256 validSignatures;
        address duplicateGuard;
        for (uint i = 0; i < signatures.length; i++) {
            address recovered = recover(_hash, signatures[i]);
            require(recovered > duplicateGuard, "executeTransaction: duplicate or unordered signatures");
            duplicateGuard = recovered;
            if(owners[recovered]){
              validSignatures++;
            }
        }

        require(validSignatures>=signaturesRequired, "executeTransaction: not enough valid signatures");

        (bool success, bytes memory result) = to.call{value: value}(data);
        require(success, "executeTransaction: tx failed");

        emit ExecuteTransaction(msg.sender, to, value, data, nonce-1, _hash, result);
        return result;
    }

  //modifiers
    modifier onlySelf() {
        require(msg.sender == address(this), "Not Self");
        _;
    }

    modifier nonZeroAddr(address _adr) {
        require(_adr != address(0), "nonZeroAddr: zero address");
        _;
    }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}
