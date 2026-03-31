# Batteries

**Regulation**: [Battery Regulation (EU) 2023/1542](https://eur-lex.europa.eu/eli/reg/2023/1542) — adopted July 2023. See [references](../../references.md#reg-battery). This is the **first EU regulation to mandate a Digital Product Passport** for a specific product category.

**Deadline**: Full battery passport mandatory **18 February 2027** for EV and industrial batteries > 2 kWh ([Art. 77(3)](../../references.md#bat-art77)).

**Granularity**: Item-level — each battery gets its own passport with unique SoH tracking ([Art. 77(1)](../../references.md#bat-art77-1)). This is confirmed in regulation, unlike tyres and textiles where granularity depends on pending delegated acts.

**Volume**: ~4-5M DPPs/year (EV + industrial + LMT), based on [IEA Global EV Outlook](../../references.md#iea-gevo) EU sales projections (~3M EVs/year by 2027) plus industrial and LMT batteries. See [scalability](../../cardano/scalability.md#volume-requirements).

## Why the EU wants to trace batteries

The Battery Regulation is the most ambitious DPP mandate because batteries are at the centre of the EU's green transition — electrification of transport depends on them. Five policy streams converge:

### 1. Critical raw materials — supply chain sovereignty

Battery manufacturing depends on cobalt, lithium, nickel, and manganese — materials with concentrated supply chains (DRC for cobalt, Chile/Australia for lithium, Indonesia for nickel). The EU's dependence on third-country processing is a strategic vulnerability.

The [Critical Raw Materials Act](https://eur-lex.europa.eu/eli/reg/2024/1252) (Regulation (EU) 2024/1252) sets EU targets: 10% domestic extraction, 40% domestic processing, 25% recycling by 2030 for strategic raw materials.

The battery passport carries:

- **Recycled content** percentages for cobalt, lead, lithium, nickel ([Art. 8](https://eur-lex.europa.eu/eli/reg/2023/1542), [Annex XIII](../../references.md#bat-annex-xiii)) — making recycled content verifiable, not just claimed
- **Supply chain due diligence** documentation ([Art. 52](https://eur-lex.europa.eu/eli/reg/2023/1542)) — OECD-aligned responsible sourcing, covering child labour in artisanal cobalt mining (DRC)
- **Material composition** — enabling urban mining by telling recyclers exactly what's inside each battery

!!! note "Recycled content mandates"
    The Battery Regulation sets **binding minimum recycled content targets**: by 18 August 2031, new batteries must contain at least 16% cobalt, 6% lithium, and 6% nickel from recycled sources ([Art. 8](https://eur-lex.europa.eu/eli/reg/2023/1542)). The passport is the enforcement mechanism — without per-battery composition data, these targets are unverifiable.

### 2. Carbon footprint — climate impact transparency

Battery manufacturing is energy-intensive. The carbon footprint varies dramatically depending on the energy source used in cell production (e.g. Chinese coal-powered factories vs Swedish hydropower).

The Battery Regulation mandates:

- **Carbon footprint declaration** per kWh, specific to manufacturing site and batch — required since 18 February 2025 ([Art. 7](https://eur-lex.europa.eu/eli/reg/2023/1542))
- **Carbon footprint performance classes** (A-E) — required since 18 August 2025
- **Maximum carbon footprint thresholds** — to be set by delegated act, effectively banning the dirtiest batteries from the EU market

The DPP carries this data per battery, linked to the specific LCA study. This directly supports the EU's [Carbon Border Adjustment Mechanism](https://eur-lex.europa.eu/eli/reg/2023/956) (CBAM) — the carbon footprint of imported batteries is now traceable.

### 3. Second-life batteries — circular economy enabler

EV batteries typically retain 70-80% capacity at vehicle end-of-life. They can serve 5-10 more years in stationary storage (grid balancing, home batteries, industrial backup). But the second-life market is blocked by **information asymmetry**: buyers cannot verify the real condition of a used battery.

The passport solves this by providing:

- **State of Health (SoH)** history — not just the current value, but the full degradation curve over time
- **Cycle count** and **energy throughput** — how hard the battery was used
- **Maintenance and incident history** — was it ever deep-discharged, overheated, or involved in an accident?
- **Repurposing assessment** — the passport data enables automated valuation of second-life batteries

The regulation explicitly requires a **new passport** when a battery is repurposed ([Art. 77(6)(a)](../../references.md#bat-art77-6a)), linked to the original. The repurposing operator becomes the new responsible economic operator.

!!! warning "This is the strongest case for blockchain"
    The SoH history is the key data that makes second-life markets work. If the manufacturer controls the SoH data, they have a perverse incentive: underreporting SoH kills the second-life market and forces consumers to buy new batteries. Anchoring SoH readings on-chain — with signatures from the BMS hardware itself — prevents this manipulation. This is a genuine blockchain value-add.

### 4. Consumer protection — used battery market transparency

The used EV market is growing. Buyers need to evaluate the battery (the most expensive component) before purchase. Today this requires expensive third-party diagnostics or trusting the seller's claims.

The passport makes battery condition transparent:

- **SoH** and **remaining capacity** — verifiable, timestamped, signed by BMS hardware
- **Charging history** — fast-charging frequency (which accelerates degradation)
- **Warranty status** and **conformity declarations**

This is analogous to a vehicle history report (like Carfax) but for the battery specifically, with the data anchored in a tamper-evident record.

### 5. Safe recycling — knowing what's inside

Battery recycling is hazardous. Different chemistries (NMC, LFP, NCA, solid-state) require different recycling processes. Processing a high-nickel battery as if it were LFP can be dangerous.

The passport provides **chemistry and material composition** data to recyclers before they open the pack. The regulation specifies that the passport records material composition and end-of-life handling instructions ([Annex XIII](../../references.md#bat-annex-xiii)), enabling safe and efficient recycling.

The passport "ceases to exist" after recycling ([Art. 77(6)(b)](../../references.md#bat-art77-6b)), but the on-chain history remains as an audit trail for material recovery reporting.

## Granularity analysis

Unlike tyres and textiles, batteries have **confirmed item-level granularity** in the regulation itself ([Art. 77(1)](../../references.md#bat-art77-1)):

> "**each** LMT battery, **each** industrial battery with a capacity greater than 2 kWh and **each** electric vehicle battery placed on the market or put into service shall have an electronic record ('battery passport')."

Every policy driver requires item-level:

| Driver | Why item-level is needed |
|--------|------------------------|
| Critical raw materials / recycled content | Each battery's recycled content depends on the specific batch of cathode material used |
| Carbon footprint | Per manufacturing site and batch — varies by production run |
| Second-life / SoH | Each battery degrades differently based on individual usage |
| Consumer protection | Buyer needs the condition of *this specific* battery, not the model average |
| Safe recycling | Each battery's chemistry must be individually verified before processing |

This is what makes batteries fundamentally different from tyres and textiles: **every unit is unique** from a regulatory perspective.

## Regulatory landscape

| Regulation | Scope | Battery DPP relevance |
|-----------|-------|----------------------|
| [**Battery Regulation (EU) 2023/1542**](../../references.md#reg-battery) | Battery passport, SoH, recycled content, carbon footprint, due diligence | Primary — the entire DPP mandate |
| [**Critical Raw Materials Act (EU) 2024/1252**](https://eur-lex.europa.eu/eli/reg/2024/1252) | Strategic materials targets (extraction, processing, recycling) | DPP carries recycled content data |
| [**CBAM (EU) 2023/956**](https://eur-lex.europa.eu/eli/reg/2023/956) | Carbon border adjustment for imports | DPP carries per-battery carbon footprint |
| [**ESPR (EU) 2024/1781**](../../references.md#reg-espr) | Framework DPP regulation | Battery Reg. predates ESPR but aligns with it |
| [**EUDR (EU) 2023/1115**](../../references.md#reg-eudr) | Deforestation-free sourcing | Cobalt/nickel mining in forested regions |
| **REACH (EC) 1907/2006** | Chemical restrictions | Battery electrolyte and material safety |
| [**ELV Regulation**](https://eur-lex.europa.eu/eli/reg/2023/1542) | End-of-life vehicles | Battery passport feeds the Environmental Vehicle Passport |

### Key timeline

| Date | Requirement |
|------|------------|
| 18 Feb 2025 | Carbon footprint declaration required |
| 18 Aug 2025 | Carbon footprint performance classes (A-E) |
| **18 Feb 2027** | **Full battery passport mandatory** for EV, industrial > 2 kWh, LMT > 2 kWh |
| 18 Aug 2028 | Minimum recycled content thresholds enforced (12% cobalt, 4% lithium, 4% nickel) |
| 18 Aug 2031 | Stricter recycled content thresholds (16% cobalt, 6% lithium, 6% nickel) |

## Expected data model (Annex XIII)

| Category | Examples | Dynamic? | Policy driver |
|----------|----------|----------|--------------|
| Product identity | Manufacturer, model, chemistry, serial | No | All |
| Carbon footprint | kgCO2e/kWh, performance class, LCA reference | No (declared once) | Climate, CBAM |
| Material composition | Hazardous substances, critical raw materials | No | Safe recycling, CRMA |
| Recycled content | % cobalt, lead, lithium, nickel from recycled sources | No (declared once) | CRMA, circular economy |
| Performance specs | Rated capacity, voltage, energy density | No | Consumer protection |
| Supply chain due diligence | Responsible sourcing audit, OECD alignment | Periodically | CRMA, ethics |
| **Dynamic performance** | **SoH, capacity fade, cycle count, energy throughput** | **Yes — continuously** | **Second-life, consumer protection** |
| Status | Original / Repurposed / Waste | Yes — on events | Lifecycle management |

The critical distinction: most data is **static** (written once at manufacturing). The dynamic SoH data is what makes batteries technically demanding — and what makes the Cardano architecture valuable.

## On-chain architecture: one MPT per operator

CIP-68 per battery is not viable at this scale (see [architecture](architecture.md) for the full analysis). Instead, each economic operator who places batteries on the EU market manages a **Merkle Patricia Trie (MPT)**. Every battery is a leaf. One on-chain UTxO per operator holds the root hash.

| Operator | Batteries | On-chain | Cost/year |
|----------|-----------|----------|-----------|
| BMW | ~500k | 1 UTxO | ~$18 (daily root updates) |
| CATL | ~2M | 1 UTxO | ~$18 |
| All EU operators combined | ~4-5M | ~100-200 UTxOs | ~$1,800-3,600 |

This follows the regulation: the operator responsible for the passport ([Art. 77(4)](../../references.md#bat-art77-4)) owns the trie. Repurposing creates a new trie under the new operator.

## Cardano value proposition for batteries

| Value | What Cardano provides | Policy driver served |
|-------|----------------------|---------------------|
| Tamper-evident SoH history | MPT root anchored on-chain — operator cannot alter past readings | Second-life markets, consumer protection |
| Per-operator accountability | Each operator's trie is independently verifiable | Art. 77(4) responsibility |
| Trustless incentive coordination | Smart contract guarantees reward for valid signed BMS readings | BMS-to-passport data bridge |
| On-chain commitment as trusted clock | Commitment UTxO proves intent to read — prevents replay and stockpiling | Data integrity |
| Non-membership proofs | MPT proves a battery ID does NOT exist in an operator's trie | Anti-counterfeiting |
| Recycled content verification | On-chain anchored supply chain attestations | CRMA targets enforcement |

## Contents

- [**Architecture**](architecture.md) — MPT per operator, MPFS update flow, signed readings, reward mechanism
- [Passport State](state.md) — who writes what, when, and how
- [Battery Lifecycle](lifecycle.md) — chain of responsibility from manufacturing to recycling
- [Signed BMS Readings](signed-bms.md) — secure element protocol, challenge-response
- [NFC Hardware](nfc-hardware.md) — NTAG 5 Link + OPTIGA Trust M, bill of materials
- [Payload Standard](payload-standard.md) — COSE/CBOR envelope, validation rules
- [User Reporting & Incentives](incentives.md) — reward model for field data collection
- [Ownership Transfer](ownership.md) — token-gated reporting, atomic handover

## Open problems

1. **BMS-to-passport data bridge** — regulation mandates both BMS data ([Art. 14](../../references.md#bat-art14)) and passport data ([Art. 77](../../references.md#bat-art77)) but does not specify how data flows between them. Our [architecture](architecture.md) addresses this via user-submitted signed BMS readings with MPFS incorporation.
2. **Non-connected batteries** — e-bikes, industrial batteries, older EVs have no telematics. NFC-based signed readings (see [NFC Hardware](nfc-hardware.md)) address this for batteries with physical access.
3. **Standardization of signed readings** — no standard exists for BMS-signed data format (see [Payload Standard](payload-standard.md) for our proposed COSE/CBOR approach)
4. **Key lifecycle** — what happens when a BMS module is replaced (new secure element = new public key in the MPT leaf)
5. **Analog front-end trust** — secure element signs whatever the sensors report; physical tampering of measurement ICs is a residual risk
