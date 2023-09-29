// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Voting.sol";

contract VotingFactory {
    event VotingInstanceCreated(address indexed instance, address indexed chairman);

    mapping(address => Voting[]) public votings;

    function createVoting(uint32 deadline, bytes32[] memory titles) external returns (Voting) {
        Voting instance = new Voting(msg.sender, deadline, titles);
        votings[msg.sender].push(instance);
        emit VotingInstanceCreated(address(instance), msg.sender);
        return instance;
    }
}
