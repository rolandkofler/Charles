pragma solidity ^0.4.6;

contract ACharlesTester{
    
    Charles public c;
    
    function ACharlesTester(){
        var c = new Charles();
        c.commitTo("don't drink", 0xaffe, 1 days , 14 days);
    }
}

// Charles is a Monkey that creates Commitment Contracts
contract Charles{
    
    address constant public theDaoHacker= 0xF35e2cC8E6523d683eD44870f5B7cC785051a77D; // according to Köppelmann here http://hackingdistributed.com/2016/06/18/analysis-of-the-dao-exploit/
    
    struct Commitment{
        string cause; 
        address witness; 
        uint32 period; 
        uint32 frequency;
    }
    
    mapping (address => Commitment) commitments;
    
    function commitTo(string _cause, address _witness, uint32 _period, uint32 _frequency) external payable
    {
        // check if commitment needs to be made if () throw;
        commitments[msg.sender]= Commitment(_cause, _witness, _period, _frequency);
        NewCommitment(msg.sender, _cause, _witness, _period, _frequency);
    }
    event NewCommitment(address committer, string cause, address witness, uint32 period, uint32 frequency);
    
    function witness() external
    {
        
    }
    
}
