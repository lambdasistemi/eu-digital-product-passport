# Signed BMS Readings

## The idea

Every BMS contains a secure element with a private key that never leaves the chip. Anyone with physical access can request a **signed hash of the current battery state**. The signature proves the reading came from that specific BMS hardware, not from a human or a software system.

## Protocol

```mermaid
sequenceDiagram
    participant U as User / Reader
    participant B as BMS
    participant SE as Secure Element
    participant C as Cardano

    Note over B,SE: At manufacturing
    SE->>SE: Generate key pair (or pre-provisioned)
    SE-->>B: Public key
    B-->>C: Public key registered in passport (CIP-68 datum)

    Note over U,SE: At any time (field reading)
    U->>B: Request signed state (via OBD-II / Bluetooth / diagnostic port)
    B->>B: Read sensors: voltage, current, temp, SoH, cycles
    B->>B: Serialize state → hash
    B->>SE: Sign(hash)
    SE-->>B: Signature
    B-->>U: {state_data, hash, signature}

    Note over U,C: Verification
    U->>C: Fetch public key from passport datum
    C-->>U: Public key
    U->>U: Verify(signature, hash, public_key)
    U->>U: Verify(hash, state_data)
    Note over U: If both pass: reading is authentic
```

## What the signature proves

| Claim | Proven? | Why |
|-------|---------|-----|
| This data came from this specific BMS hardware | Yes | Only this secure element has the private key |
| The data was not modified after leaving the BMS | Yes | Hash mismatch would break the signature |
| The data was produced at the claimed time | Partially | Timestamp is BMS-reported, not independently verified |
| The underlying sensor readings are physically accurate | No | A faulty or manipulated analog front-end still signs garbage |

The secure element proves **authenticity** (this BMS produced this data) and **integrity** (nobody changed it). It does not prove **accuracy** (the sensors might be wrong or tampered with at the analog level). But analog sensor tampering requires physical modification of the BMS board — a much higher bar than software manipulation.

## Hardware cost

The cost of adding this capability is negligible for automotive BMS:

| Component | Cost at 100k volume |
|-----------|-------------------|
| Secure element (ATECC608B / OPTIGA Trust M) | $0.50-0.70 |
| Passives (caps, resistors) | $0.01 |
| **Total BOM addition** | **$0.51-0.71** |

| Application | BMS cost | Signing cost | Impact |
|------------|----------|-------------|--------|
| EV battery | $200-400 | $0.55 | 0.1-0.3% |
| Industrial ESS | $200-2,000 | $0.55 | 0.03-0.3% |
| E-bike (mid-range) | $20-60 | $0.55 | 1-3% |

Modern automotive MCUs (NXP S32K3, Infineon AURIX TC3xx) already include hardware security modules. For new BMS designs using these MCUs, the crypto capability is already present — it just needs firmware to use it.

One-time NRE (firmware + PCB): $20k-60k, amortized to $0.20-0.60/unit at 100k volume.

Pre-provisioned secure elements (Microchip Trust&GO) come with keys injected at the factory for $0.77/unit — zero PKI infrastructure needed.

## Signed reading format

A BMS signed reading could follow a simple structure:

```json
{
  "battery_id": "urn:eudpp:battery:de:example:2024:001",
  "bms_public_key": "0x04a1b2c3...",
  "timestamp": 1735689600,
  "state": {
    "soh_percent": 88,
    "soc_percent": 72,
    "cycle_count": 1247,
    "capacity_ah": 352,
    "nominal_capacity_ah": 400,
    "voltage_v": 389.2,
    "current_a": 0.0,
    "temp_min_c": 22,
    "temp_max_c": 25,
    "energy_throughput_kwh": 48750
  },
  "hash": "0x5bd2e1f4...",
  "signature": "0x304502210..."
}
```

The hash covers the serialized `state` object. The signature is ECDSA over the hash, produced by the secure element's private key.

## Who can request a signed reading

Anyone with physical access to the BMS interface:

