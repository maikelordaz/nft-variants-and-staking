// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract RewardToken is ERC20, Ownable2Step {
    address public stakingAddress;

    error RewardToken__AddressZero();
    error RewardToken__InvalidCaller();

    constructor() Ownable(msg.sender) ERC20("RewardToken", "RWT") {}

    function setStakingAddress(address _stakingAddress) external onlyOwner {
        require(_stakingAddress != address(0), RewardToken__AddressZero());
        stakingAddress = _stakingAddress;
    }

    function mintStakingRewards(address account, uint256 amount) external {
        require(msg.sender == stakingAddress, RewardToken__InvalidCaller());
        _mint(account, amount);
    }
}
