# Feature Specification: Haskell Project Setup with On-Chain Types

**Feature Branch**: `37-haskell-types`
**Created**: 2026-04-01
**Status**: Draft
**Input**: Issue #37 — Haskell project with canonical on-chain types, PlutusData encoding, nix flake, aiken-codegen dependency. Following cardano-mpfs-cage pattern.

## User Scenarios & Testing *(mandatory)*

### Scenario 1 — Build Haskell library from nix flake (Priority: P1)

A developer clones the repo and runs `nix develop --quiet` followed by `cabal build all -O0`. The Haskell library compiles with all on-chain types available and PlutusData instances functional.

**Why this priority**: Without a building project, nothing else can proceed. This is the foundation for all downstream work (test vectors, Aiken validators, MPT, COSE).

**Independent Test**: Run `nix develop --quiet -c cabal build all -O0` from a clean checkout. Build succeeds with zero errors.

**Acceptance Scenarios**:

1. **Given** a clean clone of the repo, **When** `nix develop --quiet -c cabal build all -O0` is run, **Then** the build succeeds and produces a library artifact.
2. **Given** the nix flake, **When** `nix flake check` is run, **Then** all checks pass (build, formatting).
3. **Given** the flake inputs, **When** `aiken-codegen` is referenced as a dependency, **Then** it resolves and its modules are importable.

---

### Scenario 2 — Canonical types with PlutusData round-trip (Priority: P1)

Each on-chain type (`ItemLeaf`, `ReporterLeaf`, `Commitment`, `ReporterAssignment`) has hand-written `ToData`/`FromData` instances with explicit constructor indices. Serialising then deserialising any value yields the original.

**Why this priority**: Byte-level PlutusData compatibility between Haskell and Aiken is the core contract of the cardano-mpfs-cage pattern. If round-trip fails, nothing downstream works.

**Independent Test**: Property tests for each type: `fromData (toData x) === Just x` for arbitrary values.

**Acceptance Scenarios**:

1. **Given** an arbitrary `ItemLeaf` value, **When** `toData` then `fromData` is applied, **Then** the original value is recovered.
2. **Given** an arbitrary `ReporterLeaf` value, **When** `toData` then `fromData` is applied, **Then** the original value is recovered.
3. **Given** an arbitrary `Commitment` value, **When** `toData` then `fromData` is applied, **Then** the original value is recovered.
4. **Given** an arbitrary `ReporterAssignment` value, **When** `toData` then `fromData` is applied, **Then** the original value is recovered.
5. **Given** a `Commitment` with constructor index 0, **When** serialised to CBOR, **Then** the leading constructor tag matches the Aiken constr(0, ...) encoding.

---

### Scenario 3 — Constructor index stability (Priority: P2)

Constructor indices are pinned in the code and tested against known values. Changing an index must break a test, preventing accidental Aiken incompatibility.

**Why this priority**: Silent index drift would cause on-chain failures that are hard to diagnose. Pinned indices are a safety net.

**Independent Test**: Unit tests assert each type's constructor index against a hard-coded expected value.

**Acceptance Scenarios**:

1. **Given** the `ItemLeaf` type, **When** its `ToData` instance is inspected, **Then** its constructor index is documented and tested against the expected constant.
2. **Given** a developer changes a constructor index, **When** tests are run, **Then** at least one test fails.

---

### Edge Cases

- What happens when a `ByteString` field is empty? Round-trip must still succeed.
- What happens when numeric fields (reward amounts, timestamps) are at boundary values (0, maxBound)? PlutusData encoding must handle them.
- What happens when `ReporterAssignment` has an empty list of reporters? Encoding must produce valid CBOR.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Haskell library MUST define types `ItemLeaf`, `ReporterLeaf`, `Commitment`, and `ReporterAssignment` in a module hierarchy under `Dpp.Types`.
- **FR-002**: Each type MUST have hand-written `ToData` and `FromData` instances with explicit, documented constructor indices (no Generic deriving).
- **FR-003**: The nix flake MUST provide a `devShell` with GHC, cabal, and all dependencies resolved.
- **FR-004**: The flake MUST depend on `aiken-codegen` as a Haskell library input.
- **FR-005**: The project MUST use haskell.nix for build infrastructure.
- **FR-006**: Property tests MUST verify `fromData . toData === Just` for every on-chain type.
- **FR-007**: Constructor indices MUST be tested against pinned expected values.
- **FR-008**: The Haskell project MUST live under `haskell/` in the monorepo.

### Key Entities

- **ItemLeaf**: A leaf in the item MPT. Contains item identifier, data hash or payload, and metadata.
- **ReporterLeaf**: A leaf in the reporter MPT. Contains reporter public key, curve identifier, and status.
- **Commitment**: On-chain commitment datum for the 2-tx protocol. Contains commitment hash, operator, and expiry.
- **ReporterAssignment**: Maps reporters to items with permissions and constraints.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: `cabal build all -O0` succeeds from `nix develop` on a clean checkout.
- **SC-002**: `cabal test -O0 --test-show-details=direct` passes all property and unit tests (round-trip + constructor index).
- **SC-003**: `nix flake check` passes.
- **SC-004**: `aiken-codegen` modules are importable in the test suite.

## Assumptions

- GHC version is managed by haskell.nix (likely 9.8.x or 9.10.x, matching cardano-mpfs-cage).
- No Cardano node or network connectivity required for this issue — types are pure data definitions.
- The `aiken-codegen` library is available as a flake input or cabal source-repository-package.
- fourmolu is the Haskell formatter; formatting is checked in CI.
