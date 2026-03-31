# Existing Work

## Cardano Foundation DPP Blueprint

The Cardano Foundation published a DPP standards document describing four solution patterns for Digital Product Passports on Cardano.

- **Repository**: [github.com/cardano-foundation/cardano-dpp-standards](https://github.com/cardano-foundation/cardano-dpp-standards)
- **Solution page**: [cardanofoundation.org/solutions/digital-product-passport](https://cardanofoundation.org/solutions/digital-product-passport)
- **Content**: A blueprint document ([DPP-Blueprint-Cardano-v0.1.md](https://github.com/cardano-foundation/cardano-dpp-standards/blob/main/DPP-Blueprint-Cardano-v0.1.md)), persona definitions, and a CPS draft

!!! warning "Maturity assessment"
    The repository contains **documentation only** — no code, no schemas, no reference implementations. 16 commits by 3 contributors, last activity January 2026. The four solution patterns (Static Passport Anchor, Anchored Proof, Event Log, High Throughput) are described conceptually but not implemented in this repo.

## MPFS — Merkle Patricia Forestry Service

The on-chain infrastructure that could actually support DPP at scale exists in the MPFS repositories under the Cardano Foundation:

| Repository | Content | Activity |
|-----------|---------|----------|
| [cardano-foundation/mpfs](https://github.com/cardano-foundation/mpfs) | Off-chain HTTP service (Haskell) — trie management, proof generation, transaction building | 290+ commits, active |
| [cardano-foundation/cardano-mpfs-onchain](https://github.com/cardano-foundation/cardano-mpfs-onchain) | Aiken on-chain validators — MPT transition proof verification, cage model | 34 commits, active (March 2026) |
| [cardano-foundation/cardano-mpfs-cage](https://github.com/cardano-foundation/cardano-mpfs-cage) | Language-agnostic cage validator spec + cross-language test vectors | Active (March 2026) |

MPFS provides the per-operator Merkle Patricia Trie model described in the [battery architecture](../sectors/batteries/architecture.md). This is production-grade code with Aiken validators and QuickCheck property tests.

## LW3

LW3 Private Limited (Guwahati, India) was selected for the Cardano Foundation Venture Hub first cohort and announced pilot programs for EV batteries and textiles.

!!! warning "Maturity assessment"
    LW3 has no public GitHub repositories and no evidence of deployed products as of March 2026. The company originated in the Algorand ecosystem and expanded to Cardano. Announced pilots have not been publicly demonstrated. Treat all LW3 claims as pre-product.

## Scantrust + Cardano Foundation (Baia's Wine)

Georgian wine industry pilot ([case study](../references.md#scantrust-wine)) — this is the most mature Cardano supply chain deployment:

- **Use case**: Anti-counterfeiting and supply chain digitization
- **Implementation**: QR codes linked to blockchain-verified product data
- **Scale**: Expanded from Baia's Wine (organic winery, Imereti region) to a [national partnership with the Georgian National Wine Agency](https://cardanofoundation.org/blog/cardano-foundation-partners-with-georgian-national-wine-agency) (30+ wineries)
- **Relevance**: Proves the QR → blockchain → verification flow works in production, though the data model is simpler than a full DPP

## Supply chain metadata labels ([CIP-10](../references.md#cip-10))

| Label | Registrant | Purpose |
|-------|-----------|---------|
| 620 | [seedtrace.org](../references.md#seedtrace) | Supply chain tracing |
| 1904 | (registered) | Supply chain verification data |
| 21325 | IOG | PRISM Verifiable Data Registry |

## Other projects

| Project | Focus | Status |
|---------|-------|--------|
| **seedtrace** | Agricultural supply chain | Active (label 620) |
| **PharmaDNA** | Drug traceability (Cardano + AIoT) | Catalyst Fund 14 |
| **Cobuilder** | Construction products DPP | Pilot phase (no public evidence of deployment) |

## Relevant CIPs

| CIP | Name | DPP relevance |
|-----|------|---------------|
| [CIP-10](../references.md#cip-10) | Metadata Label Registry | Namespace for DPP labels |
| [CIP-25](../references.md#cip-25) | Media Token Metadata | Immutable NFT metadata |
| [CIP-68](../references.md#cip-68) | Datum Metadata Standard | Naming convention for updatable tokens (limited scalability — see [storage](storage.md)) |
| [CIP-32](../references.md#cip-32) | Inline Datums | Datums embedded in UTxOs |
| [CIP-100](../references.md#cip-100) | Governance Metadata | JSON-LD structured metadata pattern (reusable for DPP) |

## Honest assessment

The Cardano DPP ecosystem is **early-stage**. The strongest asset is the MPFS infrastructure (Merkle Patricia Tries with Aiken on-chain verification), which provides the scalable per-operator trie model needed for millions of battery passports. The DPP Blueprint is a useful conceptual framework but lacks implementation. The Scantrust wine pilot proves the basic flow works. Everything else is announcements without shipped product.