| Actor | Access method | Use case |
|-------|-------------|----------|
| Vehicle owner | OBD-II adapter + app | Routine reporting for incentive rewards |
| Used battery buyer | OBD-II adapter at point of sale | Verify seller's SoH claims before purchase |
| Service center | Diagnostic tool | Maintenance records with authenticated state |
| Repurposing operator | Direct BMS connection | Assess second-life viability |
| Recycler | Direct BMS connection | Document end-of-life condition |
| Market surveillance | Diagnostic tool | Compliance audit |

No internet connection required. No manufacturer backend in the loop. The reading is self-contained and independently verifiable against the public key in the on-chain passport.

## Integration with Cardano

The signed reading feeds into the [incentive reporting model](incentives.md):

```mermaid
graph TD
    A[BMS Secure Element] -->|signed reading| B[User's App]
    B -->|submit on-chain| C[Reporting Smart Contract]
    C -->|verify signature against| D[Passport CIP-68 Datum]
    D -->|contains| E[BMS Public Key]
    C -->|signature valid + plausible| F[Release Reward to User]
    C -->|store reading hash| G[On-chain Event Log]
```

The smart contract can verify the BMS signature on-chain (or more practically, a verifier off-chain submits a proof). This means:

- The manufacturer doesn't need to trust the user — the BMS signed it
- The user doesn't need to trust the manufacturer — the reward is guaranteed by the contract
- Third parties don't need to trust either — the signature is publicly verifiable

## On-chain signature verification

ECDSA signature verification is possible in Plutus (Cardano supports `verifyEcdsaSecp256k1Signature` as a built-in). If the BMS uses secp256k1 (like Bitcoin/Ethereum) or ed25519 (like Cardano native), the signature can be verified directly in the smart contract validator.

```
ReportingValidator:
  Redeemer: SubmitSignedReading
    reading    : ByteString      -- serialized state data
    signature  : ByteString      -- BMS signature over hash(reading)
    bmsKey     : ByteString      -- BMS public key (must match datum)

  Validation:
    - bmsKey matches the BMS public key in the CIP-68 datum
    - verifyEcdsaSecp256k1Signature(bmsKey, hash(reading), signature) == True
    - Plausibility checks on deserialized reading (SoH ≤ previous, cycles ≥ previous)
    - Release reward
```

This is a significant upgrade over unsigned user reports — the smart contract doesn't just check that a user submitted something plausible, it verifies that the BMS hardware itself produced the data.

## What this changes

| Without signed BMS | With signed BMS |
|-------------------|-----------------|
| User self-reports readings — low trust | BMS signs readings — hardware-level trust |
| Manufacturer could fake data | Manufacturer can't forge BMS signatures (no private key access after provisioning) |
| Plausibility checks only (SoH can't increase) | Cryptographic verification + plausibility |
| Trust requires multiple independent sources | Single reading is independently verifiable |
| Buyer must trust seller's claims | Buyer requests fresh signed reading at point of sale |

## Open questions

1. **Standardization**: No standard exists for BMS signed readings. A CIP (Cardano Improvement Proposal) or an industry standard (SAE, ISO) would be needed to define the format, key algorithm, and serialization.
2. **Key lifecycle**: What happens when a BMS module is replaced? The new module has a different key. The passport must be updated to register the new public key.
3. **Timestamp trust**: The BMS timestamp comes from its internal clock, which may drift or be manipulated. A fresh signed reading at point of sale mitigates this (the buyer knows *when* they requested it).
4. **Analog front-end trust**: The secure element signs whatever the BMS firmware gives it. If the analog measurement ICs are tampered with (replaced with a device that outputs false voltage readings), the signature is valid but the data is wrong. This requires physical board modification — a much higher bar than software tampering, but not impossible.
5. **Regulatory adoption**: The EU Battery Regulation does not currently require signed BMS readings. A delegated act or implementing act could mandate this, especially as the BMS-to-passport data gap becomes more apparent.
