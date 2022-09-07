// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./structs/DonatorData.sol";
import "./Funding.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Root {
    address public _dao;
    address public _defaultToken;
    uint32 public _totalFundings;
    mapping(uint32 => address) public _pendingFundings;
    mapping(uint32 => address) public _activeFundings;
    mapping(address => DonatorData) public _donators;

    event Donation(address funding, address donator, uint256 amount);


    modifier onlyDao {
        require(msg.sender == _dao, "Sender must be a DAO");
        _;
    }

    constructor(address dao, address defaultToken) payable {
        _dao = dao;
        _defaultToken = defaultToken;
    }

    function createFunding(FundingInfo calldata info, File[] calldata files, NFTInfo[] calldata nfts) public {
        uint32 id = _totalFundings++;
        Funding funding = new Funding(address(this), _defaultToken, id, info, files, nfts);
        _pendingFundings[id] = address(funding);
    }

    function approveFunding(uint32 fundingID) public onlyDao {
        _activeFundings[fundingID] = _pendingFundings[fundingID];
        delete _pendingFundings[fundingID];
    }

    function processDonation(uint32 fundingID, address donator, uint256 amount) public {
        require(msg.sender == _activeFundings[fundingID], "Sender must be an active funding");
        DonatorData storage data = _donators[donator];
        _donators[donator].amount += amount;
        if (!data.isParticipate[fundingID]) {
            _donators[donator].count += 1;
            _donators[donator].isParticipate[fundingID] = true;
        }
        _mintNFTs(donator, data.amount, data.count);
        emit Donation(msg.sender, donator, amount);
    }

    // todo as library (for root and funding)
    function _mintNFTs(address donator, uint256 prevAmount, uint32 prevCount) private {
//        uint256 amount = _donators[donator].amount;
//        uint32 count = _donators[donator].count;
//        for (uint i = 0; i < _nfts.length; i++) {
//            uint256 minAmount = _nfts[i].minAmount;
//            uint32 minCount = _nfts[i].minCount;
//            if (amount >= minAmount && count >= minCount && (prevAmount < minAmount || prevCount < minCount)) {
//                // todo mint
//            }
//        }
    }

}
