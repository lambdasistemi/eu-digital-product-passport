# Feature Specification: Aiken On-Chain Validators

**Feature Branch**: `39-aiken-validators`
**Created**: 2026-04-01
**Status**: Draft
**Input**: Issue #39 — Aiken on-chain library. Types MUST match PlutusData from #37. Tests come ONLY from generated vectors (#38). No hand-written Aiken tests. Depends on #38.

## User Scenarios & Testing *(mandatory)*

### Scenario 1 — Aiken types match Haskell PlutusData byte-for-byte (Priority: P1)

Aiken type definitions for `ItemLeaf`, `ReporterLeaf`, `Commitment`, and `ReporterAssignment` produce identical PlutusData encoding as the Haskell definitions. Constructor indices, field order, and CBOR structure match exactly.

**Why this priority**: Byte-level PlutusData compatibility is the foundation of the cardano-mpfs-cage pattern. If types diverge, validators will reject valid transactions or accept invalid ones.

**Independent Test**: Run `aiken check` and `aiken test` — the generated test vectors (from #38) include round-trip and encoding checks that verify type compatibility.

**Acceptance Scenarios**:

1. **Given** the generated test vectors from #38, **When** `aiken test` is run, **Then** all type encoding tests pass (Aiken-encoded data matches Haskell-encoded PlutusData literals).
2. **Given** an `ItemLeaf` constructed in Aiken with the same field values as a Haskell test vector, **When** serialised, **Then** the CBOR bytes match the vector's expected bytes.
3. **Given** a `Commitment` with constructor index 0 in Aiken, **When** its PlutusData representation is examined, **Then** it uses `constr(0, ...)` matching the Haskell `ToData` instance.

---

### Scenario 2 — Commitment validator accepts valid lifecycle (Priority: P1)

The commitment validator accepts Tx 1 (create commitment) when the datum is well-formed, and accepts Tx 2 (clear commitment) when the reading hash matches the commitment and the deadline has not passed.

**Why this priority**: The 2-tx commitment protocol is the core on-chain interaction. The validator must enforce it correctly.

**Independent Test**: Run `aiken test` — generated vectors include valid Tx 1 and Tx 2 scenarios with expected acceptance.

**Acceptance Scenarios**:

1. **Given** a valid commitment datum and create redeemer (Tx 1 vector from #38), **When** the commitment validator runs, **Then** validation succeeds.
2. **Given** a valid reading that matches the commitment hash and an unexpired deadline (Tx 2 vector from #38), **When** the commitment validator runs, **Then** validation succeeds.
3. **Given** a reading that does not match the commitment hash (rejection vector from #38), **When** the commitment validator runs, **Then** validation fails.
4. **Given** an expired commitment (rejection vector from #38), **When** the commitment validator runs, **Then** validation fails.

---

### Scenario 3 — Reward accounting validator (Priority: P1)

The reward validator distributes rewards correctly according to the rules computed by the Haskell specification. Reward amounts and recipients match the generated test vectors.

**Why this priority**: Incorrect reward distribution means fund loss. The validator must match Haskell-computed reference values exactly.

**Independent Test**: Run `aiken test` — generated vectors include reward distribution scenarios.

**Acceptance Scenarios**:

1. **Given** a single-reporter reward vector from #38, **When** the reward logic executes, **Then** the computed reward matches the expected amount from the vector.
2. **Given** a multi-reporter reward vector from #38, **When** the reward logic executes, **Then** each reporter's share matches the expected split.
3. **Given** an expired commitment with no valid reading (zero-reward vector from #38), **When** the reward logic executes, **Then** no rewards are distributed.

---

### Scenario 4 — No hand-written Aiken tests (Priority: P2)

The Aiken test suite contains only generated test files. No `.ak` files in the test paths are hand-written. CI enforces this by checking that all test files are under `aiken/lib/generated/`.

**Why this priority**: Constitution Principle II mandates that generated vectors are the contract. Hand-written tests could mask specification drift.

**Independent Test**: List all `.ak` test files in the Aiken project. Verify every test file lives under the generated directory.

**Acceptance Scenarios**:

1. **Given** the Aiken project, **When** test files are enumerated, **Then** all test files are under `aiken/lib/generated/`.
2. **Given** a developer adds a hand-written test file outside `aiken/lib/generated/`, **When** CI runs, **Then** it detects the violation and fails (or a linting step flags it).

---

### Edge Cases

- What happens when a generated test vector references a type not yet defined in Aiken? `aiken check` must fail with a clear error.
- What happens when Aiken's PlutusData encoding changes between compiler versions? CI must detect the mismatch through failing vector tests.
- What happens when the `aiken/lib/generated/` directory is missing or empty? `aiken test` must report no tests found (not silently pass).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Aiken MUST define types `ItemLeaf`, `ReporterLeaf`, `Commitment`, and `ReporterAssignment` with constructor indices matching the Haskell `ToData`/`FromData` instances from #37.
- **FR-002**: The commitment validator MUST enforce the 2-tx protocol: Tx 1 creates a commitment, Tx 2 clears it with a matching reading.
- **FR-003**: The commitment validator MUST reject expired commitments and mismatched reading hashes.
- **FR-004**: Reward logic MUST compute distributions matching the Haskell reference from #38.
- **FR-005**: All Aiken tests MUST come from generated vectors (#38). No hand-written Aiken test code.
- **FR-006**: `aiken build` MUST produce a Plutus blueprint with the validators.
- **FR-007**: `aiken test` MUST pass all generated vectors.
- **FR-008**: Aiken source MUST live under `aiken/` in the monorepo.

### Key Entities

- **Commitment Validator**: Spending validator enforcing the 2-tx commitment protocol.
- **Reward Logic**: Functions computing reporter reward distribution after valid readings.
- **Plutus Blueprint**: The `plutus.json` artifact produced by `aiken build`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `aiken build` succeeds and produces `plutus.json`.
- **SC-002**: `aiken test` passes all generated vectors with zero failures.
- **SC-003**: No hand-written test files exist outside `aiken/lib/generated/`.
- **SC-004**: Changing a constructor index in Aiken (without matching Haskell change) causes at least one vector test to fail.

## Assumptions

- Issue #38 (test vector generator) is complete and merged. Generated `.ak` files are committed.
- Aiken compiler version is pinned in `aiken.toml` (likely v1.1.x).
- The Aiken project uses `aiken-lang/stdlib` as a dependency.
- v1 is cooperative path only — no adversarial recourse validators (Constitution: Cardano Integration).
