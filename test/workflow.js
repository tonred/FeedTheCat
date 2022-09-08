const {
    time, loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const {anyValue} = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const {expect} = require("chai");
const {ethers} = require("hardhat");

describe("Workflow", function () {

    async function defaultFixture() {
        // Contracts are deployed using the first signer/account by default
        const [account, otherAccount] = await ethers.getSigners();

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

        return [library, dao, token, root, account, otherAccount];
    }

    describe("Funding", function () {
        const TARGET_AMOUNT = 1000;
        const FIRST_DONATION_AMOUNT = 100;
        const EXPECTED_FUNDING_ADDRESS = "0x6D544390Eb535d61e196c87d6B9c80dCD8628Acd";
        let library, dao, token, root, account, otherAccount, funding;
        it("Should create funding", async function () {
            [library, dao, token, root, account, otherAccount] = await loadFixture(defaultFixture);
            const info = {
                "title": "Test funding",
                "description": "Just for testing",
                "nftUri": "",
                "target": TARGET_AMOUNT,
                "spender": account.address,
                "duration": 60,  // 1 minute
            }
            expect(await root.createFunding(info, [], [])).not.to.be.reverted;

            const fundingAddress = await root._pendingFundings(0);
            const Funding = await ethers.getContractFactory("Funding", {
                libraries: {RewarderLibrary: library.address},
            });
            funding = await Funding.attach(fundingAddress);

            expect(fundingAddress).to.be.equal(EXPECTED_FUNDING_ADDRESS);
            expect(await root._activeFundings(0)).to.be.equal("0x0000000000000000000000000000000000000000");
            expect((await funding.state())).to.equal(0);  // 0 = pending
        });
        it("Should accept funding", async function () {
            expect(await dao.testAccept(root.address, 0)).not.to.be.reverted;
            expect(await root._activeFundings(0)).to.be.equal(EXPECTED_FUNDING_ADDRESS);
        });
        it("Should reject fake donation", async function () {
            await expect(root.processDonation(0, account.address, 1)).to.be.revertedWith(
                "Sender must be an active funding"
            );
        });
        it("Should accept donation", async function () {
            const amount = FIRST_DONATION_AMOUNT;
            await token.testMint(account.address, amount);
            await token.approve(funding.address, amount);
            expect(await funding.donateDefault(amount)).not.to.be.reverted;

            expect((await root._donates(account.address)).amount.toNumber()).to.equal(amount);
            expect((await funding._donates(account.address)).amount.toNumber()).to.equal(amount);
            expect((await funding.state())).to.equal(1);  // 1 = active
        });
        it("Should finish funding", async function () {
            const sendAmount = 2 * TARGET_AMOUNT;
            const returnAmount = sendAmount - (TARGET_AMOUNT - FIRST_DONATION_AMOUNT);

            await token.testMint(account.address, sendAmount);
            await token.approve(funding.address, sendAmount);
            expect(await funding.donateDefault(sendAmount)).not.to.be.reverted;

            expect((await token.balanceOf(account.address)).toNumber()).to.equal(returnAmount);
            expect((await root._donates(account.address)).amount.toNumber()).to.equal(TARGET_AMOUNT);
            expect((await funding._donates(account.address)).amount.toNumber()).to.equal(TARGET_AMOUNT);
            expect((await funding.state())).to.equal(3);  // 3 = finished
        });
    });

});
