# Cardano Feasibility Overview

## Summary

Storing EU Digital Product Passports on Cardano is technically feasible. The Cardano Foundation has published a [DPP Blueprint](../references.md#cf-dpp) describing solution patterns, and the [MPFS infrastructure](https://github.com/cardano-foundation/mpfs) provides production-grade Merkle Patricia Trie support with Aiken on-chain validators. The ecosystem is early-stage — see [existing work](existing-work.md) for an honest assessment.

The core pattern: **anchor hashes and identifiers on-chain, store full DPP data off-chain**.

## Architecture

```mermaid
graph TD
    A[Physical Product] -->|QR code / NFC| B[GS1 Digital Link URI]
    B --> C[Resolver]
    C --> D[Cardano L1]
    C --> E[Off-chain Storage]

    D -->|CIP-68 Reference NFT| F[On-chain Datum]
    F -->|contains| G[Merkle Root Hash]
    F -->|contains| H[IPFS CID / URI]
    F -->|contains| I[Product ID / GTIN]

    E -->|IPFS / Cloud| J[Full DPP JSON-LD]
    J -->|W3C VC envelope| K[UNTP Verifiable Credential]

    L[Verifier] -->|fetch datum| D
    L -->|fetch data| E
    L -->|Merkle proof| M{Hash matches?}
    M -->|yes| N[Data verified]
    M -->|no| O[Tampered / invalid]
```

## Why Cardano

| Property | Benefit for DPP |
|----------|----------------|
| **eUTxO model** | Each product's DPP is a discrete UTxO — naturally maps to per-product records |
| **Native multi-asset** | DPP tokens are first-class citizens, no ERC-721-style contract overhead |
| **[CIP-68](../references.md#cip-68) datum format** | Standard naming/datum convention for updatable per-product tokens (used for batteries; high-throughput batch anchoring for textiles) |
| **[did:prism](../references.md#did-prism-w3c)** | W3C DID method anchored on Cardano — stronger assurance than did:web |
| **[Hydra L2](../references.md#hydra)** | High-throughput channel for real-time lifecycle events |
| **Formal verification** | Aiken/Plutus validators can be formally verified for compliance logic |
| **Low fees** | $0.01-0.13 per product at current prices |

## Key components

1. **[On-chain storage](storage.md)** — CIP-68 tokens, datum structure, metadata labels
2. **[Access control](access-control.md)** — Plutus validators, role tokens, tiered visibility
3. **[Identity](identity.md)** — did:prism, Hyperledger Identus, W3C VC integration
4. **[Cost analysis](costs.md)** — per-product and at-scale economics
5. **[Scalability](scalability.md)** — L1 throughput, Hydra L2, batching patterns
6. **[EU integration](eu-integration.md)** — registry, GS1, UNTP interoperability
7. **[Existing work](existing-work.md)** — Cardano Foundation DPP standards, pilots

## Cardano Foundation DPP Standards

### Key infrastructure

| Component | Maturity | Repository |
|-----------|----------|-----------|
| **DPP Blueprint** | Conceptual (docs only) | [cardano-dpp-standards](https://github.com/cardano-foundation/cardano-dpp-standards) |
| **MPFS** (Merkle Patricia Tries) | Production-grade (Aiken + Haskell) | [mpfs](https://github.com/cardano-foundation/mpfs), [onchain](https://github.com/cardano-foundation/cardano-mpfs-onchain) |
| **did:prism / Identus** | Active open source | [hyperledger-identus](https://github.com/hyperledger-identus) |
| **Scantrust wine pilot** | Deployed (30+ wineries) | See [existing work](existing-work.md) |
