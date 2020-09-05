pragma solidity >= 0.5.0 < 0.7.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";
// import "github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";


contract Government is ERC721Full, Ownable{
    
    mapping (address => uint) public votes; // who voted for whom
    mapping(uint => uint) public votesPerCandidate; //which candidateGotHowmanyVotes
    mapping (address => uint) public myVote;
    mapping(uint => address) regiteredCandidateAdd;
    uint maxVoteCount = 0;
    uint winnerId = 0;
    
    using Counters for Counters.Counter;
    Counters.Counter token_ids;
    
    using SafeMath for uint;
    uint winnerCandidateId;
    string uri;
    
    // ideally should be passed from the registration contract TODO for the future
    uint public totalCandidates;
    Counters.Counter public totalVotes;
    mapping (uint => address) candidatesAddresses;
    
    // Events to listen
    event VotedFor(uint, address);
    event ElectionEnded(bool);
    event StartElection(bool);

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool public ended;
    bool public start;
    
    address payable fec; //regiter onwner

  constructor(uint _totalCandidate) ERC721Full("Pup Elections", "PUP") public
  {
      fec = msg.sender;
      start = true;
      totalCandidates = _totalCandidate; // ideally it should come from the registration module
      uri= "https://ipfs.io/ipfs/QmTBjGVXRpUJpg1qGCrzn4ecYsthPC6oCc49Q6yoR7kib8/TreatElection.png"; // we are hard coding it for demo you can always uncomment _uri in the argument and pass your own 
    //   uri = _uri;
      registerElection(uri);
      emit StartElection(start); //emits that election started
      
  }
  
  // WE HAVE NOT CREATED A REGISTRATION DAPP FRONT END FOR THIS PROJECT YOU HAVE ADD NUMBER OF CANDIDATES (Otherwise we could just get the count of candidates and candidates details (ie address etc.))
  function registerElection(string memory _uri) public payable onlyOwner {
        token_ids.increment();
        uint token_id = token_ids.current();
        _mint(fec, token_id);
        _setTokenURI(token_id, _uri);
    }
  
  

  function vote(uint candidateId, address candidateAddress) public {
      require(!ended, "voting has ended.");
      require(votes[msg.sender]==0,"You have already voted");
      require(candidateId >= 0, "The candidate not present"); // @TODO only registered candidate must be present
      votes[msg.sender] = candidateId;
      totalVotes.increment();
      votesPerCandidate[candidateId] = votesPerCandidate[candidateId].add(1);
      regiteredCandidateAdd[candidateId] = candidateAddress;
      emit VotedFor(candidateId, msg.sender);
  }
  

   function winnerCandidate() public view
            returns (uint, uint )
    {
       
        return (winnerId, maxVoteCount);
        
    }

    
      
  function electionEnd() public {


        // 1. Conditions
        require(!ended, "auctionEnd has already been called.");
        require(msg.sender == fec, "You are not the FEC, you cannot end the Vote!");

        // 2. Effects
        ended = true;
        
        uint votecount;
        
        
        //  There is seldom a good reason for sorting/iterating to be an on-chain concern...should be done in the client    
        for (uint p = 0; p < totalCandidates; p++) {    
            votecount = votesPerCandidate[p];
            if (maxVoteCount < votecount){
                maxVoteCount = votecount;
                winnerId = p;
            }
        }
        
        safeTransferFrom(owner(), regiteredCandidateAdd[winnerId] , token_ids.current());
        
        emit ElectionEnded(ended);
        

    }
    
  
}
