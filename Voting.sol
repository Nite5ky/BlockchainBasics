// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

contract Ballot {
    // STRUCTS

    // Struct to represent a voter
    struct Voter {
        string voterName;
        bool hasVoted; // If true, person has casted their vote
    }

    // Struct to represent a candidate
    struct Candidate {
        string candidateName;
        uint voteCount; // Votes this candidate got
    }

    // Struct to represent a vote
    struct Vote {
        address voterAddress;
        uint choice; // Choice number of candidate on Ballot list
    }

    // VARIABLES

    // Total counts for voters, votes, and candidates
    uint public totalVoter = 0;
    uint public totalVote = 0;
    uint public totalCandidate = 0;

    // Address and name of the chairperson overseeing the election
    address public chairpersonAddress;
    string public chairpersonName;

    // Mapping to store registered voters, candidates, and votes
    mapping(address => Voter) public voterRegister;
    mapping(uint => Candidate) public candidateRegister;
    mapping(uint => Vote) private votes;

    // Enum to represent the state of the election
    enum State {
        Created,
        Voting,
        Ended
    }
    State public state;

    // MODIFIERS

    // Modifier to restrict access to only the chairperson
    modifier onlyOfficial() {
        require(msg.sender == chairpersonAddress);
        _;
    }

    // Modifier to check the current state of the election
    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    // CONSTRUCTOR

    // Constructor to initialize the contract and set the chairperson
    constructor() {
        chairpersonAddress = msg.sender;
        chairpersonName = "Aakash";
        state = State.Created;
    }

    // FUNCTIONS

    // Function to add a new voter
    function addVoter(
        address _voterAddress,
        string memory _voterName
    ) public inState(State.Created) onlyOfficial {
        Voter memory v;
        v.voterName = _voterName;
        v.hasVoted = false;
        voterRegister[_voterAddress] = v;
        totalVoter++;
    }

    // Function to add a new candidate
    function addCandidate(
        uint _candidateId,
        string memory _candidateName
    ) public inState(State.Created) onlyOfficial {
        Candidate memory c;
        c.candidateName = _candidateName;
        c.voteCount = 0;
        candidateRegister[_candidateId] = c;
        totalCandidate++;
    }

    // to see the ballot list with all registered candidates
    function getCandidateListWithChoices()
        public
        view
        returns (string[] memory candidateNames, uint[] memory choiceNumbers)
    {
        candidateNames = new string[](totalCandidate);
        choiceNumbers = new uint[](totalCandidate);
        for (uint i = 0; i < totalCandidate; i++) {
            candidateNames[i] = candidateRegister[i].candidateName;
            choiceNumbers[i] = i;
        }
        return (candidateNames, choiceNumbers);
    }

    // Function to start the voting process
    function startVote() public inState(State.Created) onlyOfficial {
        state = State.Voting;
    }

    // Function for voters to cast their vote
    function doVote(
        uint _choice
    ) public inState(State.Voting) returns (bool hasVoted) {
        bool isFound = false;
        // check whether person is in registered list and has no used their vote yet
        if (
            bytes(voterRegister[msg.sender].voterName).length != 0 &&
            !voterRegister[msg.sender].hasVoted
        ) {
            voterRegister[msg.sender].hasVoted = true;
            Vote memory v;
            v.voterAddress = msg.sender;
            v.choice = _choice;
            
            // Candidate choice should be valid
            if (_choice < totalCandidate) {
                candidateRegister[_choice].voteCount++;
                votes[totalVote] = v;
                totalVote++;
                isFound = true;
            } else {
                revert("Invalid choice. Please select a valid candidate.");
            }
        }
        return isFound;
    }

    // Function to end the voting process
    function endVote() public inState(State.Voting) onlyOfficial {
        state = State.Ended;
    }

    // Function to declare the winner of the election
    function declareWinner()
        public
        view
        inState(State.Ended)
        returns (string memory)
    {
        uint winningVoteCount = 0;
        uint winningChoice = 0;

        // count the max among candidate votes
        for (uint c = 0; c < totalCandidate; c++) {
            if (candidateRegister[c].voteCount > winningVoteCount) {
                winningVoteCount = candidateRegister[c].voteCount;
                winningChoice = c;
            }
        }
        return candidateRegister[winningChoice].candidateName;
    }
}