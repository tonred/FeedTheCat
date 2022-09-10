// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IRoot.sol";
import "./Funding.sol";

import "./structs/Interface.sol";

contract Root is IRoot, Rewarder {
    address public _dao;
    address public _defaultToken;
    uint32 public _totalFundings;
    mapping(uint32 => address) public _pendingFundings;
    mapping(uint32 => address) public _activeFundings;
    mapping(uint32 => mapping(address => bool)) public _participation;

    event Donation(address indexed funding, address indexed donator, uint256 amount);
    event NewFunding(uint32 id, address funding, string title, uint256 target, uint32 duration);


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

    function fundingsDetails() public view returns (FundingsDetails[] memory){
        FundingsDetails[] memory fundings = new FundingsDetails[](_totalFundings);
        for (uint32 i = 0; i < _totalFundings; i++) {
            address fundingAddr = _activeFundings[i] != address(0) ? _activeFundings[i] : _pendingFundings[i];
            Funding funding = Funding(fundingAddr);
            FundingsDetails memory details;
            details.id = i;
            details.addr = fundingAddr;
            details.collection = address(funding._collection());
            (string memory title,,, uint256 target,,) = funding._info();
            details.title = title;
            details.target = target;
            details.balance = funding._balance();
            details.finishTime = funding._finishTime();
            details.state = funding.state();
            fundings[i] = details;
        }
        return fundings;
    }

    function emergencyFinish(uint32 fundingID) public override onlyDao {
        Funding(_activeFundings[fundingID]).emergencyFinish();
    }

    function addNfts(NFTInfo[] memory nfts) public onlyDao {
        for (uint i = 0; i < nfts.length; i++) {
            _nfts.push(nfts[i]);
        }
    }

    function setDao(address dao) public onlyDao {
        _dao = dao;
    }

    function _mintSpecialNFTs(address donator, DonatorData storage prevData) private {
        // todo add special NFTs logic
    }

}
