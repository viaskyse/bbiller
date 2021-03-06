pragma solidity ^0.4.9;

//  1 bugs found. 3+ issues, 

//Round 1. Price per token: 0.012 AUD x   50,000,000.00  = $   600,000 AUD/ETH – Early Bird Price.
//Round 2: Price per token:  0.02 AUD x  30,906,319.00   =  $  618,126 AUD/ETH

// Existing shareholders:   2,427,015  (paid up to 14/7/2017 = $ 14,703 AUD/AUD) - from presale
// Total Anticipated  from ICO $    $   1,218,126  AUD/ETH 
// Total Capital  $         1,232,829 AUD/ETH
// Project Address: 0x7B64fa719E14496818FaCba26bc9AfC72fA6947b
 

//Allocation: 
// Market Sales over the threshold of  12,500,000   tokens are transferred to the project address, otherwise returned to the purchaser  

// Owner’s Equity:    41,666,667.08
// Owners’ Equity tokens are not released until after 1/1/2018 and then transferred to the owner’s address. Locked. 



contract BBiller {

    uint256 public totalSupply;
    address public owner;
    string public symbol = 'BBILLER';
    string public name = 'bBiller';
    
    //address sendTo;
    //uint256 amount;

    uint256 public ownersExitDate;
    uint256 public roundOneSupply;
    uint256 public refundThreshold;
    uint256 public endICODate;
    uint256 public tokenPrice;
    

    //Prevent double sending of owners tokens.
    bool public ownersEquityTransfered;
    
    mapping (address => uint256) balances; //ICO BALANCES
    mapping (uint256 => GitHubIssue) issues; 
    mapping (address => uint256) pendingWithdrawals; //ETH SPENT

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AddIssue(uint256 _gitHubId);
    event Buy();

    function BBiller() {
        owner = msg.sender;
        totalSupply =   83333333 ;
   
        //Issue coins to contract owner
        balances[msg.sender] = totalSupply;

        //2018/1/1 00:00 GMT
        ownersExitDate = 1514764800;

	    //2017 14th Oct 2017, 0:00 UTC
	    endICODate =  1507939200;

        roundOneSupply = 50000000;
				 
	    refundThreshold = 12500000;
		
        ownersEquityTransfered = false;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) throw;
        if (balances[msg.sender] >= _value && _value > 0) 
        {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else 
        { 
            return false; 
        }
    }

    function transferOwnersEquity() returns (bool success) {
        require(msg.sender == owner);

        //Can only be excuted after 1/1/2018
        if (ownersEquityTransfered == false && ownersExitDate < now)
        {
            //441,666,667;
            ownersEquityTransfered == true;
            balances[owner] -= 41666667;
            //balances[] += 41666667;

            return true;
        }
        else
        {
            throw;
        }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function buy() payable {

        //use bBiller Oracle 
        uint256 amountToTransfer = 0;

        //Save the sent ETH amount for refunds
        pendingWithdrawals[msg.sender] = msg.value / 1000000000000000;

	    // Set the price depending on the remaining number of tokens.  
        if (balances[owner] < roundOneSupply) { 
            // amountToTransfer = (msg.value / 1000000000000) * tokenprice;
	        amountToTransfer = (msg.value / 1000000000000000) * 12;
        }
        else
        {
            amountToTransfer = (msg.value / 1000000000000000) * 2;
        }

        Oracle o = Oracle(0x25Dc90FAa727aa29e437E660e8F868C9784D3828);  // to do reports unused local variable.

        Buy();
    }

    //Users can vote on a git hub issue id.  They can vote in favour, no abstane.
    struct GitHubIssue {
        uint256 gitHubId;
        uint256 start;
        uint256 end;
        uint256 inFavourCount;
        uint256 againstCount;
        mapping (address => address) voted;
    }

    //Create a new GitHub issue
    function addIssue(uint256 _gitHubId, uint256 _start, uint256 _end) {
        //Only contract owner can excute
        require(msg.sender == owner);

        //Add to mapping
        issues[_gitHubId] = GitHubIssue ({
            gitHubId: _gitHubId,
            start: _start,
            end: _end,
            inFavourCount: 0,
            againstCount: 0
        });

        //Raise event
        AddIssue(_gitHubId);
    }

    function vote(uint256 _gitHubId, bool _inFavour) {
        //voter has tokens and is allowed
        require(balances[msg.sender] > 0);
        
        if (issues[_gitHubId].start > now && issues[_gitHubId].end < now)
        {
            if (_inFavour == true)
            {
                issues[_gitHubId].inFavourCount += 1;
            }
            else
            {
                issues[_gitHubId].againstCount += 1;
            }
        }
        else
        {
            throw;
        }
    }

    //Withdraw the eth to a white listed address
    function withdraw(uint256 _amount) {

        require(msg.sender == _owner);

        if (balances[owner] > refundThreshold && endICODate < now) // TODO - This is a worry
        {

        }
        else
        {
            address bBillerTo = 0x7B64fa719E14496818FaCba26bc9AfC72fA6947b;
            bBillerTotransfer(_amount);
              
            //	address bBillerTo = 0x7B64fa719E14496818FaCba26bc9AfC72fA6947b;  
            //	owner.Transfer(owner, bBillerTo, amount);
	    }
    }

    function refund(address _to) {
        require (msg.sender == owner);

        uint256 ethAmount = pendingWithdrawals[_to];

        if (ethAmount > 0)
        {
            balances[_to] = 0;
            pendingWithdrawals[_to] = 0;

            _to.send(ethAmount);
        }
    }
}