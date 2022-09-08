// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IRoot.sol";
import "./rewards/Rewarder.sol";
import "./structs/File.sol";
import "./structs/FundingInfo.sol";
import "./structs/FundingState.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


struct Rating {
    address donator;
    uint256 amount;
}

contract Funding is Rewarder, ReentrancyGuard {
    address public _root;
    address public _defaultToken;
    uint32 public _id;

    FundingInfo public _info;
    File[] public _files;
    uint256 public _startTime;
    uint256 public _finishTime;

    uint256 public _balance;
    bool public _accepted;
    bool public _finished;
    File[] public _reports;

    Rating public _top1;
    Rating public _top2;
    Rating public _top3;


    event Donation(address donator, uint256 amount);
    event Finished();


    modifier onlyRoot() {
        require(msg.sender == _root, "Sender must be a root");
        _;
    }

    modifier onlyRootOrSpender() {
        require(msg.sender == _root || msg.sender == _info.spender, "Wrong sender");
        _;
    }

    modifier inState(FundingState expected) {
        require(state() == expected, "Wrong state");
        _;
    }


    constructor(
        address root,
        address defaultToken,
        uint32 id,
        FundingInfo memory info,
        File[] memory files,
        NFTInfo[] memory nfts
    ) Rewarder(info.nftUri) {
        _root = root;
        _defaultToken = defaultToken;
        _id = id;
        _info = info;
        for (uint i = 0; i < files.length; i++) {
            _files.push(files[i]);
        }
        for (uint i = 0; i < nfts.length; i++) {
            _nfts.push(nfts[i]);
        }
        _startTime = block.timestamp;
        _finishTime = _startTime + info.duration;
    }

    function state() public view returns (FundingState) {
        if (_finished) {
            return FundingState.FINISHED;
        } else if (block.timestamp > _finishTime) {
            return FundingState.EXPIRED;
        } else if (_accepted) {
            return FundingState.ACTIVE;
        } else {
            return FundingState.PENDING;
        }
    }

    function accept() public onlyRoot {
        _accepted = true;
    }

    function donateDefault(uint256 amount) public inState(FundingState.ACTIVE) nonReentrant {
        IERC20(_defaultToken).transferFrom(msg.sender, address(this), amount);
        _processDonation(msg.sender, amount);
    }

    function refund() public inState(FundingState.EXPIRED) {
        uint256 amount = _donates[msg.sender].amount;
        require(amount > 0, "Nothing to refund");
        _balance -= amount;
        delete _donates[msg.sender];
        _transfer(msg.sender, amount);
    }

    function withdraw(address to, uint256 amount) public onlyRootOrSpender inState(FundingState.FINISHED) {
        require(amount <= _balance, "Wrong amount");
        _transfer(to, amount);
        _balance -= amount;
    }

    function addReports(File[] calldata reports) public onlyRootOrSpender inState(FundingState.FINISHED) {
        for (uint i = 0; i < reports.length; i++) {
            _reports.push(reports[i]);
        }
    }

    function emergencyFinish() public onlyRoot inState(FundingState.ACTIVE) {
        _finishTime = block.timestamp;
    }


    function _processDonation(address donator, uint256 amount) private {
        if (_balance + amount > _info.target) {
            uint256 returnAmount = _balance + amount - _info.target;
            _transfer(donator, returnAmount);
            amount -= returnAmount;
        }
        DonatorData memory prevData = _donates[donator];
        _balance += amount;
        _donates[donator].amount += amount;
        _donates[donator].count += 1;
        _mintCommonNFTs(donator, prevData);
        IRoot(_root).processDonation(_id, donator, amount);
        emit Donation(donator, amount);
        _updateTop(donator);
        if (_balance == _info.target) {
            _finished = true;
            emit Finished();
            _mintFinishedNFTs();
        }
    }

    function _updateTop(address donator) private {
        uint256 amount = _donates[donator].amount;
        if (amount > _top1.amount) {
            _top3 = _top2;
            _top2 = _top1;
            _top1 = Rating(donator, amount);
        } else if (amount > _top2.amount) {
            _top3 = _top2;
            _top2 = Rating(donator, amount);
        } else if (amount > _top3.amount) {
            _top3 = Rating(donator, amount);
        }
    }

    function _mintFinishedNFTs() private {
        for (uint id = 0; id < _nfts.length; id++) {
            NFTInfo storage nft = _nfts[id];
            if (nft.onlyTop1 && _top1.amount > 0) {
                _mintNFT(_top1.donator, id);
            }
            if (nft.onlyTop2 && _top2.amount > 0) {
                _mintNFT(_top2.donator, id);
            }
            if (nft.onlyTop3 && _top3.amount > 0) {
                _mintNFT(_top3.donator, id);
            }
        }
    }

    function _transfer(address to, uint256 amount) private {
        IERC20(_defaultToken).transfer(to, amount);
    }

}
