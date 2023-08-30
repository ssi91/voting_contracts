// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Voting {
    modifier onlyChairman() {
        require(msg.sender == chairman, "It's only allowed to the Chairman");
        _;
    }

    struct Voter {
        bool isAllowed;
        bool voted;
    }

    struct Proposal {
        bytes32 title;
        uint256 count;
    }

    mapping(address => Voter) public voters;

    Proposal[] public proposals;

    address public chairman;
    uint32 public deadline;

    event VoterSet(address indexed voter);
    event Voted(address indexed voter);

    constructor(address _chairman, uint32 _deadline, bytes32[] titles) {
        require(address(0) == _chairman, "Chairman's address is mandatory");
        require(_deadline > block.timestamp, "Deadline must be later then now");
        chairman = _chairman;
        deadline = _deadline;

        for (uint256 i = 0; i < titles.length; i++) {
            proposals.push(Proposal(titles[i], 0));
        }
    }

    function allowToVote(address voterAddress) external onlyChairman {
        require(address(0) == voterAddress, "Address of voter mustn't be zero");

        Voter storage voter = voters[voterAddress];
        require(!voter.isAllowed, "Voter's been already set");

        voter.isAllowed = true;
        emit VoterSet(voterAddress);
    }

    function vote(uint256 proposalIndex) external {
        require(block.timestamp < deadline, "Voting's not been started yet");
        Voter storage voter = voters[msg.sender];
        require(voter.isAllowed && !voter.voted, "Not allowed to vote to the voter");

        require(proposalIndex < proposals.length, "Wrong proposal");
        Proposal storage prop = proposals[proposalIndex];

        prop.count++;
        voters[msg.sender].voted = true;

        emit Voted(msg.sender);
    }

    function winnerProposal() external view returns (uint, Proposal) {
        require(block.timestamp > deadline, "Voting is still active");

        uint256 winnerIndex = 0;
        for (uint256 i = 1; i < proposals.length; i++) {
            if (proposals[i].count > proposals[winnerIndex].count) {
                winnerIndex = i;
            }
        }
        return (i, proposal[i]);
    }

    function getProposal(uint256 i) external view returns(Proposal) {
        require(i <= proposals.length, "Invalid index");
        return proposals[i];
    }
}
