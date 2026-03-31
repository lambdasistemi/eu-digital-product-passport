# EU Digital Product Passport on Cardano

Feasibility study for storing EU Digital Product Passports on the Cardano blockchain.

## What is a DPP

The Digital Product Passport (DPP) is a structured data record linked to physical products via a data carrier (QR code, RFID, NFC). Mandated by the EU under the **Ecodesign for Sustainable Products Regulation (ESPR)**, it provides standardized information about sustainability, circularity, material composition, and supply chain traceability.

## Why Cardano

Cardano's eUTxO model maps naturally to per-product records. CIP-68 tokens provide updatable on-chain metadata, `did:prism` offers W3C-compliant decentralized identity, and Hydra L2 enables high-throughput event logging. The Cardano Foundation already maintains an [official DPP standards repository](https://github.com/cardano-foundation/cardano-dpp-standards).

```mermaid
graph LR
    A[Product QR] --> B[GS1 Resolver]
    B --> C[Cardano CIP-68 UTxO]
    C --> D[On-chain: hash + URI]
    D --> E[Off-chain: full DPP]
    E --> F[UNTP Verifiable Credential]
```

## Sector studies

This study covers three EU product sectors with the earliest DPP deadlines:

| Sector | Regulation | Deadline | Granularity | Cardano fit |
|--------|-----------|----------|-------------|-------------|
| [**Batteries**](sectors/batteries/index.md) | (EU) 2023/1542 | Feb 2027 | Item | Dynamic SoH tracking, signed BMS readings, ownership transfer |
| [**Tyres**](sectors/tyres/index.md) | ESPR delegated act | ~2027 | TBD | Wear monitoring, retreading lifecycle, DOT code identity |
| [**Textiles**](sectors/textiles/index.md) | ESPR delegated act | ~2027-2028 | Batch/model | Supply chain provenance, anti-counterfeiting, destruction ban |

## Key findings

| Aspect | Assessment |
|--------|-----------|
| **Technical feasibility** | High — CIP-68, Plutus, did:prism cover all requirements |
| **Cost** | $0.01-0.13/product (L1 batched), ~$0.0001 (Hydra) |
| **Scalability** | L1 sufficient for all three sectors at expected volumes |
| **EU compliance** | Technology-neutral regulation; adapter middleware needed for EU registry |
| **Identity** | did:prism is W3C-registered, supplementary to UNTP's did:web |
| **Existing work** | Cardano Foundation DPP standards, LW3 Hydra platform, pilots in wine/batteries |

## Contents

**Cardano platform** (shared infrastructure):

- [Overview](cardano/overview.md) — architecture and rationale
- [On-chain storage](cardano/storage.md) — CIP-68, datums, metadata labels
- [Access control](cardano/access-control.md) — Plutus validators, role tokens
- [Identity](cardano/identity.md) — did:prism, Identus, Verifiable Credentials
- [Cost analysis](cardano/costs.md) — per-product and at-scale economics
- [Scalability](cardano/scalability.md) — L1, Hydra L2, volume requirements
- [EU integration](cardano/eu-integration.md) — registry, GS1, UNTP
- [Existing work](cardano/existing-work.md) — CF DPP standards, pilots, CIPs

**Sector studies:**

- [Batteries](sectors/batteries/index.md) — signed BMS readings, NFC hardware, ownership transfer, incentives
- [Tyres](sectors/tyres/index.md) — wear monitoring, retreading, DOT codes
- [Textiles](sectors/textiles/index.md) — supply chain traceability, anti-counterfeiting, circular economy

**EU DPP background:**

- [Regulation](regulation.md) — ESPR, Battery Regulation, related directives
- [Timeline](timeline.md) — sector-by-sector rollout dates
- [Data model](data-model.md) — schemas and formats
- [Schemas](schemas/battery-pass.md) — Battery Pass, UNTP DPP
- [Examples](examples/battery-pass.md) — realistic JSON payloads
- [Access & governance](access.md) — three-tier model, registry, enforcement
- [Pilots](pilots.md) — CIRPASS, Battery Pass, Catena-X

## Key regulations

| Regulation | Scope | Status |
|-----------|-------|--------|
| [ESPR (EU) 2024/1781](https://eur-lex.europa.eu/eli/reg/2024/1781) | Framework for all product DPPs | In force (July 2024) |
| [Battery Regulation (EU) 2023/1542](https://eur-lex.europa.eu/eli/reg/2023/1542) | Battery passports | In force (August 2023) |
| [CPR (EU) 2024/3110](https://eur-lex.europa.eu/eli/reg/2024/3110) | Construction products DPP | In force (January 2025) |
| Delegated acts (various) | Sector-specific DPP requirements | In progress |
