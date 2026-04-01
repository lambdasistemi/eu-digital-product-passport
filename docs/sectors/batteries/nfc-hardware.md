# NFC Hardware for Signed Readings

## Requirements

A standard hardware module that every BMS manufacturer adds to their board:

- **NFC interface** — user taps phone, no dongle needed
- **I2C master** — reads sensor data from the BMS bus
- **Secure element** — signs the reading with a private key
- **Passive power** — energized by the phone's NFC field, no battery needed
- **Standard protocol** — same for every battery, every manufacturer

## Recommended architecture

No single chip does all of this today. The cleanest solution is two chips on the same I2C bus:

```mermaid
graph LR
    subgraph "Phone"
        A[NFC reader + App]
    end

    subgraph "On BMS board"
        B[NTAG 5 Link]
        C[NXP SE050]
        D[BMS Sensor ICs]
        E[NFC Antenna]
    end

    A <-->|NFC field| E
    E <--> B
    B <-->|I2C master| C
    B <-->|I2C master| D
```

| Component | Role | Why this one |
|-----------|------|-------------|
| [**NXP NTAG 5 Link**](../../references.md#ntag5-link) (NT3H5111) | NFC interface + I2C master + energy harvesting | Only NFC tag with I2C master mode — can actively read sensors |
| [**NXP EdgeLock SE050**](../../references.md#se050) | Secure element — ECDSA/EdDSA signing | Supports secp256k1 + Ed25519 (both Plutus-native), I2C slave, CC EAL 6+, pre-provisioned variants available |

## How a tap works

```mermaid
sequenceDiagram
    participant P as Phone
    participant N as NTAG 5 Link
    participant S as OPTIGA Trust M
    participant B as BMS Sensors

    P->>N: NFC field energizes tag
    P->>N: Write challenge to mailbox (slot range)

    N->>B: I2C read: voltage, current, temp, SoH, cycles
    B-->>N: Sensor data

    N->>S: I2C: sign(hash(sensor_data ‖ validFrom ‖ validUntil))
    S-->>N: ECDSA/EdDSA signature

    N->>N: Build NDEF message: {data, challenge, signature}
    P->>N: Read NDEF message
    N-->>P: Signed reading (~300 bytes)

    Note over P: Verify signature against public key from passport
    Note over P: Submit to Cardano with reward claim
```

Total time from tap to signed reading: **200-500 ms**. The user holds their phone to the battery for under a second.

## Bill of materials

| Component | Description | 100k price | 1M price |
|-----------|------------|-----------|----------|
| [NXP NTAG 5 Link](../../references.md#ntag5-link) (NT3H5111) | NFC Type 5 tag, I2C master, energy harvesting | ~$0.55 | ~$0.35 |
| [NXP EdgeLock SE050](../../references.md#se050) | Secure element, secp256k1 + Ed25519, CC EAL 6+ | ~$2.50 | ~$1.50* |
| NFC antenna | Printed or etched on PCB, or external foil | ~$0.08 | ~$0.04 |
| Decoupling capacitor | 100µF, buffers energy harvest for crypto burst | ~$0.02 | ~$0.01 |
| Passives | Pull-ups, bypass caps | ~$0.02 | ~$0.01 |
| **Total** | | **~$3.17** | **~$1.91** |

\* SE050 distributor pricing at 3k units is ~$1.71-2.49. The 1M estimate assumes NXP direct volume negotiation.

!!! note "Pricing estimates"
    Component prices are approximate, based on distributor indicative pricing (Mouser/DigiKey) at the stated volumes. Actual production pricing depends on supply agreements and may differ.

For an EV battery BMS ($150-400, per [BatPaC](../../references.md#batpac) model), this adds ~0.5-1.3% to the cost. For an e-bike BMS ($20-60), it adds ~3.2-9.6%.

## Energy budget

Everything is powered by the phone's NFC field via the NTAG 5 Link's energy harvesting output.

| Operation | Power | Duration | Energy |
|-----------|-------|----------|--------|
| NTAG 5 Link active | ~5 mW | 400 ms | 2 mJ |
| I2C sensor read | ~1 mW | 10 ms | 0.01 mJ |
| SE050 ECDSA/EdDSA sign | ~15 mW | 100 ms | 1.5 mJ |
| **Total** | | **~400 ms** | **~3.5 mJ** |

An NFC field typically delivers 15-30 mW to the tag. A 100µF capacitor at 3V stores 0.45 mJ, providing burst capacity for the signing operation. The energy budget is tight but feasible — this is the same principle as contactless payment cards, which also perform ECDSA on harvested NFC power.

Using the **NTAG 5 Boost** variant (with boost regulator) provides a more stable voltage rail and higher harvest current, adding ~$0.10 to the BOM.

## Why NXP SE050

The choice of secure element is driven by **on-chain signature verification**. Cardano's Plutus has native built-in verifiers for exactly two elliptic curves:

- **Ed25519** — `verifyEd25519Signature` (native since Shelley)
- **secp256k1** — `verifyEcdsaSecp256k1Signature` (CIP-49, Valentine hard fork Feb 2023)

P-256 (secp256r1), the most common curve in IoT secure elements, has **no Plutus built-in**. No CIP has been proposed for P-256, and implementing P-256 verification in pure Plutus/Aiken exceeds the transaction execution budget by orders of magnitude.

| Secure Element | secp256k1 | Ed25519 | I2C | Price (100k) | On-chain verify? |
|----------------|-----------|---------|-----|-------------|-----------------|
| **NXP SE050** | **Yes** | **Yes** | Yes | ~$2.50 | **Both curves — native** |
| Infineon OPTIGA Trust M | No | No | Yes | ~$0.90 | ZK wrapper only (see below) |
| Microchip ATECC608B | No | No | Yes | ~$0.81 | ZK wrapper only (see below) |
| Infineon SECORA Blockchain | Yes | No | No | ~$1.50 | secp256k1 only |
| Tropic Square TROPIC01 | No | Yes | SPI | ~$1.50 | Ed25519 only |

The SE050 is the only commercially available secure element that supports **both** Plutus-compatible curves while providing I2C for sensor bus integration. The ~$1.60 premium over OPTIGA Trust M (at 100k distributor pricing) buys direct on-chain verification — no off-chain intermediary needed. At 1M+ direct volumes, the premium narrows.

### Alternative: P-256 with ZK proof wrapper

A P-256 signature from an OPTIGA Trust M **can** be verified on Cardano indirectly via a Groth16 SNARK:

1. The operator verifies the P-256 COSE_Sign1 signature off-chain
2. A [circom-ecdsa-p256](https://github.com/privacy-ethereum/circom-ecdsa-p256) circuit generates a Groth16 proof attesting "this P-256 signature is valid for this message and this public key"
3. The on-chain validator verifies the Groth16 proof using Cardano's BLS12-381 built-ins (CIP-0381)

This works today in theory, but adds significant complexity:

| Aspect | Native (SE050) | ZK wrapper (OPTIGA) |
|--------|---------------|---------------------|
| On-chain cost | ~1% tx budget (built-in) | ~23% tx budget (Groth16 verify) |
| Off-chain infra | None | Proving server (26s per proof, 56GB RAM) |
| Phone proving | N/A | Not feasible — must delegate to server |
| Circuit audit status | N/A (built-in) | **Unaudited** |
| SE price (100k) | ~$2.50 | ~$0.90 |

The ZK path trades cheaper hardware for a proving infrastructure and an unaudited cryptographic circuit. [CIP-0133](https://cips.cardano.org/cip/CIP-0133) (native multi-scalar multiplication) would reduce the on-chain Groth16 verification cost once enabled.

### Alternative: off-chain verification only

If on-chain signature verification is not required, any P-256 secure element works. The operator verifies the COSE_Sign1 signature off-chain and the on-chain validator trusts the operator's attestation (the operator's own signing key on the MPT update transaction serves as the trust anchor).

!!! warning "Trust model impact"
    Without on-chain signature verification, the protocol **cannot claim** that all readings stored on-chain are cryptographically bound to the physical item's secure element. The chain records that the operator _says_ a valid reading occurred, not that it can independently prove it. Third-party auditors must trust the operator's off-chain verification, which is the same trust model as a centralized database — the blockchain adds immutability but not independent verifiability.

    This is still useful (tamper-evident log, regulatory compliance), but it is a weaker guarantee than full on-chain verification.

## Alternative: Infineon SECORA Blockchain

The [SECORA Blockchain](../../references.md#secora-blockchain) chip (SLC37 family) combines NFC + secure element + ECDSA in a single package. It is used in [Tangem](../../references.md#tangem) hardware wallet cards. The phone taps, the chip signs, done.

| Aspect | NTAG 5 + SE050 | SECORA Blockchain |
|--------|---------------|-------------------|
| Chips needed | 2 | 1 |
| ECDSA/EdDSA signing | Yes (via SE050) | ECDSA only (secp256k1) |
| Plutus-compatible curves | secp256k1 + Ed25519 | secp256k1 only |
| NFC | Yes (NTAG 5) | Yes (built-in) |
| I2C bus master | Yes (NTAG 5 Link) | **No** |
| Can read BMS sensors | Yes | No — needs external bridge |
| Cost (100k) | ~$3.17 | ~$1.50 + bridge MCU |
| Passive powered | Yes | Yes |

The SECORA is a true single-chip NFC+SE but **cannot read sensors from the I2C bus**. It's designed as a standalone card element, not an embedded sensor interface. You'd still need an NTAG 5 Link or a small MCU to bridge the sensor data to it, making it more expensive and complex than the two-chip solution.

## What needs standardization

The hardware is available and cheap. What's missing is a **standard protocol** that every manufacturer implements:

1. **Signed reading format** — what fields, what serialization, what hash algorithm
2. **NFC command set** — how the phone sends the challenge and receives the response (NDEF message format)
3. **Key provisioning** — how the public key is registered in the battery passport at manufacturing
4. **Key algorithm** — secp256k1 (ECDSA, CIP-49 built-in) or Ed25519 (EdDSA, native since Shelley). Both supported; operator chooses per deployment.
5. **Challenge format** — Cardano slot range (validFrom, validUntil) from the on-chain commitment

This could be:

- A **CIP** (Cardano Improvement Proposal) for the on-chain verification protocol
- An **industry standard** (ISO, SAE, or IEC) for the BMS-side protocol
- An **EU implementing act** mandating signed BMS readings as part of the battery passport

## Existing precedents

| Product | What it does | Chip | Relevance |
|---------|-------------|------|-----------|
| [Tangem](../../references.md#tangem) wallet cards | NFC tap → ECDSA signature of transaction | [SECORA Blockchain](../../references.md#secora-blockchain) | Same sign-on-tap pattern |
| Abbott FreeStyle Libre | NFC tap → 14 days of glucose sensor data | NFC + MCU + sensor | Same read-sensor-via-NFC pattern |
| NXP DNA authentication | NFC tap → AES-CMAC proof of authenticity | [NTAG 22x DNA](../../references.md#ntag-22x-dna) | Same tap-to-authenticate pattern (but symmetric, not ECDSA) |
| Rémy Martin connected bottles | NFC tap → product authentication | [NTAG 22x DNA](../../references.md#ntag-22x-dna) | Anti-counterfeit for physical products ([NXP case study](https://www.nxp.com/company/about-nxp/remy-martin-club-connected-bottle:REMY-MARTIN-CLUB-CONNECTED)) |
| Cold chain loggers | NFC tap → signed temperature history | NFC + crypto tag | Same sensor-data-via-NFC pattern |
