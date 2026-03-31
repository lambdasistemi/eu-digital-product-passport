# Existing Work

## Cardano Foundation DPP Standards

The Cardano Foundation maintains an official open-source DPP standards repository with monthly technical working group meetings.

- **Repository**: [github.com/cardano-foundation/cardano-dpp-standards](https://github.com/cardano-foundation/cardano-dpp-standards)
- **Solution page**: [cardanofoundation.org/solutions/digital-product-passport](https://cardanofoundation.org/solutions/digital-product-passport)
- **Validator language**: Aiken (Rust-like, formally verifiable)
- **Token standard**: CIP-68
- **Data structure**: Merkle Trees / Merkle Patricia Tries

The standards define four solution patterns (Static Passport Anchor, Anchored Proof, Event Log, High Throughput) with reference implementations.

## LW3 + Hydra DPP Platform

[**LW3**](../references.md#lw3) partners with the Cardano Foundation on a [Hydra](../references.md#hydra)-powered DPP platform:

- **Focus**: EV battery supply chain
- **Architecture**: CIP-68 tokenization + Hydra L2 for real-time operational updates
- **Features**: Sub-second QR responses, high-frequency lifecycle event logging

## Scantrust + Cardano Foundation (Baia's Wine)

Georgian wine industry pilot ([case study](../references.md#scantrust-wine)):

- **Use case**: Anti-counterfeiting and supply chain digitization
- **Implementation**: QR codes linked to blockchain-verified product data
- **Scale**: Expanded from Baia's Wine (organic winery, Imereti region) to a [national partnership with the Georgian National Wine Agency](https://cardanofoundation.org/blog/cardano-foundation-partners-with-georgian-national-wine-agency) (30+ wineries)

## Supply chain metadata labels ([CIP-10](../references.md#cip-10))

| Label | Registrant | Purpose |
|-------|-----------|---------|
| 620 | [seedtrace.org](../references.md#seedtrace) | Supply chain tracing |
| 1904 | (registered) | Supply chain verification data |
| 21325 | IOG | PRISM Verifiable Data Registry |

## Other projects

| Project | Focus | Status |
|---------|-------|--------|
| **PharmaDNA** | Drug traceability (Cardano + AIoT) | Catalyst Fund 14 |
| **seedtrace** | Agricultural supply chain | Active (label 620) |
| **Cobuilder** | Construction products DPP | Pilot phase |

## Relevant CIPs

| CIP | Name | DPP relevance |
|-----|------|---------------|
| [CIP-10](../references.md#cip-10) | Metadata Label Registry | Namespace for DPP labels |
| [CIP-25](../references.md#cip-25) | Media Token Metadata | Immutable NFT metadata |
| [CIP-68](../references.md#cip-68) | Datum Metadata Standard | **Updatable on-chain DPP metadata** |
| [CIP-20](../references.md#cip-20) | Transaction Messages | Human-readable DPP event annotations |
| [CIP-26](../references.md#cip-26) | Off-Chain Metadata | Off-chain metadata references |
| [CIP-32](../references.md#cip-32) | Inline Datums | Datums embedded in UTxOs (essential for CIP-68) |
| [CIP-88](../references.md#cip-88) | Token Policy Registration | DPP collection metadata |
| [CIP-100](../references.md#cip-100) | Governance Metadata | JSON-LD structured metadata pattern (reusable for DPP) |
| CIP-119 | DRep Metadata | CIP-100 extension pattern |
