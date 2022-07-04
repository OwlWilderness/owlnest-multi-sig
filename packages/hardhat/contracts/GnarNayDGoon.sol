// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//chainlink contracts
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//chainlink random number
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

//alchemy road 2 web 3 challenge 5 on scaffold-eth
//attempt at 1155 on polygon to level skills 
//

contract GNDG is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply, KeeperCompatibleInterface, VRFConsumerBaseV2 {
     using Counters for Counters.Counter;
   VRFCoordinatorV2Interface COORDINATOR;
    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    //polygon testnet: 0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed
    //Rinkeby: 0x6168499c0cFfCaCD319c818142124B7A15E857ab
    //polygon mainnet: 0xAE975071Be8F8eE67addBC1A82488F1C24858067
    address vrfCoordinator = 0xAE975071Be8F8eE67addBC1A82488F1C24858067;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    //rinkeby: 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc
    //polygon testnet: 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f
    //polygon mainnet 500gwei: 0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd
    //polygon mainnet 1000gwei: 0xd729dc84e21ae57ffb6be0053bf2b0668aa2aaf300a2a7b2ddf7dc0bb6e875a8
    bytes32 keyHash = 0xd729dc84e21ae57ffb6be0053bf2b0668aa2aaf300a2a7b2ddf7dc0bb6e875a8;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 callbackGasLimit = 500000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords =  1;

    uint256[] public s_randomWords;
    uint256 public s_randomMod2  = 1;
    uint256 public s_requestId;

    string public lastWvrp = "goon";
    string public wvrp = "gnar";
    
    address s_owner;

    //CHAINLINK KEEPER COMPATIbLE INTERFACE
    //https://docs.chain.link/docs/chainlink-keepers/compatible-contracts/
    /**
    * Public counter variable
    */
    uint public counter;

    /**
    * Use an interval in seconds and a timestamp to slow execution of Upkeep
    */
    uint public /*immutable*/ interval;
    uint public lastTimeStamp;
    int256 public currentPrice;
    bool public enableVRF = false;

    //reference to chainlink aggragator and random number contract;
    AggregatorV3Interface public priceFeed;


    //private variables
    Counters.Counter private _tokenIdCounter;


    
    //metadata for nfts
    // gnar and goon/nay uris - note glitch is in both
    //use chain link randomness to select random metadata
    //VRFConsermerBaseV2 - add state variables, add values, pass in chain link subscription id
    //increate gas - 500000
    string[] gnarUrisIpfs = [
        "https://gndg-metadata.vercel.app/api/WVRPS-ENCORE-001",
        "https://gndg-metadata.vercel.app/api/WVRP-9113",
        "https://gndg-metadata.vercel.app/api/WVRP-9777"
    ];

    string[] nayGoonUrisIpfs = [
        "https://gndg-metadata.vercel.app/api/WVRPS-ENCORING-001",
        "https://gndg-metadata.vercel.app/api/WVRP-678",
        "https://gndg-metadata.vercel.app/api/WVRP-2360"
    ];

    function getMetadata(uint a, uint b) public view returns(string memory){
        require(a < 2, "value must be: [0|1]");
        require(b < 3, "value must be: [0|1|2]");
        
        if (a == 0){
            return gnarUrisIpfs[b];
        } else {
            return nayGoonUrisIpfs[b];
        }
    }
    //set IPFS of current array one at a time
    function setMetadata(uint a, uint b, string memory uri) public onlyOwner{
        require(a < 2, "value must be: [0|1]");
        require(b < 3, "value must be: [0|1|2]");
        
        if (a == 0){
            gnarUrisIpfs[b] = uri;
        } else {
            nayGoonUrisIpfs[b] = uri;
        }
    }
//events
//*
//*
    event RandomWordFulfilled (uint256[] randomWords, uint256 randomWordMod2);
    event TokensUpdated(string, uint256);

//constructor
//*
//*

    constructor(uint updateInterval, address _priceFeed, uint64 subscriptionId) payable VRFConsumerBaseV2(vrfCoordinator) ERC1155("") {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;

        //support chainlink randomness
        //https://vrf.chain.link/
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;        

        // set the price feed address to
        // BTC/USD Price Feed Contract Address on Rinkeby: https://rinkeby.etherscan.io/address/0xECe365B379E1dD183B20fc5f022230C044d51404
        // ETH / USD Rinkeby 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // ETH / USD Polygon 0xF9680D99D6C9589e2a93a78A04A279e509205945
        // MATIC / ETH Polygon (MATIC)	Crypto	0x327e23A4855b6F663a28c5161541d69Af8973302
        // or the MockPriceFeed Contract

        priceFeed = AggregatorV3Interface(_priceFeed);
        currentPrice = getLatestPrice();
        counter = 0;    
        safeMint(msg.sender, 1);
    }

//public funcitons
//*
//*
    function safeMint(address to, uint256 amount) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        bytes memory data;
        string memory defaultUri = gnarUrisIpfs[1];
        _mint(to, tokenId, amount, data);
        _setURI(defaultUri);
    }

    /**
    * Returns the latest price
    */
    function getLatestPrice() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();

        return price;
    }

