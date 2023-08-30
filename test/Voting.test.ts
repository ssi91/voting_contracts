import {ethers} from "hardhat";
import {encodeBytes32String} from "ethers";
import {time} from "@nomicfoundation/hardhat-network-helpers";

describe("Voting", function () {
    let voting;
    let deadline;
    let accounts;
    beforeEach(async () => {
        accounts = await ethers.getSigners();
        deadline = (await time.latest()) + 100;
        const VotingFactory = await ethers.getContractFactory("Voting");
        const titles = [encodeBytes32String("option1"), encodeBytes32String("option2")]
        voting = await VotingFactory.deploy(accounts[0].address, deadline, titles);
        await voting.waitForDeployment()
    });

    it("Should allow to vote to an account", async () => {
        // TODO: implement the test-case
    });
});
