# Feature Specification: Test Vector Generator Executable

**Feature Branch**: `38-test-vectors`
**Created**: 2026-04-01
**Status**: Draft
**Input**: Issue #38 — Executable that computes commitment lifecycle + reward accounting reference values in Haskell, generates Aiken test files via aiken-codegen. Depends on #37.

## User Scenarios & Testing *(mandatory)*

### Scenario 1 — Generate Aiken test files from Haskell (Priority: P1)

A developer runs `just generate-vectors` and the executable produces `.ak` test files under `aiken/lib/generated/`. Each file contains test functions with hard-coded PlutusData literals and expected results computed by Haskell.

**Why this priority**: Generated test vectors are the contract between Haskell specification and Aiken implementation (Constitution Principle II). Without them, Aiken code cannot be validated.

**Independent Test**: Run `just generate-vectors`, verify `.ak` files are produced, verify they are syntactically valid Aiken.

**Acceptance Scenarios**:

1. **Given** the Haskell project builds, **When** `just generate-vectors` is run, **Then** `.ak` test files are written to `aiken/lib/generated/`.
2. **Given** generated test files exist, **When** `aiken check` is run in the `aiken/` directory, **Then** the generated files parse without syntax errors.
3. **Given** the generator is run twice with no code changes, **When** outputs are compared, **Then** they are byte-identical (deterministic generation).

---

### Scenario 2 — Commitment lifecycle vectors (Priority: P1)

The generator produces test vectors covering the full 2-tx commitment protocol: creating a commitment (Tx 1), and clearing it with the signed reading (Tx 2). Vectors include valid and invalid cases.

**Why this priority**: The commitment protocol is the core on-chain interaction. Validators cannot be written without reference values for both the happy path and rejection cases.

**Independent Test**: Inspect generated test file for commitment lifecycle. Verify it contains both acceptance and rejection test cases with concrete PlutusData values.

**Acceptance Scenarios**:

1. **Given** a valid commitment creation scenario, **When** the generator runs, **Then** a test vector is produced with the datum, redeemer, and expected validation result (accept).
2. **Given** a commitment with expired deadline, **When** the generator runs, **Then** a test vector is produced with the expected validation result (reject).
3. **Given** a Tx 2 with a reading that does not match the commitment hash, **When** the generator runs, **Then** a rejection test vector is produced.
4. **Given** a valid Tx 2 (reading matches commitment, deadline not passed), **When** the generator runs, **Then** an acceptance test vector is produced.

---

### Scenario 3 — Reward accounting vectors (Priority: P1)

The generator produces test vectors for reward calculations: correct reward distribution after a valid reading, no reward on invalid/expired commitment, and edge cases (zero reward, multiple reporters).

**Why this priority**: Reward accounting errors would cause fund loss or unfair distribution. Haskell-computed reference values are the only trustworthy source.

**Independent Test**: Inspect generated test file for reward accounting. Verify it contains vectors for correct distribution, zero-reward, and multi-reporter cases.

**Acceptance Scenarios**:

1. **Given** a single reporter submits a valid reading, **When** the generator runs, **Then** a vector is produced with the expected reward amount for that reporter.
2. **Given** an expired commitment with no valid reading, **When** the generator runs, **Then** a vector is produced where no reward is distributed.
3. **Given** multiple reporters assigned to an item, **When** the generator runs, **Then** vectors are produced showing correct reward splits.

---

### Scenario 4 — Vector freshness CI check (Priority: P2)

CI runs `just vectors-check` which regenerates vectors into a temp directory and diffs against committed vectors. If they differ, CI fails.

**Why this priority**: Stale vectors mean the Aiken tests validate against an outdated specification. Freshness checks enforce the contract.

**Independent Test**: Modify a Haskell type, run `just vectors-check`, verify it fails. Revert, verify it passes.

**Acceptance Scenarios**:

1. **Given** committed vectors match current Haskell output, **When** `just vectors-check` runs, **Then** it exits 0.
2. **Given** a Haskell type was changed but vectors were not regenerated, **When** `just vectors-check` runs, **Then** it exits non-zero with a diff.

---

### Edge Cases

- What happens when a type has no meaningful test scenarios yet? The generator must still produce at least a round-trip vector.
- What happens when `aiken-codegen` output format changes? The generator must fail loudly, not produce malformed Aiken.
- What happens when the `aiken/lib/generated/` directory does not exist? The generator must create it.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Haskell project MUST produce an executable (e.g., `dpp-generate-vectors`) that writes Aiken test files.
- **FR-002**: Generated `.ak` files MUST use `aiken-codegen` to produce syntactically valid Aiken test functions.
- **FR-003**: The generator MUST produce vectors for commitment creation (valid datum, redeemer).
- **FR-004**: The generator MUST produce vectors for commitment clearing (matching reading, hash verification).
- **FR-005**: The generator MUST produce vectors for commitment rejection (expired, mismatched hash).
- **FR-006**: The generator MUST produce vectors for reward accounting (single reporter, multiple reporters, zero reward).
- **FR-007**: Generation MUST be deterministic — same input produces byte-identical output.
- **FR-008**: A `just generate-vectors` recipe MUST invoke the generator executable.
- **FR-009**: A `just vectors-check` recipe MUST verify committed vectors match current generator output.
- **FR-010**: Generated files MUST be written to `aiken/lib/generated/` (or a configurable output path).

### Key Entities

- **Test Vector**: A generated Aiken test function containing PlutusData literals for inputs and expected outputs.
- **Commitment Lifecycle**: The sequence: create commitment (Tx 1) then clear with reading (Tx 2).
- **Reward Accounting**: The calculation of reporter rewards based on valid readings and assignment rules.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `just generate-vectors` produces at least one `.ak` file per on-chain type.
- **SC-002**: All generated `.ak` files pass `aiken check` (syntax validity).
- **SC-003**: `just vectors-check` passes in CI when vectors are up to date.
- **SC-004**: `just vectors-check` fails when Haskell types or logic change without regenerating vectors.
- **SC-005**: At least 3 commitment lifecycle vectors (valid create, valid clear, expired reject) are generated.
- **SC-006**: At least 2 reward accounting vectors (single reporter, zero reward) are generated.

## Assumptions

- Issue #37 (Haskell types with PlutusData instances) is complete and merged.
- `aiken-codegen` provides an API to emit Aiken source code as `Text` or `ByteString`.
- The nix flake wires the generator executable output into the Aiken project input (Constitution: Development Workflow).
- The `aiken` CLI is available in the nix devShell for syntax checking.
