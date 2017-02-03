pragma solidity ^0.4.6;

contract ACharlesTester{
    
    Charles public c;
    
    function tst(){
        var c = new Charles();
        c.commitTo("don't drink", this, 1 days , 14);
        c.witnessTo(this, 1, true);
        c.payout();
    }
}

// Charles is a Monkey that creates Commitment Contracts
contract Charles{
    
    address constant public theDaoHacker= 0xF35e2cC8E6523d683eD44870f5B7cC785051a77D; // according to Köppelmann here http://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/
    
    struct Commitment{
        address committer;
        string cause; 
        address witness; 
        uint32 period; 
        uint32 frequency;
        uint amount;
        bool[] witnessed;
        bool[] topay;
    }
    
    mapping (address => Commitment) public commited;
    
    
    function commitTo(string _cause, address _witness, uint32 _period, uint32 _frequency) external payable
    {
        // check if commitment needs to be made if () throw;
        bool[] w;
        bool[] p;
        var c =Commitment(msg.sender, _cause, _witness, _period, _frequency, msg.value, w, p);
        commited[msg.sender]= c;
        
        NewCommitmentCreated(msg.sender, _cause, _witness, _period, _frequency);
    }
    event NewCommitmentCreated(address committer, string cause, address witness, uint period, uint frequency);
    
    function witnessTo(address _commiter, uint _period, bool _isOk) external 
    {
        var c = commited[_commiter];
        if (c.witness != msg.sender) throw; 
        c.witnessed[_period] = _isOk;
        c.topay[_period] = _isOk;
        CommitmentWitnessed(c.committer, c.cause, c.witness, _period, _isOk);
    }
    event CommitmentWitnessed(address committer, string cause, address witness, uint period, bool isOk);
    
    function payout(){
        var c = commited[msg.sender];
        uint count =0;
        for(uint i = 0; i < c.frequency; i++){
            if (c.topay[i]) count ++;
            c.topay[i] = false;
            
        }
        msg.sender.send(c.amount*count/c.frequency); //TODO: solve binary division rounding problem
    }
    
}
