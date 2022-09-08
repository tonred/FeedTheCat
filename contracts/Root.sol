// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IRoot.sol";
import "./Funding.sol";


contract Root is IRoot, Rewarder {
    address public _dao;
    address public _defaultToken;
    uint32 public _totalFundings;
    mapping(uint32 => address) public _pendingFundings;
    mapping(uint32 => address) public _activeFundings;
    mapping(uint32 => mapping(address => bool)) public _participation;

    event Donation(address funding, address donator, uint256 amount);


    modifier onlyDao {
        require(msg.sender == _dao, "Sender must be a DAO");
        _;
    }

    constructor(
        address dao,
        address defaultToken,
        NFTInfo[] memory nfts,
        string memory nftUri
    ) Rewarder(nftUri) {
        _dao = dao;
        _defaultToken = defaultToken;
        for (uint i = 0; i < nfts.length; i++) {
            _nfts.push(nfts[i]);
        }
    }

    function createFunding(FundingInfo calldata info, File[] calldata files, NFTInfo[] calldata nfts) public override {
        uint32 id = _totalFundings++;
        Funding funding = new Funding(address(this), _defaultToken, id, info, files, nfts);
        _pendingFundings[id] = address(funding);
    }

    function acceptFunding(uint32 fundingID) public override onlyDao {
        address funding = _pendingFundings[fundingID];
        _activeFundings[fundingID] = funding;
        delete _pendingFundings[fundingID];
        Funding(funding).accept();
    }

    function processDonation(uint32 fundingID, address donator, uint256 amount) public override {
        require(msg.sender == _activeFundings[fundingID], "Sender must be an active funding");
        DonatorData storage prevData = _donates[donator];
        _donates[donator].amount += amount;
        if (!_participation[fundingID][donator]) {
            _donates[donator].count += 1;
            _participation[fundingID][donator] = true;
        }
        _mintCommonNFTs(donator, prevData);
        _mintSpecialNFTs(donator, prevData);
        emit Donation(msg.sender, donator, amount);
    }

    function emergencyFinish(uint32 fundingID) public override onlyDao {
        Funding(_activeFundings[fundingID]).emergencyFinish();
    }

    function _mintSpecialNFTs(address donator, DonatorData storage prevData) private {
        // todo add special NFTs logic
    }

}
