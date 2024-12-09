// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract EnumerableNFT is ERC721Enumerable, Ownable2Step {
    uint256 private tokenId;
    uint256 public constant MAX_SUPPLY = 100;

    error EnumerableNFT__MaxSupplyReached();

    constructor(address owner) Ownable(owner) ERC721("EnumerableNFT", "ENFT") {
        tokenId = 1;
    }

    function mint(address to) external onlyOwner {
        require(tokenId <= MAX_SUPPLY, EnumerableNFT__MaxSupplyReached());
        _mint(to, tokenId);
        ++tokenId;
    }
}
