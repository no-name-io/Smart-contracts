//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";

contract MyToken is ERC721, ERC721Enumerable, ERC721URIStorage {
    address public owner;
    address public blockProvider;
    uint currentTokenId;

    mapping(address => uint) public stacked;
    mapping(address => uint) public Claimers;
    mapping(uint => bool) public returned_pools;

    struct blockToken {
        uint amount;
        uint pool;
    }

    mapping(address => blockToken[]) public blocked;

    constructor() ERC721("MyToken", "MTK") {
        owner = msg.sender;
        blockProvider = msg.sender;
    }








    function safeMint(address to, string calldata tokenId) public {
        require(owner == msg.sender, "not an owner!");

        _safeMint(to, currentTokenId);
        _setTokenURI(currentTokenId, tokenId);

        currentTokenId++;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns(string memory) {
        return "ipfs://";
    }

    function _burn(uint tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721, ERC721Enumerable) {
        if (from!=address(0)){
            uint stackedU = getBlockedNow(from);
            uint BalanceU = balanceOf(from);

            require(BalanceU-1 >= stackedU, "can't transfer stacked tokens!"); 
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function stakeToken(
        uint tokenN
    )external {
       uint tokenU = balanceOf(msg.sender);
       uint tokenB = getBlockedNow(msg.sender);
       require(tokenU >= tokenN, "Sum of tokens < tokens on balance"); 
       require(tokenN >= tokenB, "Sum of tokens < tokens on block"); 
       stacked[msg.sender] = tokenN;
    }

    function getStacked(
        address _user
    ) public view returns (uint) {
        return stacked[_user];
    }

    function getBlockedNow(
        address _user
    ) public view returns (uint) {
        blockToken[] memory arrayBlocked =  blocked[_user];
        uint length = arrayBlocked.length;
        uint _amount = 0;
        for(uint i = 0; i < length; i++) {
           if (arrayBlocked[i].amount>_amount && returned_pools[arrayBlocked[i].pool]==false) _amount=arrayBlocked[i].amount;
        }
        return _amount;
    }    


    function addBlockedTokens(address to, uint amount, uint _pool) external {
        require(blockProvider == msg.sender, "not an blockProvider!");
        uint tokenU = balanceOf(to);
        require(tokenU >= amount, "Sum of tokens < tokens on block"); 
        blockToken[] storage arrayBlocked =  blocked[to];
        // arrayBlocked.push(blockToken(amount,_pool));
        arrayBlocked.push();
        //blocked[to][blocked[to].length]=blockToken(amount,_pool);
        arrayBlocked[arrayBlocked.length-1].amount=amount;
        arrayBlocked[arrayBlocked.length-1].pool=_pool;       
    }
    

    function removeBlockedTokens(address to, uint _pool) external {
        require(blockProvider == msg.sender, "not an blockProvider!");
        uint needDelete = 1000000;
        blockToken[] storage arrayBlocked =  blocked[to];

        for (uint i = 0; i<arrayBlocked.length; i++){
            if(arrayBlocked[i].pool==_pool){
                needDelete = i;
            }
            
        }
        if (needDelete!=1000000)  delete arrayBlocked[needDelete];
    }



    function removeBlockedTokens_return(uint _pool) external {
        require(blockProvider == msg.sender, "not an blockProvider!");
        returned_pools[_pool]=true;
    }

    function setBlockProvider(address to) external {
        require(owner == msg.sender, "not an owner!");

        blockProvider = to;
    }
}