// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract PrimeTokenIdsCounter {
    function primeTokenBalanceOf(
        address nft,
        address owner
    ) external view returns (uint256 primesCount) {
        uint256 balance = IERC721Enumerable(nft).balanceOf(owner);
        uint256 tokenId;
        unchecked {
            primesCount = balance;
            for (uint256 i; i < balance; ++i) {
                tokenId = IERC721Enumerable(nft).tokenOfOwnerByIndex(owner, i);
                for (uint256 divisor = 2; divisor < tokenId; ++divisor) {
                    if (tokenId % divisor == 0) {
                        --primesCount;
                        break;
                    }
                }
            }
        }
    }
}
