import {ethers} from "hardhat";
import {encodeBytes32String} from "ethers";
import {time} from "@nomicfoundation/hardhat-network-helpers";
import {HardhatEthersSigner} from "@nomicfoundation/hardhat-ethers/signers";
import {Voting} from "../typechain-types";
import {expect} from "chai";

describe("Voting", function () {
    let voting: Voting;
    let deadline: number;
    let accounts: HardhatEthersSigner[];
    beforeEach(async () => {
        accounts = await ethers.getSigners();
        deadline = (await time.latest()) + 100;
        const VotingFactory = await ethers.getContractFactory("Voting");
        const titles = [encodeBytes32String("option1"), encodeBytes32String("option2")];
        voting = await VotingFactory.deploy(accounts[0].address, deadline, titles);
        await voting.waitForDeployment();
    });

    it("Should allow to vote to an account", async () => {
        await voting.allowToVote(accounts[1].address);
        const voter = await voting.voters(accounts[1].address);
        expect(voter[0]).to.be.true
    });

    it("Should vote", async () => {
        await voting.allowToVote(accounts[1].address);
        await voting.connect(accounts[1]).vote(0);

        const proposal = await voting.getProposal(0);
        expect(proposal[1]).to.be.equal(1);
    });

    it("Should not allow to vote", async () => {
        await expect(voting.connect(accounts[1]).vote(0)).to.be.revertedWith("Not allowed to vote to the voter");
    });

    it("Should not let to set a voter", async () => {
        await expect(voting.connect(accounts[1]).allowToVote(accounts[1].address)).to.be.revertedWith("It's only allowed to the Chairman");
    });

    it("Should not let to set a zero-address voter", async () => {
        await expect(voting.allowToVote("0x0000000000000000000000000000000000000000")).to.be.revertedWith("Address of voter mustn't be zero");
    });

    it("Should not let to set a voter twice", async () => {
        await voting.allowToVote(accounts[1].address);
        await expect(voting.allowToVote(accounts[1].address)).to.be.revertedWith("Voter's been already set");
    });

    it("Should revert due to Voting was finished", async () => {
        await voting.allowToVote(accounts[1].address);

        await time.increaseTo(deadline + 10);

        await expect(voting.connect(accounts[1]).vote(0)).to.be.revertedWith("Voting's been finished");

    });
});
