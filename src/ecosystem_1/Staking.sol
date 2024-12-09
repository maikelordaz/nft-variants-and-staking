// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IRewardToken} from "src/ecosystem_1/interfaces/IRewardToken.sol";

contract Staking is IERC721Receiver {
    struct Deposit {
        address depositer;
        uint256 block;
    }

    // blocks per day
    uint256 public constant REWARD_DELAY = 17_280;

    address public immutable i_nftAddress;
    IRewardToken public immutable rewardToken;
    uint256 public immutable i_tokenDecimals;

    mapping(uint256 => Deposit) private _deposits;

    error Staking__AddressZero();
    error Staking__InvalidCaller();
    error Staking__InvalidTime();

    constructor(address _nftAddress, address _tokenAddress) {
        require(_nftAddress != address(0), Staking__AddressZero());
        require(_tokenAddress != address(0), Staking__AddressZero());
        i_nftAddress = _nftAddress;
        rewardToken = IRewardToken(_tokenAddress);
        i_tokenDecimals = rewardToken.decimals();
    }

    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external returns (bytes4) {
        _deposits[tokenId] = Deposit(from, block.number);
        return IERC721Receiver.onERC721Received.selector;
    }

    function collectTokens(uint256 tokenID) external {
        Deposit memory deposit = _deposits[tokenID];

        require(deposit.depositer == msg.sender, Staking__InvalidCaller());
        require(
            deposit.block + REWARD_DELAY <= block.number,
            Staking__InvalidTime()
        );

        _deposits[tokenID].block = block.number;

        rewardToken.mintStakingRewards(msg.sender, 10 * 10 ** i_tokenDecimals);
    }

    function bulkCollectTokens(uint256[] calldata tokenIDs) external {
        uint256 tokens = 0;

        uint256 arrayLength = tokenIDs.length;
        for (uint256 i; i < arrayLength; ++i) {
            Deposit memory deposit = _deposits[tokenIDs[i]];

            if (
                deposit.depositer == msg.sender &&
                deposit.block + REWARD_DELAY <= block.number
            ) {
                tokens += 10 * 10 ** i_tokenDecimals;
                _deposits[tokenIDs[i]].block = block.number;
            }
        }
        rewardToken.mintStakingRewards(msg.sender, tokens);
    }

    function withdrawNFT(uint256 tokenID) external {
        Deposit memory deposit = _deposits[tokenID];
        require(deposit.depositer == msg.sender, Staking__InvalidCaller());

        delete _deposits[tokenID];
        ERC721(i_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenID
        );

        if (deposit.block + REWARD_DELAY <= block.number) {
            rewardToken.mintStakingRewards(
                msg.sender,
                10 * 10 ** i_tokenDecimals
            );
        }
    }
}
