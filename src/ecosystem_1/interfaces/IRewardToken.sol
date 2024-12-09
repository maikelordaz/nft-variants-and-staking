// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

interface IRewardToken {
    function acceptOwnership() external;
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function decimals() external view returns (uint8);
    function mintStakingRewards(address account, uint256 amount) external;
    function name() external view returns (string memory);
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function renounceOwnership() external;
    function setStakingAddress(address _stakingAddress) external;
    function stakingAddress() external view returns (address);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
    function transferOwnership(address newOwner) external;
}
