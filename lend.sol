pragma solidity 0.4.23;

contract NodeLender {

    address public lender;
    address public borrower;

    uint public paymentThreshold;
    uint public lenderSplit;
    uint public borrowerTxAllowance;

    // On Deployment - A Split of 10 Means 10% Lender Split
    constructor(address borrowerAddress, uint split) public {
        lender = msg.sender;
        borrower = borrowerAddress;
        lenderSplit = split;
        paymentThreshold = 10;
        borrowerTxAllowance = 2;
    }

    function() payable external {
        if(msg.value < (paymentThreshold * (1 ether))) {
            uint lenderPayment = (msg.value / 100) * lenderSplit;
            uint borrowerPayment = (msg.value - lenderPayment);
            lender.transfer(lenderPayment);
            borrower.transfer(borrowerPayment);
        }
    }

    // transfer allows lender to transfer any remaining contract balance(ie node collateral) - value is in wei
    function transfer(address to, uint value) public onlyLender returns (bool) {
        assert(address(this).balance >= value);
        to.transfer(value);
        return true;
    }
    
    // borrowerTransfer allows borrower to send a tx to verify node (must be less than 1 etho) - value is in wei
    function borrowerTransfer(address to, uint value) public onlyBorrower returns (bool) {
        assert(address(this).balance >= value && value < (1 ether) && borrowerTxAllowance > 0);
        borrowerTxAllowance--;
        to.transfer(value);
        return true;
    }

    // updateBorrowerTxAllowance allows lender to allocate borrower more tranfers
    function updateBorrowerTxAllowance(uint allowance) public onlyLender() {
        borrowerTxAllowance = allowance;
    }
    
    function updateThreshold(uint threshold) public onlyLender() {
        paymentThreshold = threshold;
    }

    function withdraw() public onlyLender() {
        lender.transfer(address(this).balance);
    }

    function updateLender(address newLender) public onlyLender() {
        lender = newLender;
    }

    function updateBorrower(address newBorrower) public onlyLender() {
        borrower = newBorrower;
    }

    modifier onlyLender {
        require(
            msg.sender == lender
        );
        _;
    }

    modifier onlyBorrower {
        require(
            msg.sender == borrower
        );
        _;
    }

    modifier lenderOrBorrower() {
        require(
            msg.sender == lender || msg.sender == borrower
        );
        _;
    }

}
