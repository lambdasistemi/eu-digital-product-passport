# Feature Specification: COSE_Sign1 Verification

**Feature Branch**: `42-cose-verification`
**Created**: 2026-04-01
**Status**: Draft
**Input**: Issue #42 — COSE_Sign1 verification. Haskell constructs and signs readings with test keys (Ed25519 + secp256k1). Aiken verifies using Plutus built-ins. Depends on #39.

## User Scenarios & Testing *(mandatory)*

### Scenario 1 — Haskell COSE_Sign1 construction with Ed25519 (Priority: P1)

A developer constructs a COSE_Sign1 message in Haskell for a sensor reading, signed with an Ed25519 test key. The protected header encodes the algorithm identifier. The resulting structure can be verified by the Haskell verification function.

**Why this priority**: Ed25519 is the primary curve for the NXP SE050 hardware module. Constructing valid COSE_Sign1 in Haskell is necessary to generate test vectors for Aiken.

**Independent Test**: Construct a COSE_Sign1 message, verify it in Haskell, assert success. Tamper with the payload, verify again, assert failure.

**Acceptance Scenarios**:

1. **Given** an Ed25519 key pair and a sensor reading payload, **When** a COSE_Sign1 message is constructed, **Then** Haskell verification succeeds.
2. **Given** a valid COSE_Sign1 message, **When** the payload is tampered with, **Then** Haskell verification fails.
3. **Given** a valid COSE_Sign1 message, **When** the protected header is inspected, **Then** the algorithm identifier is EdDSA (-8).
4. **Given** a valid COSE_Sign1 message, **When** the signature is replaced with random bytes, **Then** verification fails.

---

### Scenario 2 — Haskell COSE_Sign1 construction with secp256k1 (Priority: P1)

A developer constructs a COSE_Sign1 message signed with a secp256k1 test key. The protected header identifies the ECDSA algorithm. Haskell verification succeeds for valid signatures and fails for tampered ones.

**Why this priority**: Constitution Principle IV mandates dual-curve support. Both Ed25519 and secp256k1 must work end-to-end.

**Independent Test**: Same as Scenario 1 but with secp256k1 key pair.

**Acceptance Scenarios**:

1. **Given** a secp256k1 key pair and a sensor reading payload, **When** a COSE_Sign1 message is constructed, **Then** Haskell verification succeeds.
2. **Given** a valid secp256k1 COSE_Sign1 message, **When** the payload is tampered with, **Then** Haskell verification fails.
3. **Given** a valid secp256k1 COSE_Sign1 message, **When** the protected header is inspected, **Then** the algorithm identifier is ES256K (-47).

---

### Scenario 3 — Generated test vectors for Aiken COSE verification (Priority: P1)

