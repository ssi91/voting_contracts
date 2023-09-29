import {ethers} from "hardhat";
import {time} from "@nomicfoundation/hardhat-network-helpers";
import {VotingFactory} from "../typechain-types";
import {encodeBytes32String} from "ethers";
import {expect} from "chai";
import {HardhatEthersSigner} from "@nomicfoundation/hardhat-ethers/signers";

describe("VotingFactory", function () {
    let votingFactory: VotingFactory;
    let accounts: HardhatEthersSigner[];
    beforeEach(async () => {
        const VotingFactory = await ethers.getContractFactory("VotingFactory");
        votingFactory = await VotingFactory.deploy();
        await votingFactory.waitForDeployment();
        accounts = await ethers.getSigners();
    });

    it("Should create a voting instance", async () => {
        const deadline = await time.latest() + 100;
        const titles = [encodeBytes32String("option1"), encodeBytes32String("option2")];

        const instanceTx = await votingFactory.createVoting(deadline, titles);
        const tx = await instanceTx.wait();

        // @ts-ignore
        const args = tx?.logs.filter((event) => event.fragment.name === "VotingInstanceCreated")[0].args;

        const votingAddress = args[0];
        const voting = await ethers.getContractAt("Voting", votingAddress);

        const chairmanAddress = await voting.chairman();
        expect(chairmanAddress).to.be.equal(accounts[0].address)
    });
});
