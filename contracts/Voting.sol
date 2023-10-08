// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

error Unauthorized(address accessor, address chairman);

error InvalidVoter(address voterAddress);

error InvalidProposal(uint256 proposalIndex, uint256 maxProposals);

error WrongTime(uint256 currentTime, uint256 deadline);

contract Voting {
    modifier onlyChairman() {
        if (msg.sender != chairman) {
            revert Unauthorized(msg.sender, chairman);
        }
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

    constructor(address _chairman, uint32 _deadline, bytes32[] memory titles) {
        require(address(0) != _chairman, "Chairman's address is mandatory");
        require(_deadline > block.timestamp, "Deadline must be later then now");
        chairman = _chairman;
        deadline = _deadline;

        for (uint256 i = 0; i < titles.length; i++) {
            proposals.push(Proposal(titles[i], 0));
        }
    }

    function allowToVote(address voterAddress) external onlyChairman {
        Voter storage voter = voters[voterAddress];
        if (address(0) == voterAddress || voter.isAllowed) {
            revert InvalidVoter(voterAddress);
        }

        voter.isAllowed = true;
        emit VoterSet(voterAddress);
    }

    function vote(uint256 proposalIndex) external {
        if (block.timestamp >= deadline) {
            revert WrongTime(block.timestamp, deadline);
        }
        Voter storage voter = voters[msg.sender];
        if (!voter.isAllowed || voter.voted) {
            revert InvalidVoter(msg.sender);
        }

        if (proposalIndex >= proposals.length) {
            revert InvalidProposal(proposalIndex, proposals.length);
        }
        Proposal storage prop = proposals[proposalIndex];

        prop.count++;
        voters[msg.sender].voted = true;

        emit Voted(msg.sender);
    }

    // TODO: write tests for this function
    function winnerProposal() external view returns (uint, Proposal memory) {
        if (block.timestamp <= deadline) {
            revert WrongTime(block.timestamp, deadline);
        }

        uint256 winnerIndex = 0;
        for (uint256 i = 1; i < proposals.length; i++) {
            if (proposals[i].count > proposals[winnerIndex].count) {
                winnerIndex = i;
            }
        }
        return (winnerIndex, proposals[winnerIndex]);
    }

    // TODO: write tests for this function
    function getProposal(uint256 i) external view returns (Proposal memory) {
        if (i > proposals.length) {
            revert InvalidProposal(i, proposals.length);
        }
        return proposals[i];
    }
}
