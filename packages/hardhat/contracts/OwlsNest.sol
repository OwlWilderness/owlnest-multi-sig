pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract OwlsNest {

  //events
  event SetPurpose(address sender, string purpose);
  event Owner(address indexed owner,bool added);

  //variables
  string public purpose = "Supporting Wilderness Conservation";
  uint public signaturesRequired;

  //mappings
  mapping (address => bool) public owners;

  constructor(address[] memory _owners, uint _signaturesRequired)  {
        _updateSigsRequired(_signaturesRequired);
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            _addSigner(owner);
        }
  }
  
  function _addSigner(address newSigner) private {
      require(newSigner != address(0), "_addSigner: zero address");
      require(!owners[newSigner], "_addSigner: already an owner");
      owners[newSigner] = true;
      emit Owner(newSigner, owners[newSigner]);
  }

  function _updateSigsRequired(uint _signaturesRequired) private {
      require(_signaturesRequired > 0, "constructor: must be non-zero sigs required");
      signaturesRequired = _signaturesRequired;
  }

  function setPurpose(string memory newPurpose) public {
      purpose = newPurpose;
      //console.log(msg.sender,"set purpose to",purpose);
      emit SetPurpose(msg.sender, purpose);
  }

  //modifiers
  modifier onlySelf() {
      require(msg.sender == address(this), "Not Self");
      _;
  }

  // to support receiving ETH by default
  receive() external payable {}
  fallback() external payable {}
}