The test vector generator (extended from #38) produces Aiken test files containing COSE_Sign1 structures as PlutusData, the corresponding public key, and the expected verification result. Vectors cover both curves and both valid/invalid cases.

**Why this priority**: Aiken must verify COSE_Sign1 on-chain using Plutus built-ins. Generated vectors are the contract (Constitution Principle II).

**Independent Test**: Run `just generate-vectors`, verify COSE-related `.ak` test files exist. Run `aiken test`, verify all pass.

**Acceptance Scenarios**:

1. **Given** a valid Ed25519 COSE_Sign1 message, **When** the generator runs, **Then** a test vector is produced with the message, public key, and expected result (valid).
2. **Given** a valid secp256k1 COSE_Sign1 message, **When** the generator runs, **Then** a test vector is produced with the message, public key, and expected result (valid).
3. **Given** a tampered Ed25519 message, **When** the generator runs, **Then** a rejection vector is produced.
4. **Given** a tampered secp256k1 message, **When** the generator runs, **Then** a rejection vector is produced.
5. **Given** an Ed25519 message verified with a secp256k1 key (curve mismatch), **When** the generator runs, **Then** a rejection vector is produced.

---

### Scenario 4 — Aiken COSE_Sign1 verification dispatching by curve (Priority: P1)

An Aiken function reads the protected header of a COSE_Sign1 structure, determines the algorithm (Ed25519 or secp256k1), and dispatches to the correct Plutus built-in verifier (`verifyEd25519Signature` or `verifyEcdsaSecp256k1Signature`).

**Why this priority**: On-chain verification is the critical path. The validator must correctly dispatch based on the protected header, not assume a single curve.

**Independent Test**: `aiken test` passes all generated COSE verification vectors for both curves.

**Acceptance Scenarios**:

1. **Given** an Ed25519 COSE_Sign1 vector, **When** the Aiken verifier runs, **Then** it dispatches to `verifyEd25519Signature` and returns `True`.
2. **Given** a secp256k1 COSE_Sign1 vector, **When** the Aiken verifier runs, **Then** it dispatches to `verifyEcdsaSecp256k1Signature` and returns `True`.
3. **Given** a tampered message vector, **When** the Aiken verifier runs, **Then** it returns `False`.
4. **Given** an unknown algorithm identifier in the protected header, **When** the Aiken verifier runs, **Then** it returns `False` (or fails explicitly).

---

### Edge Cases

- What happens when the protected header is malformed CBOR? The Aiken verifier must reject, not crash.
- What happens when the signature length is wrong for the curve? Verification must fail gracefully.
- What happens with an empty payload? Construction and verification must still work (empty payload is valid in COSE_Sign1).
- What happens with a COSE_Sign1 that has a non-empty unprotected header? The verifier should ignore unprotected headers (only protected header determines algorithm).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Haskell MUST construct COSE_Sign1 messages with Ed25519 signatures (algorithm -8).
- **FR-002**: Haskell MUST construct COSE_Sign1 messages with secp256k1 ECDSA signatures (algorithm -47).
- **FR-003**: Haskell MUST verify COSE_Sign1 messages for both curves.
- **FR-004**: Haskell MUST use deterministic test key pairs (hard-coded or derived from a fixed seed) for reproducible vector generation.
- **FR-005**: The test vector generator MUST produce Aiken test vectors for valid Ed25519 verification.
- **FR-006**: The test vector generator MUST produce Aiken test vectors for valid secp256k1 verification.
- **FR-007**: The test vector generator MUST produce rejection vectors (tampered payload, wrong key, curve mismatch).
- **FR-008**: Aiken MUST implement a COSE_Sign1 verification function that reads the protected header and dispatches to the correct Plutus built-in.
- **FR-009**: The Aiken verifier MUST use `verifyEd25519Signature` for EdDSA and `verifyEcdsaSecp256k1Signature` for ES256K.
- **FR-010**: The Aiken verifier MUST reject messages with unknown or unsupported algorithm identifiers.
- **FR-011**: COSE operations MUST live under `Dpp.Cose` in the Haskell module hierarchy.

### Key Entities

- **COSE_Sign1**: A CBOR Object Signing and Encryption structure for single-signer messages (RFC 9052). Contains protected header, unprotected header, payload, and signature.
- **Protected Header**: CBOR-encoded map containing at minimum the algorithm identifier (`alg`). Determines which Plutus built-in to use.
- **Test Key Pair**: Deterministic key pair used for vector generation. Ed25519 (32-byte private key) or secp256k1 (32-byte private key).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Haskell property tests pass for COSE_Sign1 construction and verification on both curves.
- **SC-002**: `just generate-vectors` produces COSE verification vectors for both Ed25519 and secp256k1.
- **SC-003**: `aiken test` passes all generated COSE verification vectors.
- **SC-004**: At least 2 valid vectors (one per curve) and 3 rejection vectors (tampered, wrong key, curve mismatch) are generated.
- **SC-005**: The Aiken verifier correctly dispatches to the right Plutus built-in based on the protected header algorithm field.

## Assumptions

- Issue #39 (Aiken validators with type definitions) is complete and merged.
- Plutus V3 built-ins `verifyEd25519Signature` and `verifyEcdsaSecp256k1Signature` are available in the target Aiken stdlib version.
- COSE_Sign1 follows RFC 9052. The `Sig_structure` for signing is `["Signature1", protected, external_aad, payload]` with empty external AAD.
- Test keys are NOT production keys. They are hard-coded constants used only for deterministic vector generation.
- The `crypton` or `cardano-crypto-class` library provides Ed25519 and secp256k1 primitives in Haskell.
