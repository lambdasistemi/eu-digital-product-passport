# Scalability

## Layer 1 throughput

| Parameter | Value |
|-----------|-------|
| Block time | 20 seconds |
| Max block size | 90,112 bytes (~90 KB) |
| Simple TPS | ~9-18 |
| Batched TPS (multi-output) | ~40-70 effective |
| Annual capacity (15 TPS sustained) | ~473 million transactions |

With batching (30 products per transaction), L1 can register **~14 billion products/year** — far more than the EU market requires.

The bottleneck is not throughput but **cost**: at scale, individual L1 transactions become expensive compared to L2.

## Layer 2: Hydra

```mermaid
graph TD
    A[Manufacturer] -->|opens| B[Hydra Head]
    C[Logistics Provider] -->|joins| B
    D[Recycler] -->|joins| B

    B -->|~1,000 TPS| E[DPP Lifecycle Events]
    E -->|batch settle| F[Cardano L1]
    F -->|final anchor| G[On-chain Record]
```

| Property | Value |
|----------|-------|
| TPS per Hydra Head | ~1,000 |
| Demonstrated peak | 1 million TPS (1,000 heads, gaming qualifier 2024) |
| Latency | Sub-second within a head |
| Settlement | Periodic batch commits to L1 |

### DPP use cases for Hydra

- **Real-time SoH updates** for EV batteries (voltage, temperature, cycle count)
- **Supply chain event logging** (warehouse transfers, quality checks)
- **High-frequency manufacturing** (one event per product per station on the line)
- **Batch settlement** — aggregate events into a single L1 transaction periodically

LW3's DPP platform explicitly uses Hydra for EV battery supply chain tracking with CIP-68 tokenization.

## Future improvements

| Enhancement | Impact |
|------------|--------|
| **Ouroboros Leios** (Input Endorsers) | Significant L1 throughput increase |
| **Block size increases** (governance) | Currently 90 KB, incrementally adjustable |
| **CIP-150** (Block Data Compression) | Higher effective block capacity |
| **Mithril** | Fast chain sync for light clients / verifiers |

## Volume requirements

The EU produces roughly:

- ~3 million EV batteries/year (growing)
- ~6 billion textile items/year
- Hundreds of millions of electronic devices/year

For batteries (first DPP mandate, Feb 2027): L1 batching is sufficient.
For textiles and electronics at full scale: Hydra or equivalent L2 is required.

| Sector | Annual volume | L1 individual | L1 batched (30/tx) | L1 High Throughput (10k/root) | L2 (Hydra) |
|--------|--------------|--------------|-------------------|-------------------------------|------------|
| Batteries | ~3M | Comfortable | Comfortable | Trivial | Not needed |
| Iron & steel | ~50M | Tight | Comfortable | Trivial | Optional |
| Textiles | ~6B | Impossible | Tight (~6.3 TPS sustained) | Comfortable (~600k tx/year) | Optional |
| Electronics | ~500M | Impossible | Feasible | Comfortable | Optional |
| Construction | ~100M | Feasible | Comfortable | Trivial | Not needed |

!!! note "High Throughput changes the picture"
    With the CF High Throughput pattern (one Merkle root per 10k products), even 6 billion textile items require only ~600k L1 transactions/year — well within capacity. L2 (Hydra) is beneficial for real-time lifecycle events but not strictly required for initial registration.
