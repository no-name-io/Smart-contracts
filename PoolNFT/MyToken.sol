//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./ERC721URIStorage.sol";

contract MyToken is ERC721, ERC721Enumerable, ERC721URIStorage {
    address public owner;
    uint currentTokenId;
    address public main_contract;
    mapping(address => uint) public stacked;

    struct blockToken {
        uint amount;
        uint pool;
    }
    
    mapping(address => blockToken[]) public blocked;

    constructor() ERC721("NoNamePoolNFT", "NNP") {
        owner = msg.sender;
        main_contract = msg.sender;
    }

    function main_contract_set(address to) public {
        require(owner == msg.sender, "not an owner!");
        main_contract = to;
    }


    function safeMint(address to, uint tokenId) public {
        require(main_contract == msg.sender, "not an owner!");

        _safeMint(to, tokenId);


        currentTokenId=tokenId;
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
        super._beforeTokenTransfer(from, to, tokenId);
    }

  
}