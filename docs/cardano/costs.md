# Cost Analysis

## Per-product costs

All costs at ADA ~$0.25 USD (March 2026).

### Individual mint (CIP-68)

| Component | ADA | USD |
|-----------|-----|-----|
| Transaction fee | 0.2-0.5 | $0.05-0.13 |
| Min-UTxO deposit (refundable) | 1.5-2.0 | $0.38-0.50 |
| **Total (non-refundable)** | **0.2-0.5** | **$0.05-0.13** |

The min-UTxO deposit is locked for the lifetime of the reference NFT UTxO. It is returned when the UTxO is consumed (e.g., on product end-of-life).

### Batched minting (20-30 products per transaction)

| Component | ADA/product | USD/product |
|-----------|------------|------------|
| Transaction fee share | 0.05-0.1 | $0.013-0.025 |
| Min-UTxO deposit (refundable) | 1.5-2.0 | $0.38-0.50 |

### High throughput (Hydra L2)

| Component | ADA/product | USD/product |
|-----------|------------|------------|
| Amortized fee | ~0.0003 | ~$0.00008 |
| Hydra infrastructure | Variable | Depends on setup |

## At-scale economics

### 1 million products/year

| Method | Annual fees (ADA) | Annual fees (USD) |
|--------|------------------|------------------|
| Individual L1 | 200,000-500,000 | $50,000-125,000 |
| Batched L1 (30/tx) | 50,000-100,000 | $12,500-25,000 |
| Hydra L2 | ~300 | ~$75 |

Plus infrastructure costs:

- Cardano node operation: ~$50-100/month
- IPFS pinning (1M documents): ~$100-500/month
- API servers / resolver: ~$200-500/month
- Total infrastructure: ~$5,000-13,000/year

### 10 million products/year

| Method | Annual fees (ADA) | Annual fees (USD) |
|--------|------------------|------------------|
| Batched L1 (30/tx) | 500,000-1,000,000 | $125,000-250,000 |
| Hydra L2 | ~3,000 | ~$750 |

At this scale, Hydra becomes essential for cost-effectiveness.

## Comparison with alternatives

| Platform | Cost per product | Notes |
|----------|-----------------|-------|
| Cardano L1 (batched) | $0.013-0.025 | Decentralized, immutable |
| Cardano Hydra L2 | ~$0.0001 | Near-free, requires Hydra setup |
| Ethereum L1 | $0.50-5.00 | Gas price dependent |
| Polygon PoS | $0.001-0.01 | Centralized validator set |
| Centralized database | ~$0.001 | No tamper evidence |

## Update costs

DPP data changes over the product lifecycle (SoH updates, repairs, ownership transfers). Each update requires a transaction to consume and recreate the reference NFT UTxO with a new datum.

| Update type | L1 cost | Hydra cost |
|------------|---------|------------|
| Datum update | 0.2-0.3 ADA | ~0.0003 ADA |
| Ownership transfer | 0.2-0.3 ADA | ~0.0003 ADA |
| Batch event log (50 events) | 0.25 ADA total | ~0.001 ADA total |
