// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const {ethers} = require("hardhat");

async function main() {
    const RewarderLibrary = await ethers.getContractFactory("RewarderLibrary");
    const library = await RewarderLibrary.deploy();
    await library.deployed();

    const TestDao = await ethers.getContractFactory("TestDao");
    const dao = await TestDao.deploy();

    const TestToken = await ethers.getContractFactory("TestToken");
    const token = await TestToken.deploy("Test", "TEST");

    const Root = await ethers.getContractFactory("Root", {
        libraries: {RewarderLibrary: library.address},
    });
    const root = await Root.deploy(dao.address, token.address, [], "");
    await root.deployed();

    console.log(`Root deployed to ${root.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
