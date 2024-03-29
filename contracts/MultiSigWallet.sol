pragma solidity ^0.5.0;

contract MultiSigWallet{
    // state variables
    address[] public owners;
    uint public required;
    mapping (address => bool) public isOwner;
    uint public transactionCount;
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;

    // Events
    event Submission(uint indexed transactionId);
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Execution(uint indexed transactinId);
    event ExectionFailiure(uint indexed transactinId);

    struct Transaction{
        bool executed;
        address destination;
        uint value;
        bytes data;
    }
    
    // modifier
    ///@dev Modifier for requirement settings for contract.
    ///@param ownerCount Count of owners for wallet.
    ///@param _required Thereshold count for the Wallet.
    modifier validRequirement(uint ownerCount, uint _required){
        if ( _required < ownerCount || _required == 0 || ownerCount == 0)
            revert();
        _;
    }
    
    ///@dev Fallback function, which accepts ether when sent to contract
    function() external payable{}
    
    /*
     * Public Functions 
     */
     
    ///@dev Contract constructor sets intial owners and required number of confirmations.
    ///@param _owners List of intial owners.
    ///@param _required Number of required confirmations.
    constructor(address[] memory _owners, uint _required) public validRequirement(_owners.length, _required) {
        for (uint i=0; i<_owners.length; i++){
            isOwner[_owners[i]] = true; 
        }
        owners = _owners;
        required = _required;
    }
    
    ///@dev Allows an owner to submit and confirm a Transaction.
    ///@param destination Transaction target address.
    ///@param value Transaction ether value.
    ///@param data Transaction data payload.
    ///@return Returns Transaction ID.
    function submitTransaction(address destination, uint value, bytes memory data) public returns (uint transactionId){
        require(isOwner[msg.sender]);
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }
    
    ///@dev Allows an owner to confirm a transaciton.
    ///@param transactionId Transaction ID.
    function confirmTransaction(uint transactionId) public {
    require(isOwner[msg.sender]);
    require(transactions[transactionId].destination != address(0));
    require(confirmations[transactionId][msg.sender] == false);
    confirmations[transactionId][msg.sender] = true;
    emit Confirmation(msg.sender, transactionId);
    executeTransaction(transactionId);
    }
    
    ///@dev Allows an owner to revoke a confirmation for a transaction.
    ///@param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId) public {}
    
    ///@dev Allows anyone to execute a confirmed transaction.
    ///@param transactionId Transaciton ID.
    function executeTransaction(uint transactionId) public {
        require(transactions[transactionId].executed == false);
        if(isConfirmed(transactionId)){
            Transaction storage t = transactions[transactionId];
            t.executed= true;
            // (bool success, bytes memory returnedData) = t.destination.send(t.value)(t.data);
            // if (success)
            //     emit Execution(transactionId);
            
            // else {
            //     emit ExectionFailiure(transactionId);
            //     t.executed = false;
            // }
        }
    }
    
    
        /*
         * (Possible) Helper Function
         */
         
         
    ///@dev Returns the confirmation status of a transaction.
    ///@param transactionId Transaction ID.
    ///@return Confirmation status.
    function isConfirmed(uint transactionId) internal view returns (bool){
        uint count = 0;
        for (uint i=0; i< owners.length; i++){
            if(confirmations[transactionId][owners[i]])
                count += 1;
            if(count == required)
                return true;
        }
    }

    ///@dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    ///@param destination Transaction target address.
    ///@param value Transaction ether value.
    ///@param data Transaction data payload.
    ///@return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes memory data) internal returns (uint transactionId) {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount+=1;
        emit Submission(transactionId);
    }
}