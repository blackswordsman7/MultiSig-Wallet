# MultiSig-Wallet

A multisignature wallet is an account that requires some m-of-n quorum of approved private keys to approve a transaction before it is executed.

Ethereum implements multisignature wallets slightly differently than Bitcoin does. In Ethereum, multisignature wallets are implemented as a smart contract, that each of the approved external accounts sends a transaction to in order to "sign" a group transaction.

Following this project spec designed by the UPenn Blockchain Club, I have created my own multisignature wallet contract.
# Objectives:

1.  To learn how to handle complex interactions between multiple users on one contract
2.  Learn how to avoid loops and implement voting
3.  To learn to assess possible attacks on contracts.
  
