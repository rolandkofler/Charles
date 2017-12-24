pragma solidity ^0.4.19;

contract ACharlesTester{
    
    Charles public c = new Charles();
    
    function tst() public payable {
        bytes32 pledge= keccak256("I want to not drink alcohol more than once a week. My witness will randomly check by asking me to blow into a tester");
        c.commitToPrivately(pledge, this, 1 days , 14, c.THE_DAO_HACKER());
        c.witnessTo(this, 0, true);
        c.payout(0);
    }
}

// Charles is a Monkey that creates Commitment Contracts
contract Charles{
    
    // some possible anticharites
    address constant public THE_DAO_HACKER= 0xF35e2cC8E6523d683eD44870f5B7cC785051a77D; // if you wanna donate to hacker, according to http://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/
    address constant public THE_FROZEN_PARITY_WALLET= 0x863DF6BFa4469f3ead0bE8f9F2AAE51c91A907b4; // if you wanna freeze https://github.com/paritytech/parity/issues/6995
    
    address constant public ALREADY_PAYED = address(0xdeadbeef);
    
    struct Commitment{
        address committer;
        address anticharity;
        bytes32 pledge; 
        address witness; 
        uint32 interval; 
        uint32 frequency;
        uint startTime;
        uint amount;
        address[] giveTo;
    }
    
    mapping (address => Commitment) public commited;
    
    function commitToPublicly(string _pledge, address _witness, uint32 _interval, uint32 _frequency, address _anticharity) external payable{
        commitTo(keccak256( _pledge),  _witness,  _interval,  _frequency, _anticharity);
        NewPublicCommitmentCreated(msg.sender, _pledge, _witness, _interval, _frequency, _anticharity);
    }
    event NewPublicCommitmentCreated(address indexed committer, string pledge, address indexed witness, uint period, uint frequency, address indexed _anticharity);
    
    function commitToPrivately(bytes32 _pledge, address _witness, uint32 _interval, uint32 _frequency, address _anticharity) public payable
    {
        commitTo(_pledge, _witness, _interval, _frequency, _anticharity);
        
        NewPrivateCommitmentCreated(msg.sender, _pledge, _witness, _interval, _frequency, _anticharity);
    }
    event NewPrivateCommitmentCreated(address indexed committer, bytes32 pledge, address indexed witness, uint period, uint frequency, address indexed _anticharity);
    
    function commitTo(bytes32 _pledge, address _witness, uint32 _interval, uint32 _frequency, address _anticharity) internal {
        require(this.balance == 0); // old commitment should be already drained to create new
        require(msg.value % _frequency == 0); // we only accept integer divisible amounts
        address[] memory w = new address[](_frequency);
        var c =Commitment(msg.sender,_anticharity,  _pledge, _witness, _interval, _frequency, now, msg.value, w);
        commited[msg.sender]= c;
    }
    
    function witnessTo(address _committer, uint _period, bool _isBreached) external 
    {
        var c = commited[_committer];
        require (c.witness == msg.sender);
        require( c.giveTo[_period] != ALREADY_PAYED);
        
        var beneficiary= _isBreached ? c.anticharity : c.committer;
        c.giveTo[_period] = beneficiary;
        CommitmentWitnessed(c.committer, c.pledge, c.witness, _period, _isBreached);
    }
    event CommitmentWitnessed(address committer, bytes32 pledge, address witness, uint period, bool isBreached);
    
    function reclaimUnwitnessedPeriod(uint _period) external{
        var c = commited[msg.sender];
        require( c.giveTo[_period] != ALREADY_PAYED);
        require (now > c.startTime + _period * c.interval+1); //possible only if you let whitness time for one period after this
        c.giveTo[_period] =  c.committer;
    }
    
    function payout(uint _period) public payable{
        var c = commited[msg.sender];
        var amount = c.amount / c.frequency; //TODO: solve binary division rounding problem
        var beneficiary = c.giveTo[_period];
        require (beneficiary != address(0));
        c.giveTo[_period]=  ALREADY_PAYED;
        beneficiary.transfer(amount); 
        
        PayedOut(beneficiary, amount, c.pledge);
    }
    event PayedOut(address _commiter, uint amount, bytes32 pledge);
    
}
