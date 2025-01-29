# Crop Insurance Platform

This project implements a decentralized crop insurance platform using Clarity smart contracts on the Stacks blockchain.

## Contracts

1. `crop-insurance-core.clar`: Handles core insurance functionality, policy management, and payouts.
2. `crop-insurance-governance.clar`: Manages governance, staking, and additional features.

## Features

### Core Insurance Contract

- Policy creation and management
- Weather data integration
- Automated payout system
- Risk assessment (simplified)
- Policy querying

### Governance Contract

- Staking mechanism
- Proposal creation and voting
- Governance token (CROP_GOV_TOKEN)

## Getting Started

1. Install the [Clarinet](https://github.com/hirosystems/clarinet) development tool.
2. Clone this repository.
3. Run `clarinet console` to interact with the contracts.

## Usage

### Purchase a Policy

```clarity
(contract-call? .crop-insurance-core purchase-policy "wheat" u1000000 u30)
