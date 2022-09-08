// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./structs/DonatorData.sol";
import "./Funding.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Root is Rewarder {
    address public _dao;
    address public _defaultToken;
    uint32 public _totalFundings;
    mapping(uint32 => address) public _pendingFundings;
    mapping(uint32 => address) public _activeFundings;
    mapping(address => DonatorData) public _donators;
    mapping(uint32 => mapping(address => bool)) public _participation;
    NFTInfo[] public _nfts;

    event Donation(address funding, address donator, uint256 amount);


    modifier onlyDao {
        require(msg.sender == _dao, "Sender must be a DAO");
        _;
    }

    constructor(address dao, address defaultToken, NFTInfo[] memory nfts)  {
        _dao = dao;
        _defaultToken = defaultToken;
        for (uint i = 0; i < nfts.length; i++) {
            _nfts.push(nfts[i]);
        }
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
        DonatorData storage prevData = _donators[donator];
        _donators[donator].amount += amount;
        if (!_participation[fundingID][donator]) {
            _donators[donator].count += 1;
            _participation[fundingID][donator] = true;
        }
        _mintCommonAchievements(donator, _donators[donator], _nfts, prevData);
        _mintSpecialAchievements(donator, prevData);
        emit Donation(msg.sender, donator, amount);
    }

    function _mintSpecialAchievements(address donator, DonatorData storage prevData) private {
        // todo
    }

}
