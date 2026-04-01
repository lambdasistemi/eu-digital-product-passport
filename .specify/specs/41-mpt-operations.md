# Feature Specification: MPT Operations

**Feature Branch**: `41-mpt-operations`
**Created**: 2026-04-01
**Status**: Draft
**Input**: Issue #41 — MPT operations in Haskell (insert/update leaves, compute root hashes, generate proofs) + Aiken verification matching Haskell reference. Depends on #39.

## User Scenarios & Testing *(mandatory)*

### Scenario 1 — Haskell MPT insert and root hash computation (Priority: P1)

A developer inserts `ItemLeaf` and `ReporterLeaf` values into an empty MPT using the Haskell library. The library computes a deterministic root hash. Inserting the same leaves in the same order always produces the same root.

**Why this priority**: The MPT root hash is the on-chain anchor for item and reporter state. Without correct insertion and hashing, the single-UTxO-per-operator model (Constitution: Cardano Integration) cannot work.

**Independent Test**: Build and run Haskell MPT unit tests. Insert known leaves, compare root hashes against hard-coded expected values.

**Acceptance Scenarios**:

1. **Given** an empty MPT, **When** a single `ItemLeaf` is inserted, **Then** the root hash matches a known expected value.
2. **Given** an MPT with one leaf, **When** a second leaf with a different key is inserted, **Then** the root hash changes and matches the expected value for two leaves.
3. **Given** the same set of leaves inserted in the same order, **When** root hashes are compared across runs, **Then** they are identical (deterministic).
4. **Given** leaves inserted in different orders, **When** root hashes are compared, **Then** they are identical (order-independent — if the MPT design requires this; otherwise document the ordering requirement).

---

### Scenario 2 — Haskell MPT update and proof generation (Priority: P1)

A developer updates an existing leaf in the MPT and generates a Merkle proof for any leaf. The proof can be verified against the root hash.

**Why this priority**: On-chain validators need Merkle proofs to verify leaf membership without storing the full trie. Update correctness ensures state transitions are valid.

**Independent Test**: Insert leaves, update one, generate proof for the updated leaf, verify proof against the new root hash.

**Acceptance Scenarios**:

1. **Given** an MPT with an `ItemLeaf`, **When** the leaf is updated with new data, **Then** the root hash changes.
2. **Given** an MPT with multiple leaves, **When** a proof is generated for a specific leaf, **Then** verifying the proof against the root hash succeeds.
3. **Given** a valid proof for leaf A, **When** the proof is verified against a root hash from a different MPT state, **Then** verification fails.
4. **Given** a proof for a non-existent key, **When** verification is attempted, **Then** it correctly reports non-membership.

---

### Scenario 3 — Generated test vectors for Aiken MPT verification (Priority: P1)

The test vector generator (extended from #38) produces Aiken test vectors for MPT proof verification. Vectors include the proof, the leaf, the root hash, and the expected verification result.

**Why this priority**: Aiken must verify MPT proofs on-chain. Generated vectors are the only way to ensure Aiken verification matches Haskell computation (Constitution Principle II).

**Independent Test**: Run `just generate-vectors`, verify MPT-related `.ak` test files are produced. Run `aiken test`, verify MPT proof verification tests pass.

**Acceptance Scenarios**:

1. **Given** a valid MPT proof computed by Haskell, **When** the generator runs, **Then** a test vector is produced with proof, leaf, root hash, and expected result (valid).
2. **Given** a tampered proof (one sibling hash changed), **When** the generator runs, **Then** a test vector is produced with expected result (invalid).
3. **Given** a proof against the wrong root hash, **When** the generator runs, **Then** a rejection vector is produced.
4. **Given** the generated vectors, **When** `aiken test` runs, **Then** all MPT verification tests pass.

---

### Scenario 4 — Aiken MPT proof verifier (Priority: P1)

An Aiken function takes a Merkle proof, a leaf, and a root hash, and returns whether the proof is valid. This function is used by the commitment validator to verify item and reporter membership.

**Why this priority**: Without on-chain proof verification, the validator cannot confirm that a reading refers to a registered item from a registered reporter.

**Independent Test**: `aiken test` passes all generated MPT verification vectors.

**Acceptance Scenarios**:

1. **Given** a valid proof vector from #38-extended, **When** the Aiken verifier runs, **Then** it returns `True`.
2. **Given** an invalid proof vector, **When** the Aiken verifier runs, **Then** it returns `False`.
3. **Given** the Aiken verifier, **When** integrated into the commitment validator, **Then** the validator rejects transactions with invalid MPT proofs.

---

### Edge Cases

- What happens with an MPT containing a single leaf? Proof generation and verification must still work.
- What happens when two keys share a long common prefix? The trie must handle branch/extension nodes correctly.
- What happens with an empty MPT (no leaves)? Root hash must be a well-defined sentinel value.
- What happens when proof size exceeds Plutus script execution budget? Document expected proof sizes for typical trie depths.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Haskell MUST implement MPT insert operation for `ItemLeaf` and `ReporterLeaf`.
- **FR-002**: Haskell MUST implement MPT update operation for existing leaves.
- **FR-003**: Haskell MUST compute deterministic root hashes from the trie state.
- **FR-004**: Haskell MUST generate Merkle proofs for any leaf in the trie.
- **FR-005**: Haskell MUST verify its own proofs against root hashes (self-consistency check).
- **FR-006**: The test vector generator MUST be extended to produce MPT proof verification vectors (valid, invalid, tampered).
- **FR-007**: Aiken MUST implement an MPT proof verification function.
- **FR-008**: The Aiken verifier MUST pass all generated MPT test vectors.
- **FR-009**: MPT proof verification MUST be usable from the commitment validator.
- **FR-010**: MPT operations MUST live under `Dpp.Mpt` in the Haskell module hierarchy.

### Key Entities

- **MPT (Merkle Patricia Trie)**: Authenticated data structure storing item and reporter leaves. Single UTxO per operator holds the root hash.
- **Merkle Proof**: A list of sibling hashes from leaf to root, sufficient to recompute the root hash.
- **Root Hash**: The single hash representing the entire trie state, stored on-chain.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Haskell MPT property tests pass: insert/lookup round-trip, proof verification for all inserted leaves.
- **SC-002**: `just generate-vectors` produces MPT proof verification vectors.
- **SC-003**: `aiken test` passes all generated MPT vectors.
- **SC-004**: Haskell and Aiken agree on root hash for identical leaf sets (verified through vectors).
- **SC-005**: Proof size for a trie with 1000 leaves is documented and within Plutus execution budget estimates.

## Assumptions

- Issue #39 (Aiken validators with type definitions) is complete and merged.
- The MPT algorithm follows the same variant used in cardano-mpfs-cage (Patricia Trie, not plain Merkle Trie).
- Hashing uses Blake2b-256 (native Plutus built-in) for both Haskell and Aiken.
- The Aiken verifier is a library function, not a standalone validator. It is called by validators that need membership proofs.
