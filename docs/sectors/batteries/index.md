# Batteries

**Regulation**: [Battery Regulation (EU) 2023/1542](https://eur-lex.europa.eu/eli/reg/2023/1542) — adopted July 2023. See [references](../references.md#reg-battery).

**Deadline**: Full battery passport mandatory **18 February 2027** for EV and industrial batteries > 2 kWh ([Art. 77(3)](../references.md#bat-art77)).

**Granularity**: Item-level — each battery gets its own passport with unique SoH tracking.

**Volume**: ~4-5M DPPs/year (EV + industrial + LMT).^[Estimate based on IEA Global EV Outlook 2024 EU EV sales projections (~3M by 2027), plus industrial and LMT batteries. See [scalability](../cardano/scalability.md#volume-requirements).] Comfortable on Cardano L1.

## Why batteries are different

Batteries are the only EU product category with:

- **Item-level tracking** confirmed in regulation ([Art. 77(1)](../references.md#bat-art77-1))
- **Dynamic data** that changes throughout the product lifecycle (State of Health, cycle count)
- **A hardware data source** (BMS) that produces the dynamic data
- **An unsolved data bridge** — how BMS data reaches the passport is unspecified ([Art. 14](../references.md#bat-art14) vs [Art. 77](../references.md#bat-art77))
- **Repurposing** — a battery can have a second life with a new passport

This makes batteries the most technically demanding DPP use case and the best proving ground for Cardano's value proposition.

## On-chain architecture: one MPT per operator

CIP-68 per battery is not viable at this scale (see [architecture](architecture.md) for the full analysis). Instead, each economic operator who places batteries on the EU market manages a **Merkle Patricia Trie (MPT)**. Every battery is a leaf. One on-chain UTxO per operator holds the root hash.

| Operator | Batteries | On-chain | Cost/year |
|----------|-----------|----------|-----------|
| BMW | ~500k | 1 UTxO | ~$18 (daily root updates) |
| CATL | ~2M | 1 UTxO | ~$18 |
| All EU operators combined | ~4-5M | ~100-200 UTxOs | ~$1,800-3,600 |

This follows the regulation: the operator responsible for the passport ([Art. 77(4)](../references.md#bat-art77-4)) owns the trie. Repurposing creates a new trie under the new operator.

## Cardano value proposition for batteries

| Value | What Cardano provides |
|-------|----------------------|
| Tamper-evident SoH history | MPT root anchored on-chain — operator cannot alter past readings without changing the root |
| Per-operator accountability | Each operator's trie is independently verifiable; no shared mutable state |
| Trustless incentive coordination | Smart contract guarantees reward for valid signed BMS readings |
| On-chain commitment as trusted clock | Commitment UTxO proves intent to read — prevents replay and stockpiling |
| Non-membership proofs | MPT proves a battery ID does NOT exist in an operator's trie (anti-counterfeiting) |

## Contents

- [**Architecture**](architecture.md) — MPT per operator, why not CIP-68, verification flow
- [Passport State](state.md) — who writes what, when, and how
- [Battery Lifecycle](lifecycle.md) — chain of responsibility from manufacturing to recycling
- [Signed BMS Readings](signed-bms.md) — secure element protocol, challenge-response
- [NFC Hardware](nfc-hardware.md) — NTAG 5 Link + OPTIGA Trust M, bill of materials
- [Payload Standard](payload-standard.md) — COSE/CBOR envelope, validation rules
- [User Reporting & Incentives](incentives.md) — reward model for field data collection
- [Ownership Transfer](ownership.md) — token-gated reporting, atomic handover

## Key data fields (Annex XIII)

| Category | Examples | Dynamic? |
|----------|----------|----------|
| Product identity | Manufacturer, model, chemistry, serial | No |
| Carbon footprint | kgCO2e/kWh, performance class | No (declared once) |
| Material composition | Hazardous substances, critical raw materials | No |
| Recycled content | % cobalt, lithium, nickel from recycled sources | No (declared once) |
| Performance specs | Rated capacity, voltage, energy density | No |
| **Dynamic performance** | **SoH, capacity fade, cycle count, energy throughput** | **Yes — continuously** |
| Status | Original / Repurposed / Waste | Yes — on events |
| Due diligence | Supply chain audit reports | Periodically |

## Open problems

1. **BMS-to-passport data bridge** — regulation mandates both BMS data (Art. 14) and passport data (Art. 77) but does not specify how data flows between them
2. **Non-connected batteries** — e-bikes, industrial batteries, older EVs have no telematics
3. **Standardization of signed readings** — no standard exists for BMS-signed data format
4. **Key lifecycle** — what happens when a BMS module is replaced
5. **Analog front-end trust** — secure element signs whatever the sensors report
