// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable2Step, Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NFT is ERC721, ERC2981, Ownable2Step {
    uint256 public constant MAX_SUPPLY = 1_000;
    uint256 public constant PRICE = 0.1 ether;
    uint256 public constant DISCOUNT_FACTOR = 2;
    uint96 public constant ROYALTY = 250;
    bytes32 public immutable merkleRoot;
    uint256 public currentSupply;

    address private immutable i_royaltyCollector;
    uint256 private _royalties;
    BitMaps.BitMap private _discountList;

    error NFT__AddressZero();
    error NFT__WrongPrice();
    error NFT__NoMoreTokens();
    error NFT__OnlyTwoNFTs();
    error NFT__AlreadyUsedDiscount();
    error NFT__InvalidCaller();
    error NFT__NoRoyalties();
    error NFT__TransferFailed();

    constructor(
        bytes32 _merkleRoot,
        address _royaltyCollector
    ) Ownable(msg.sender) ERC721("NFTtrio", "NFT3") {
        require(_royaltyCollector != address(0), NFT__AddressZero());
        i_royaltyCollector = _royaltyCollector;
        _setDefaultRoyalty(_royaltyCollector, ROYALTY);
        merkleRoot = _merkleRoot;
    }

    function mint() external payable {
        _mintTokens(PRICE);
    }

    function mintWithDiscount(
        bytes32[] calldata proof,
        uint256 index
    ) external payable {
        require(!BitMaps.get(_discountList, index), NFT__AlreadyUsedDiscount());

        _verifyProof(proof, index);

        // set discount as used
        BitMaps.setTo(_discountList, index, true);

        uint256 discount = PRICE / DISCOUNT_FACTOR;
        _mintTokens(discount);
    }

    function withdrawRoyalties() external {
        require(msg.sender == i_royaltyCollector, NFT__InvalidCaller());
        require(_royalties > 0, NFT__NoRoyalties());

        uint256 amount = _royalties;
        _royalties = 0;
        (bool success, ) = i_royaltyCollector.call{value: amount}("");
        require(success, NFT__TransferFailed());
    }

    function withdrawReserves() external onlyOwner {
        (bool success, ) = msg.sender.call{
            value: address(this).balance - _royalties
        }("");
        require(success, NFT__TransferFailed());
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC2981) returns (bool) {
        return
            interfaceId == type(ERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _mintTokens(uint256 _price) internal {
        require(msg.value == PRICE, NFT__WrongPrice());
        require(currentSupply < MAX_SUPPLY, NFT__NoMoreTokens());
        require(balanceOf(msg.sender) < 2, NFT__NoMoreTokens());

        _safeMint(msg.sender, currentSupply);

        (, uint256 royalty) = royaltyInfo(currentSupply, _price);
        _royalties += royalty;

        currentSupply++;
    }

    function _verifyProof(bytes32[] memory proof, uint256 index) private view {
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(msg.sender, index)))
        );
        require(MerkleProof.verify(proof, merkleRoot, leaf), "Invalid proof");
    }
}
