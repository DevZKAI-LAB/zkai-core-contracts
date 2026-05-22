# ZKAI - Smart Contracts

Official repository for the ZKAI ecosystem smart contracts, optimized for Solidity 0.8.20 and successfully deployed on the BNB Smart Chain Testnet.

## Deployed Contracts

### 1. ZkaiToken ($ZKAI)
* **Description:** Core ERC20 token for the ecosystem with a fixed maximum supply of 100,000,000 tokens.
* **Network:** BNB Smart Chain Testnet
* **Status:** Deployed and publicly verified via Sourcify.

### 2. ZkaiPresale
* **Description:** Automated presale (ICO) contract. It handles the distribution of $ZKAI tokens in exchange for tBNB based on a fixed rate, securely routing raised funds directly to the treasury wallet using the modern `.call` method.
* **Network:** BNB Smart Chain Testnet
* **Status:** Deployed and verified.

## Technical Features
* Developed using **Solidity ^0.8.20**.
* Built upon **OpenZeppelin** industry-standard security contracts (`Ownable`, `ERC20`).
* Gas-optimized architecture for native BNB transfers.

## Presale Parameters
* **Rate:** 100,000 $ZKAI per 1 tBNB.
* **Treasury Routing:** Automatic non-custodial forwarding on every purchase.
