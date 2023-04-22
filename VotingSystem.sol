// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract VotingSystem {

    // data structures for the contract
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint candidateId;
    }

    //  state variables 
    address public votingOfficer;
    uint public votingStartTime;
    uint public votingEndTime;
    uint public winningCandidateId;
    uint public winningVoteCount;

    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;
    uint public candidatesCount;
    uint public votersCount;

    //  events for the contract
    event NewCandidate(uint id, string name);
    event NewVote(address voter);
    event VotingEnded(uint winningCandidateId, uint winningVoteCount);

    // constructor for the contract
    constructor() {
        votingOfficer = msg.sender;
        votingStartTime = 0;
        votingEndTime = 0;
        candidatesCount = 0;
        votersCount = 0;
    }

    // Define the modifier for the voting officer
    modifier onlyOfficer() {
        require(msg.sender == votingOfficer);
        _;
    }

    // Define the function to add a candidate
    function addCandidate(string memory name) public onlyOfficer {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, name, 0);
        emit NewCandidate(candidatesCount, name);
    }

    // Define the function to remove a candidate
    function removeCandidate(uint id) public onlyOfficer {
        require(id > 0 && id <= candidatesCount);
        delete candidates[id];
    }

    // Define the function to start the voting
    function startVoting() public onlyOfficer {
        require(votingStartTime == 0);
        votingStartTime = block.timestamp;
        votingEndTime = votingStartTime + 60; // 1 minutes
    }

    // Define the function to end the voting and declare the winner
    function endVoting() public onlyOfficer {
        require(block.timestamp >= votingEndTime);
        require(winningCandidateId == 0);
        for (uint i = 1; i <= candidatesCount; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningCandidateId = i;
                winningVoteCount = candidates[i].voteCount;
            }
        }
        emit VotingEnded(winningCandidateId, winningVoteCount);
    }

    // Define the function to vote for a candidate
    function vote(uint candidateId) public {
        require(candidateId > 0 && candidateId <= candidatesCount);
        require(!voters[msg.sender].hasVoted);
        require(block.timestamp >= votingStartTime && block.timestamp < votingEndTime);
        votersCount++;
        voters[msg.sender] = Voter(true, candidateId);
        candidates[candidateId].voteCount++;
        emit NewVote(msg.sender);
    }
}
