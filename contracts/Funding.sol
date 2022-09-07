// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IRoot.sol";
import "./structs/File.sol";
import "./structs/FundingInfo.sol";
import "./structs/FundingState.sol";
import "./structs/NFTInfo.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";  // todo



contract Funding {
    address public _root;
    address public _defaultToken;
    uint32 public _id;

    FundingInfo public _info;
    File[] public _files;
    NFTInfo[] public _nfts;
    uint256 public _startTime;
    uint256 public _finishTime;

    uint256 public _balance;
    mapping(address => uint256) public _donates;
    bool public _finished;
    File[] public _reports;


    event Donation(address donator, uint256 amount);
    event Finished();


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
    ) {
        _root = root;
        _defaultToken = defaultToken;
        _id = id;
        _info = info;
        // todo memory/storage
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
        } else if (_balance == _info.target) {
            return FundingState.COLLECTED;
        } else if (block.timestamp > _finishTime) {
            return FundingState.EXPIRED;
        } else {
            return FundingState.ACTIVE;
        }
    }

    function donateDefault(uint256 amount) public inState(FundingState.ACTIVE) {
        IERC20(_defaultToken).transferFrom(msg.sender, address(this), amount);
        _processDonation(msg.sender, amount);
    }

    function donateSpecific(address token, uint256 amount, bytes calldata autoRouterData) public inState(FundingState.ACTIVE) {
        // todo auto router (uniswap)
        token; amount; autoRouterData;
        uint256 amountInDefault = 0;  // todo
        _processDonation(msg.sender, amountInDefault);
    }

    function refund() public inState(FundingState.EXPIRED) {
        // todo test optimization "address (memory) sender = msg.sender;"
        uint256 amount = _donates[msg.sender];
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

    function emergencyFinish() public inState(FundingState.ACTIVE) {
        require(msg.sender == _root, "Wrong sender");
        _finishTime = block.timestamp;
    }


    function _processDonation(address donator, uint256 amount) private {
        if (_balance + amount > _info.target) {
            uint256 returnAmount = _balance + amount - _info.target;
            _transfer(donator, returnAmount);
            amount -= returnAmount;
        }
        uint256 prevAmount = _donates[donator];
        _balance += amount;
        _donates[donator] += amount;
        _mintNFTs(donator, prevAmount);
        IRoot(_root).processDonation(_id, donator, amount);
        emit Donation(donator, amount);
        // todo avoid reentrancy! (see "onERC1155BatchReceived")!
        if (_balance == _info.target) {
            _finished = true;
            emit Finished();
        }
    }

    function _mintNFTs(address donator, uint256 prevAmount) private {
        uint256 amount = _donates[donator];
        for (uint i = 0; i < _nfts.length; i++) {
            uint256 minAmount = _nfts[i].minAmount;
            if (prevAmount < minAmount && amount >= minAmount) {
                // todo mint
            }
        }
    }

    function _transfer(address to, uint256 amount) private {
        IERC20(_defaultToken).transfer(to, amount);
    }

}
