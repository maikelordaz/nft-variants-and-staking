// SPDX-License-Identifier: MIT

import {ERC721, ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

pragma solidity 0.8.27;

contract NFT is ERC721, ERC721Enumerable {
    uint16 private MAX_SUPPLY = 1000;
    uint16 private _tokenCounter;

    error NFT__MaxSupplyReached();

    constructor() ERC721("NFT", "NFT") {}

    function mintNewTokens(address to, uint256 tokenId) public {
        require(_tokenCounter < MAX_SUPPLY, NFT__MaxSupplyReached());
        ++_tokenCounter;
        _safeMint(to, tokenId);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override(ERC721, ERC721Enumerable) returns (address) {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
