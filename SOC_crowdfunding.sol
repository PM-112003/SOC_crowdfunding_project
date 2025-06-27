// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract CrowdFunding{

    mapping(address => uint) public contributors;
    address public manager;
    uint public minimumContribution;
    uint public deadline;
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    bool private locked;

    struct Campaign{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }

    mapping(uint => Campaign) public requests;
    uint public numRequests;

    //Events
    event Contributed(address indexed contributor, uint amount);
    event Refunded(address indexed contributor, uint amount);
    event RequestCreated(uint indexed requestId, string description, uint value, address recipient);
    event Voted(address indexed voter, uint indexed requestId);
    event PaymentMade(uint indexed requestId, address recipient, uint value);
    
    constructor(uint _target, uint _deadline) {
        require(_target > 0, "Target must be positive");
        require(_deadline > 0, "Deadline duration must be positive");
        target = _target;
        deadline = block.timestamp + _deadline;  //in seconds
        minimumContribution = 100 wei;
        manager = msg.sender;
        locked = false;
    }

    modifier onlyManager(){
        require(msg.sender==manager, "only manager can call this function");
        _;
    }

    modifier noReentrancy() {
        require(!locked, "Reentrant call detected!");
        locked = true;
        _;
        locked = false;
    }

    function sendEth() public payable {
        require(block.timestamp < deadline, "deadline has passed");
        require(msg.value >= minimumContribution, "min contribution is not met");

        if(contributors[msg.sender]==0){
            noOfContributors++;
        }

        contributors[msg.sender] += msg.value;
        raisedAmount += msg.value;

        emit Contributed(msg.sender, msg.value);
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function refund() public noReentrancy {
        require(block.timestamp > deadline, "Deadline not yet passed");
        require(raisedAmount < target, "Target was met");
        require(contributors[msg.sender] > 0, "No contributions found");

        uint refundAmount = contributors[msg.sender];
        contributors[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);

        emit Refunded(msg.sender, refundAmount);
    }

    function createRequests(string memory _description, address payable _recipient, uint _value) public onlyManager{
        Campaign storage newRequest = requests[numRequests];
        numRequests++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value = _value; 
        newRequest.completed = false;
        newRequest.noOfVoters = 0;

        emit RequestCreated(numRequests, _description, _value, _recipient);
    }

    function voteRequest(uint _RequestNo) public{
        require(contributors[msg.sender]>0, "You must be a contributor");
        Campaign storage thisRequest = requests[_RequestNo];
        require(thisRequest.voters[msg.sender]==false, "You have already voted!");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;

        emit Voted(msg.sender, _RequestNo);
    }

    function makePayment(uint _RequestNo) public onlyManager{
        require(raisedAmount>=target);
        Campaign storage thisRequest = requests[_RequestNo];
        require(thisRequest.completed==false, "The request has already been completed");
        require(thisRequest.noOfVoters>noOfContributors/2, "Majority does not support!");
        
        thisRequest.recipient.transfer(thisRequest.value);
        thisRequest.completed = true;

        emit PaymentMade(_RequestNo, thisRequest.recipient, thisRequest.value);
    }

    function getRequestSummary(uint _requestId) public view returns (
        string memory, address, uint, bool, uint, uint
    ) {
        Campaign storage r = requests[_requestId];
        require(contributors[msg.sender] > 0, "Only contributors can view");
        return (
            r.description,
            r.recipient,
            r.value,
            r.completed,
            r.noOfVoters,
            noOfContributors
        );
    }

    receive() external payable {
        sendEth();
    }

    fallback() external payable {
        sendEth();
    }
}