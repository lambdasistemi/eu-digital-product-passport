<!--
Sync Impact Report
- Version: 0.0.0 → 1.0.0 (initial ratification)
- Added: All principles (I–V), Cardano Integration section, Development Workflow section
- Templates requiring updates: none (first version)
-->

# EU Digital Product Passport Constitution

## Core Principles

### I. Specification First (NON-NEGOTIABLE)

Every on-chain type and behavior MUST be defined in Haskell before any Aiken code is written. The Haskell project is the canonical specification — it defines PlutusData encodings, computes reference values, and generates test vectors. Aiken validators are the implementation that MUST match the specification. No Aiken code without Haskell-generated test vectors to validate it against.

### II. Test Vectors as Contract

Haskell generates Aiken test files via `aiken-codegen`. These generated `.ak` files are the contract between specification and implementation. The Aiken code MUST pass all generated tests. CI MUST verify vector freshness (committed vectors match current Haskell output). Hand-written Aiken tests are not a substitute for generated vectors.

### III. Formal Proofs for Invariants

Protocol invariants (single-use commitment, reward monotonicity, MPT consistency) MUST be proved in Lean 4 before implementation. Proofs live in `proofs/` and compile in CI. Proofs drive the protocol design — if an invariant cannot be proved, the design must change.

### IV. Dual-Curve Cryptography

The protocol MUST support both Ed25519 and secp256k1 for COSE_Sign1 signature verification. Both have native Plutus built-in verifiers. The on-chain validator reads the protected header to dispatch to the correct verifier. Hardware: NXP SE050 (supports both curves).

### V. Documentation Drives Design

Design documentation MUST be written and updated before code. The sequence is: docs → Lean proofs → Haskell specification → Aiken implementation. The MkDocs site is the public-facing design record.

## Cardano Integration

- On-chain data format follows the cardano-mpfs-cage pattern: Haskell `ToData`/`FromData` instances with hand-written constructor indices matching Aiken byte-for-byte.
- MPT (Merkle Patricia Trie) for item and reporter leaf storage, single UTxO per operator.
- 2-transaction commitment protocol: Tx 1 sets commitment, Tx 2 clears it with the signed reading.
- Configurable data visibility: full CBOR payload or hash-only on-chain, per operator.
- Cooperative path only for v1. Adversarial recourse deferred to v2.

## Development Workflow

- Monorepo: `docs/` (MkDocs), `proofs/` (Lean 4), `haskell/` (specification + vector generator), `aiken/` (on-chain validators).
- CI verifies: docs build (strict), Lean proofs compile, Haskell builds, vector freshness, Aiken tests pass.
- Nix flake wires Haskell exe output into Aiken test input.
- `just generate-vectors` regenerates vectors; `just vectors-check` gates CI.

## Governance

Constitution amendments require documentation and explicit approval. All PRs MUST verify compliance with these principles. The specification-first principle (I) and test-vector contract (II) are non-negotiable and cannot be waived.

**Version**: 1.0.0 | **Ratified**: 2026-04-01 | **Last Amended**: 2026-04-01
