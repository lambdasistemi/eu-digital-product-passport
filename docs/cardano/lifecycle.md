# Battery Lifecycle on Cardano

## The problem

A battery passport is a **living document**. Article 77(2) of Regulation 2023/1542 requires it to contain "information specific to the individual battery, **including resulting from the use of that battery**."

This means the passport must be updated throughout the battery's life:

```mermaid
graph LR
    A[Manufacturing] --> B[Sale to OEM]
    B --> C[In-vehicle use]
    C --> D[SoH degrades]
    D --> E{Decision}
    E -->|still viable| F[Second life / Repurpose]
    E -->|end of life| G[Recycling]
    F --> H[Stationary storage]
    H --> I[Further degradation]
    I --> G
    G --> J[Material recovery]
```

At each stage, the passport must record:

| Event | Who updates | Data changed |
|-------|-----------|-------------|
| Manufacturing | Manufacturer | Initial creation — all fields |
| Carbon footprint declaration | Manufacturer | LCA data, performance class |
| Sale / ownership transfer | Seller → buyer | Operator information |
| Periodic SoH update | BMS / service provider | State of Health, cycle count, energy throughput |
| Repair / maintenance | Service provider | Event log, parts replaced |
| Status change | New operator | Original → Repurposed / Remanufactured |
| End of life | Recycler | Status → Waste, material recovery data |

## History requirements

The regulation requires that historical data remain accessible. Annex XIII Section 4 includes "remaining capacity" and "capacity fade" — these only make sense if tracked over time, not just as a snapshot.

Three approaches on Cardano:

### 1. Chain history (implicit)

Every CIP-68 datum update consumes the old UTxO and creates a new one. The old datum is not in the current UTxO set but **exists in the transaction history**.

```mermaid
sequenceDiagram
    participant M as Manufacturer
    participant C as Cardano L1
    participant I as Indexer

    M->>C: Mint CIP-68 (datum v1: SoH=100%)
    Note over C: UTxO₁ with datum v1

    M->>C: Update datum (v2: SoH=95%)
    Note over C: UTxO₁ consumed, UTxO₂ with datum v2

    M->>C: Update datum (v3: SoH=88%)
    Note over C: UTxO₂ consumed, UTxO₃ with datum v3

    I->>C: Query tx history for policy ID
    C-->>I: v1, v2, v3 (all preserved in chain)
```

**Pros**: Simple, no extra cost, full history on-chain.
**Cons**: Requires a chain indexer to reconstruct history. Not directly queryable from the UTxO set — only the latest state is.

### 2. Event log pattern (CF standard)

Lifecycle events are collected off-chain, batched periodically, and a Merkle root of the batch is anchored on-chain.

```mermaid
graph TD
    A[SoH reading] --> B[Event collector]
    C[Maintenance event] --> B
    D[Ownership transfer] --> B
    B --> E[Batch of N events]
    E --> F[Merkle tree]
    F --> G[Root hash → Cardano tx]
    E --> H[Full events → IPFS]
```

**Pros**: Cost-efficient (~0.25 ADA per batch of many events), tamper-evident history, off-chain data can be large.
**Cons**: Events are not individually on-chain — only roots. Requires trust in the off-chain event store (mitigated by IPFS content-addressing).

### 3. Hybrid: current state + event log

Combine both: CIP-68 datum holds the **current state** (latest SoH, current owner, status). A separate event log anchors the **full history**.

```mermaid
graph TD
    subgraph "Current State (CIP-68)"
        A[Reference NFT datum]
        A --> B[SoH: 88%]
        A --> C[Cycles: 1,247]
        A --> D[Status: Original]
        A --> E[Owner: did:prism:...]
    end

    subgraph "History (Event Log)"
        F[Batch 1: manufacturing + initial test]
        G[Batch 2: months 1-6 SoH readings]
        H[Batch 3: first service event]
        I[Batch N: latest readings]
        F --> J[Merkle root₁ → Cardano tx₁]
        G --> K[Merkle root₂ → Cardano tx₂]
        H --> L[Merkle root₃ → Cardano tx₃]
        I --> M[Merkle rootₙ → Cardano txₙ]
    end
```

This is the most complete approach and likely what a production system would use:

- **QR scan → CIP-68 datum** gives you the current state instantly
- **Event log** provides the full auditable history
- **Chain history** serves as a backup / cross-check

## Who can update?

The Plutus validator controlling the CIP-68 reference NFT enforces update permissions:

| Actor | Proof | Allowed operations |
|-------|-------|-------------------|
| Manufacturer | Signing key (issuerPkh in datum) | All updates, initial creation |
| Authorized service provider | Role token (`DPP_SERVICE`) | SoH updates, maintenance events |
| New owner (on transfer) | Transaction signed by both parties | Ownership field update |
| Recycler | Role token (`DPP_RECYCLER`) | Status → Waste, material recovery |
| Authority | Role token (`DPP_AUTHORITY`) | Revocation, compliance flags |

The validator can also enforce **invariants**:

- SoH can only decrease (or stay the same after recalibration)
- Cycle count can only increase
- Status transitions follow a valid state machine (Original → Repurposed → Waste, never Waste → Original)

## Hydra for high-frequency updates

EV batteries in active use generate telemetry data continuously. Writing every voltage/temperature reading to L1 is impractical and unnecessary. Pattern:

1. **BMS telemetry** streams to an off-chain collector
2. Collector aggregates readings into periodic SoH snapshots (e.g., monthly)
3. Snapshots are batched and Merkle-rooted via L1 event log
4. For real-time applications (fleet management, grid balancing), a **Hydra Head** between the BMS operator and the DPP service can process high-frequency events with sub-second latency
5. Hydra settles to L1 periodically
