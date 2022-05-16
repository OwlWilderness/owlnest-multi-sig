pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// import "@openzeppelin/contracts/access/Ownable.sol"; 
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract OwlsNest {

    //events
    event SetPurpose(address indexed sender, string purpose);
    event Owner(address indexed owner, bool added);
    event SigsRequired(address indexed sender, uint newSigsRequired );

    //variables
    string public purpose = "Supporting Wilderness Conservation";
    uint256 public signaturesRequired;
    uint256 public nonce = 1;

    //mappings
    mapping (address => bool) public owners;

    constructor(address[] memory _owners, uint _signaturesRequired)  {
            _updateSigsRequired(_signaturesRequired);
            for (uint i = 0; i < _owners.length; i++) {
                address owner = _owners[i];
                _addSigner(owner);
            }
    }
    
//public functions
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
      emit SigsRequired(msg.sender, _signaturesRequired);
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