//public helpers
//*
//*
    function setInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }

    function setPriceFeed(address newFeed) public onlyOwner {
        priceFeed = AggregatorV3Interface(newFeed);
    }  

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function toggleVRF() public onlyOwner{
        enableVRF = !enableVRF;
    }


//external 
//*
//*
    //Chain Link Keeper Support
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    //chainlink keeper upkeep - execute when interval has elapsed
    function performUpkeep (bytes calldata /* performData */) external override {
        if ((block.timestamp - lastTimeStamp) < interval) {
            return; //interval not elappsed
        }
        
        // get last time stamp and latest price
        lastTimeStamp = block.timestamp;
        int latestPrice = getLatestPrice();

        //nothing to see here price has not changed
        if(latestPrice == currentPrice) {
            return;
        }

        //update wvrp based on current market trend
        lastWvrp = wvrp;
        if (latestPrice < currentPrice){
            wvrp = "gnar";
        } else {
            wvrp = "goon";
        }
        currentPrice = latestPrice;

        //request random number from chainlink vrf
        //https://vrf.chain.link/rinkeby
        if(enableVRF){
            requestRandomWords();
        } else {
            updateAllTokenUris();
        }
       
    }

//internal 
//*
//*
//internal helpers
    function stringEqual(string memory a, string memory b) internal pure returns(bool){
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

//internal methods
    //update token uris for wvrp and random number
    function updateAllTokenUris() internal {
        
        //determine uri based on wvrp
        string memory uri;
        if(stringEqual("gnar", wvrp)){
            uri = gnarUrisIpfs[s_randomMod2];
        } else {
            uri = nayGoonUrisIpfs[s_randomMod2];
        }

        //update each token uri
        //for (uint i = 0; i < _tokenIdCounter.current(); i++){
        //    _setTokenURI(i,uri);
        //} 
        setURI(uri);

        emit TokensUpdated(wvrp,s_randomMod2);
    }

//chainlink VRF
    //support for chainlink randomness
    function requestRandomWords() internal onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }    

    //update the token when the random number request is fufilled 
    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords; 
        uint256 randomMod2 = (randomWords[0] % 2) ;
        
        if((randomMod2 == s_randomMod2) && (stringEqual(wvrp,lastWvrp))){
            //do not update if random number and wvrp have not changed
            return;
        }
        s_randomMod2 = randomMod2 ;
        updateAllTokenUris();
    }

    //function mint(address account, uint256 id, uint256 amount, bytes memory data)
    //    public
    //    onlyOwner
    //{
    //    _requireNotPaused();
    //    _mint(account, id, amount, data);
    //}

    //function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    //    public
    //    onlyOwner
    //{
    //    _requireNotPaused();
    //    _mintBatch(to, ids, amounts, data);
    //}

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // to support receiving ETH by default
    receive() external payable {}
    fallback() external payable {}
}